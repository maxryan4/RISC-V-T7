module two_way_set_assoc_cache_wt #(
    parameter SETS = 64,
    parameter CACHE_LINE_SIZE_MULT_POW2 = 2,
    parameter AW = 12,
    localparam SL = 4,
    localparam RAM_SZ = (2*SETS*(2**CACHE_LINE_SIZE_MULT_POW2)),
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
    reg [TAG_W-1:0] tags0[0:SETS-1];
    reg [TAG_W-1:0] tags1[0:SETS-1];
    reg             valid0[0:SETS-1];
    reg             valid1[0:SETS-1];
    reg             mru[0:SETS-1];
    typedef enum { CACHE_IDLE, CACHE_WRITE, CACHE_FILL } cache_state_t;
    cache_state_t   cache_state;
    wire                         cache_fill;
    wire  [3:0]                  cache_wr;
    wire  [3:0]                  cpu_cache_wr;
    wire                         fill_end_condition;
    wire                         fill_pend_condition;
    wire  [31:0]                 cpu_wr_data;
    wire  [31:0]                 ram_wr_data;
    logic [31:0]                 ram_data;
    wire  [$clog2(RAM_SZ)-1:0]   ram_rd_addr;
    wire  [$clog2(SETS)-1:0]     cpu_set;
    wire  [TAG_W-1:0]            cpu_tag;
    wire  [TAG_W-1:0]            tag0_read;
    wire                         valid0_read;
    wire  [TAG_W-1:0]            tag1_read;
    wire                         valid1_read;
    wire  [1:0]                  cpu_match;
    wire  [$clog2(RAM_SZ)-1:0]   fill_addr;
    wire  [$clog2(RAM_SZ)-1:0]   ram_wr_addr;
    wire                         replacement_enc;
    assign ram_wr_data = cache_fill ? wb_dat_i : cpu_wr_data;
    assign cache_wr = cache_fill ? {4{wb_ack_i&!wb_err_i}} : {cpu_cache_wr&{4{wb_ack_i&!wb_err_i}}};
    assign cache_fill = cache_state==CACHE_FILL;
    assign ram_wr_addr = cache_fill ? fill_addr : ram_rd_addr;
    initial begin
        for (integer i = 0; i < RAM_SZ; i++) begin
            cache_ram[i] = '0;
        end
        for (integer i = 0; i < SETS; i++) begin
            tags0[i] = '0; valid0[i] = '0;
            tags1[i] = '0; valid1[i] = '0;
        end 
    end

    assign cpu_set = cpu_addr_i[$clog2(SETS)+CACHE_LINE_SIZE_MULT_POW2+1:CACHE_LINE_SIZE_MULT_POW2+2];
    assign cpu_tag = cpu_addr_i[AW+1:$clog2(SETS)+CACHE_LINE_SIZE_MULT_POW2+2];
    
    assign tag0_read = tags0[cpu_set];
    assign valid0_read = valid0[cpu_set];

    assign tag1_read = tags1[cpu_set];
    assign valid1_read = valid1[cpu_set];

    assign cpu_match[0] = valid0_read&&(tag0_read==cpu_tag);
    assign cpu_match[1] = valid1_read&&(tag1_read==cpu_tag);
    assign cpu_stall_o = cpu_valid_i&&((cpu_mem_write_i&!wb_ack_i)||(~(|cpu_match)&!cpu_mem_write_i));
    
    assign replacement_enc = valid1_read&valid0_read ? ~mru[cpu_set] : valid1_read ? 1'b0 : 1'b1;
    
    generate if (CACHE_LINE_SIZE_MULT_POW2==0) begin : __if_no_spatial
        assign ram_rd_addr = {cpu_match[1], cpu_set};
    end else begin : __if_spatial
        assign ram_rd_addr = {cpu_match[1], cpu_set, cpu_addr_i[CACHE_LINE_SIZE_MULT_POW2+1:2]};
    end endgenerate

    assign ram_data = cache_ram[ram_rd_addr];
    load_format lf0 (ram_data, cpu_addr_i[1:0], cpu_mem_ctrl_i, cpu_data_o);
    store_format sf0 (cpu_data_i, cpu_addr_i[1:0], cpu_mem_ctrl_i[1:0], cpu_wr_data, cpu_cache_wr);

    
    generate if (CACHE_LINE_SIZE_MULT_POW2==0) begin : ___if_no_spatial
        assign fill_end_condition = 1'b1;
        assign fill_addr = {replacement_enc,cpu_set};
        assign fill_pend_condition = 1'b1;
    end else begin : ___if_spatial
        reg [CACHE_LINE_SIZE_MULT_POW2-1:0] counter = '0;
        always_ff @(posedge cpu_clock_i) begin
            if ((cache_state==CACHE_FILL)&&wb_ack_i) begin
                counter <= counter + 1;
            end
        end
        assign fill_end_condition = counter == {CACHE_LINE_SIZE_MULT_POW2{1'b1}};
        assign fill_addr = {replacement_enc, cpu_set, counter};
        assign fill_pend_condition = wb_adr_o[CACHE_LINE_SIZE_MULT_POW2-1:0]=={CACHE_LINE_SIZE_MULT_POW2{1'b1}};
    end endgenerate

    always_ff @(posedge cpu_clock_i) begin
        case (cache_state)
            CACHE_IDLE: begin
                if (cpu_stall_o&cpu_mem_write_i) begin
                    cache_state <= CACHE_WRITE;
                    wb_adr_o <= cpu_addr_i[AW+1:2];
                    wb_cyc_o <= 1'b1;
                    wb_stb_o <= 1'b1;
                    wb_dat_o <= cpu_wr_data;
                    wb_sel_o <= cache_wr;
                    wb_we_o <= 1'b1;
                end else if (cpu_stall_o&!cpu_mem_write_i) begin
                    cache_state <= CACHE_FILL;
                    wb_adr_o <= {cpu_addr_i[AW+1:2+CACHE_LINE_SIZE_MULT_POW2], {CACHE_LINE_SIZE_MULT_POW2{1'b0}}};
                    wb_cyc_o <= 1'b1;
                    wb_stb_o <= 1'b1;
                    wb_sel_o <= '0;
                    wb_we_o <= 1'b0;
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
                    if (replacement_enc) begin
                        tags1[cpu_set] <= cpu_tag;
                        valid1[cpu_set] <= 1'b1;
                    end else begin
                        tags0[cpu_set] <= cpu_tag;
                        valid0[cpu_set] <= 1'b1;
                    end
                    wb_cyc_o <= 1'b0;
                    cache_state <= CACHE_IDLE;
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
        endcase
    end
    
    always_ff @(posedge cpu_clock_i) begin
        case (cache_state)
            CACHE_IDLE: begin
                if (!cpu_stall_o&cpu_valid_i&!cpu_mem_write_i) begin
                    mru[cpu_set] <= cpu_match[1];
                end
            end
            default: begin
                
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
