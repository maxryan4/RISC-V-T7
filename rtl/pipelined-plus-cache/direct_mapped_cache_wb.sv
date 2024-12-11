module direct_mapped_cache_wb #(
    parameter SETS = 32,
    parameter CACHE_LINE_SIZE_MULT_POW2 = 0,
    parameter AW = 12,
    localparam SL = 4,
    localparam RAM_SZ = (SETS*(2**CACHE_LINE_SIZE_MULT_POW2)),
    localparam TAG_W = AW-$clog2(SETS)-CACHE_LINE_SIZE_MULT_POW2
) (
    input   wire logic              cpu_clock_i,

    // CPU interface in (note does not include bottom two bits of address)
    input   wire logic [AW+1:0]     cpu_addr_i, // Address of data to access
    input   wire logic [31:0]       cpu_data_i, // CPU Data in, used in stores
    input   wire logic [2:0]        cpu_mem_ctrl_i, // instr[14:12]
    input   wire logic              cpu_mem_write_i, // if CPU is requesting a write
    input   wire logic              cpu_valid_i, // if a memory operation is being executed that cycle
    /**
        Note:
            When using this cache, data is valid, and may be forwarded to the writeback stage, IFF 
                !cpu_stall_o
            when cpu_stall_o is high, all subsequent stages must be stalled.
    **/
    // Backing memory in
    input   wire logic              wb_stall_i, // Wishbone signal: stall_i
    input   wire logic              wb_ack_i, // Wishbone signal: acknowledgment
    input   wire logic [31:0]       wb_dat_i, // Wishbone signal: data in (used for cache fills)
    input   wire logic              wb_err_i, // Wishbone signal: error (should never be high)
    // CPU interface out
    output       logic [31:0]       cpu_data_o, // CPU Data out, formatted for the registers already
    output       logic              cpu_stall_o, // IFF this signal is high, then the rest of the stages in the CPU **MUST** be stalled
    // Backing memory out
    output       logic              wb_cyc_o,
    output       logic              wb_stb_o,
    output       logic              wb_we_o,
    output       logic [AW-1:0]     wb_adr_o,
    output       logic [31:0]       wb_dat_o,
    output       logic [SL-1:0]     wb_sel_o
);
    // This cache has write back behaviour, no allocate
    reg [31:0]      cache_ram[0:RAM_SZ-1];
    reg [TAG_W-1:0] tags[0:SETS-1];
    reg             valid[0:SETS-1];
    reg             dirty[0:SETS-1];
    typedef enum { CACHE_IDLE, CACHE_WRITE, CACHE_FILL, CACHE_EVICT } cache_state_t;
    cache_state_t   cache_state;
    wire                         cache_fill;
    wire  [3:0]                  cache_wr;
    wire  [3:0]                  cpu_cache_wr;
    wire                         fill_end_condition;
    wire                         fill_pend_condition;
    wire                         evict_end_condition;
    wire                         evict_pend_condition;
    wire  [31:0]                 cpu_wr_data;
    wire  [31:0]                 ram_wr_data;
    wire  [31:0]                 ram_data;
    wire  [$clog2(RAM_SZ)-1:0]   cpu_rd_addr;
    wire  [$clog2(RAM_SZ)-1:0]   ram_rd_addr;
    wire  [$clog2(SETS)-1:0]     cpu_set;
    wire  [TAG_W-1:0]            cpu_tag;
    wire  [TAG_W-1:0]            tag_read;
    wire                         valid_read;
    wire                         dirty_read;
    wire                         cpu_match;
    wire  [$clog2(RAM_SZ)-1:0]   fill_addr;
    wire  [$clog2(RAM_SZ)-1:0]   evict_addr;
    wire  [$clog2(RAM_SZ)-1:0]   ram_wr_addr;
    assign ram_wr_data = cache_fill ? wb_dat_i : cpu_wr_data;
    assign cache_wr = cache_fill ? {4{wb_ack_i&!wb_err_i}} : {cpu_cache_wr&{4{cpu_mem_write_i}}&{4{cpu_match}}};
    assign cache_fill = cache_state==CACHE_FILL;
    assign ram_wr_addr = cache_fill ? fill_addr : ram_rd_addr;
    initial begin
        for (integer i = 0; i < RAM_SZ; i++) begin
            cache_ram[i] = '0;
        end
        for (integer i = 0; i < SETS; i++) begin
            tags[i] = '0; valid[i] = '0; dirty[i] = '0;
        end 
    end

    assign cpu_set = cpu_addr_i[$clog2(SETS)+CACHE_LINE_SIZE_MULT_POW2+1:CACHE_LINE_SIZE_MULT_POW2+2];
    assign cpu_tag = cpu_addr_i[AW+1:$clog2(SETS)+CACHE_LINE_SIZE_MULT_POW2+2];
    
    assign tag_read = tags[cpu_set];
    assign valid_read = valid[cpu_set];
    assign dirty_read = dirty[cpu_set];

    assign cpu_match = valid_read&&(tag_read==cpu_tag);
    assign cpu_stall_o = cpu_valid_i&(!cpu_match & !(wb_ack_i&cpu_mem_write_i)); // stall when load/store references uncached line, and exception when wb_ack_i&cpu_mem_write_i
    
    generate if (CACHE_LINE_SIZE_MULT_POW2==0) begin : __if_no_spatial
        assign cpu_rd_addr = cpu_set;
    end else begin : __if_spatial
        assign cpu_rd_addr = {cpu_set, 
        cpu_stall_o&!cpu_mem_write_i&dirty_read ? {CACHE_LINE_SIZE_MULT_POW2{1'b0}} : cpu_addr_i[CACHE_LINE_SIZE_MULT_POW2+1:2]};
    end endgenerate

    assign ram_rd_addr = cache_state==CACHE_EVICT ? evict_addr : cpu_rd_addr;
    assign ram_data = cache_ram[ram_rd_addr];
    load_format lf0 (ram_data, cpu_addr_i[1:0], cpu_mem_ctrl_i, cpu_data_o);
    store_format sf0 (cpu_data_i, cpu_addr_i[1:0], cpu_mem_ctrl_i[1:0], cpu_wr_data, cpu_cache_wr);

    
    generate if (CACHE_LINE_SIZE_MULT_POW2==0) begin : ___if_no_spatial
        assign fill_end_condition = 1'b1;
        assign fill_addr = cpu_set;
        assign fill_pend_condition = 1'b1;
        assign evict_pend_condition = 1'b1;
        assign evict_end_condition = 1'b1;
        assign evict_addr = cpu_set;
    end else begin : ___if_spatial
        reg [CACHE_LINE_SIZE_MULT_POW2-1:0] counter = '0;
        reg [CACHE_LINE_SIZE_MULT_POW2-1:0] evict_ack_counter = 0;
        reg [CACHE_LINE_SIZE_MULT_POW2-1:0] evict_rq_counter = '0;
        always_ff @(posedge cpu_clock_i) begin
            if ((cache_state==CACHE_FILL)&&wb_ack_i) begin
                counter <= counter + 1;
            end
            if ((cpu_stall_o&!cpu_mem_write_i&valid_read&dirty_read&(cache_state==CACHE_IDLE))||(cache_state==CACHE_EVICT&&!wb_stall_i&&!evict_pend_condition)) begin
                evict_rq_counter <= evict_rq_counter+1;
            end
            if ((cache_state==CACHE_EVICT)&&wb_ack_i) begin
                evict_ack_counter <= evict_ack_counter + 1;
            end
        end
        assign fill_end_condition = counter == {CACHE_LINE_SIZE_MULT_POW2{1'b1}};
        assign fill_addr = {cpu_set, counter};
        assign fill_pend_condition = wb_adr_o[CACHE_LINE_SIZE_MULT_POW2-1:0]=={CACHE_LINE_SIZE_MULT_POW2{1'b1}};
        assign evict_pend_condition = wb_adr_o[CACHE_LINE_SIZE_MULT_POW2-1:0]=={CACHE_LINE_SIZE_MULT_POW2{1'b1}};
        assign evict_end_condition = evict_ack_counter == {CACHE_LINE_SIZE_MULT_POW2{1'b1}};
        assign evict_addr = {cpu_set, evict_rq_counter};
    end endgenerate

    always_ff @(posedge cpu_clock_i) begin
        case (cache_state)
            CACHE_IDLE: begin
                if (cpu_match&cpu_valid_i&cpu_mem_write_i) begin
                    dirty[cpu_set] <= 1'b1;
                end
                if (cpu_stall_o&cpu_mem_write_i) begin
                    cache_state <= CACHE_WRITE;
                    wb_adr_o <= cpu_addr_i[AW+1:2];
                    wb_cyc_o <= 1'b1;
                    wb_stb_o <= 1'b1;
                    wb_dat_o <= cpu_wr_data;
                    wb_sel_o <= cache_wr;
                    wb_we_o <= 1'b1;
                end else if (cpu_stall_o&!cpu_mem_write_i) begin
                    if (valid_read&dirty_read) begin
                        cache_state <= CACHE_EVICT;
                        wb_adr_o <= {tag_read, cpu_set, {CACHE_LINE_SIZE_MULT_POW2{1'b0}}};
                        wb_cyc_o <= 1'b1;
                        wb_stb_o <= 1'b1;
                        wb_dat_o <= ram_data;
                        wb_sel_o <= 4'b1111;
                        wb_we_o <= 1'b1;
                    end else begin
                        cache_state <= CACHE_FILL;
                        wb_adr_o <= {cpu_addr_i[AW+1:2+CACHE_LINE_SIZE_MULT_POW2], {CACHE_LINE_SIZE_MULT_POW2{1'b0}}};
                        wb_cyc_o <= 1'b1;
                        wb_stb_o <= 1'b1;
                        wb_sel_o <= '0;
                        wb_we_o <= 1'b0;
                    end
                end
            end
            CACHE_WRITE: begin
                if (!wb_stall_i) begin
                    wb_stb_o <= 1'b0;
                end
                if (wb_ack_i) begin
                    wb_cyc_o <= 1'b0;
                    cache_state <= CACHE_IDLE;
                end
            end
            CACHE_FILL: begin
                if (!wb_stall_i) begin
                    if (!fill_pend_condition) begin
                        wb_stb_o <= 1'b1;
                        wb_adr_o <= wb_adr_o + 1;
                    end else begin
                        wb_stb_o <= 1'b0;
                    end
                end
                if (wb_ack_i&fill_end_condition) begin
                    tags[cpu_set] <= cpu_tag;
                    valid[cpu_set] <= 1'b1;
                    dirty[cpu_set] <= 1'b0;
                    wb_cyc_o <= 1'b0;
                    cache_state <= CACHE_IDLE;
                end
            end
            CACHE_EVICT: begin
                if (!wb_stall_i&!evict_pend_condition) begin
                    wb_adr_o <= wb_adr_o + 1;
                    wb_dat_o <= ram_data;
                end
                if (!wb_stall_i&evict_pend_condition) begin
                    wb_stb_o <= 1'b0;
                end
                if (wb_ack_i&evict_end_condition) begin
                    valid[cpu_set] <= 1'b0;
                    cache_state <= CACHE_FILL;
                    wb_adr_o <= {cpu_addr_i[AW+1:2+CACHE_LINE_SIZE_MULT_POW2], {CACHE_LINE_SIZE_MULT_POW2{1'b0}}};
                    wb_cyc_o <= 1'b1;
                    wb_stb_o <= 1'b1;
                    wb_sel_o <= '0;
                    wb_we_o <= 1'b0;
                end
            end
        endcase
    end
    
    for (genvar k = 0; k < 4; k++) begin : __ram_write
        always_ff @(posedge cpu_clock_i) begin
            if (cache_wr[k]) begin
                cache_ram[ram_wr_addr][((k+1)*8)-1:k*8] <= ram_wr_data[((k+1)*8)-1:k*8];
            end
        end
    end
endmodule
