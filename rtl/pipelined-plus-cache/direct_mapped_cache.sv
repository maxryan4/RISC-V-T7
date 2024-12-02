module direct_mapped_cache #(
    parameter SETS = 16,
    parameter CACHE_LINE_SIZE_MULT_POW2 = 0,
    parameter AW = 12,
    parameter SYNC_RAM = 1,
    localparam SL = 4,
    localparam RAM_SZ = (SETS*(2**CACHE_LINE_SIZE_MULT_POW2)),
    localparam TAG_W = AW-$clog2(SETS)-CACHE_LINE_SIZE_MULT_POW2
) (
    input   wire logic              cpu_clock_i,
    input   wire logic              cpu_reset_i,

    // CPU interface in (note does not include bottom two bits of address)
    input   wire logic [AW+1:0]     cpu_addr_i,
    input   wire logic [31:0]       cpu_data_i,
    input   wire logic [2:0]        cpu_mem_ctrl_i,
    input   wire logic              cpu_mem_write_i,
    input   wire logic              cpu_valid_i,
    // Backing memory in
    input   wire logic              wb_stall_i,
    input   wire logic              wb_ack_i,
    input   wire logic [31:0]       wb_dat_i,
    input   wire logic              wb_err_i,
    // CPU interface out
    output       logic [31:0]       cpu_data_o,
    output       logic              cpu_stall_o,
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
    typedef enum { IDLE, CACHE_WRITE, CACHE_FILL } cache_state_t;
    cache_state_t   cache_state;
    wire cache_fill;
    wire [3:0] cache_wr;
    wire [3:0] cpu_cache_wr;
    wire [31:0]                  ram_wr_data;
    logic [31:0]                 ram_data;
    wire  [$clog2(RAM_SZ)-1:0]   ram_addr;
    wire  [$clog2(SETS)-1:0]     cpu_set;
    wire  [TAG_W-1:0]            cpu_tag;
    wire  [TAG_W-1:0]            tag_read;
    wire                         valid_read;
    wire                         cpu_match;
    initial begin
        for (integer i = 0; i < RAM_SZ; i++) begin
            cache_ram[i] = '0;
        end
        for (integer i = 0; i < SETS; i++) begin
            tags[i] = '0; valid[i] = '0;
        end 
    end

    assign cpu_set = cpu_addr_i[$clog2(SETS)+CACHE_LINE_SIZE_MULT_POW2+1:CACHE_LINE_SIZE_MULT_POW2+2];
    assign cpu_tag = cpu_addr_i[AW+1:$clog2(SETS)+CACHE_LINE_SIZE_MULT_POW2+2];
    
    assign tag_read = tags[cpu_set];
    assign valid_read = valid[cpu_set];

    assign cpu_match = valid_read&&(tag_read==cpu_tag);
    assign cpu_stall_o = cpu_valid_i&&((cpu_mem_write_i&!wb_ack_i)||(!cpu_match&!cpu_mem_write_i));
    
    generate if (CACHE_LINE_SIZE_MULT_POW2==0) begin : __if_no_spatial
        assign ram_addr = cpu_set;
    end else begin : __if_spatial
        assign ram_addr = {cpu_set, cpu_addr_i[CACHE_LINE_SIZE_MULT_POW2+1:2]};
    end endgenerate
    assign ram_data = cache_ram[ram_addr];

    assign cpu_data_o = ram_data;

    store_format sf0 (cpu_data_i, cpu_addr_i[1:0], cpu_mem_ctrl_i[1:0], ram_wr_data, cache_wr);
    always_ff @(posedge cpu_clock_i) begin
        case (cache_state)
            IDLE: begin
                if (cpu_stall_o&cpu_mem_write_i) begin
                    cache_state <= CACHE_WRITE;
                    wb_adr_o <= cpu_addr_i[AW+1:2];
                    wb_cyc_o <= 1'b1;
                    wb_stb_o <= 1'b1;
                    wb_dat_o <= ram_wr_data;
                    wb_sel_o <= cache_wr;
                end else if (cpu_stall_o&!cpu_mem_write_i) begin
                    
                end
            end
        endcase
    end
    
endmodule
