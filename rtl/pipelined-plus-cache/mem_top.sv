module mem_top #(
    parameter AW = 18, 
    parameter SETS = 32,
    parameter CACHE_LINE_SIZE_MULT_POW2 = 1,
    parameter FILE_LOAD = 1,
    parameter FILE = "../rtl/memory/gaussian.mem"
) (
    input   wire logic              cpu_clock_i,

    // CPU interface in (note does not include bottom two bits of address)
    input   wire logic [AW+1:0]     cpu_addr_i,
    input   wire logic [31:0]       cpu_data_i,
    input   wire logic [2:0]        cpu_mem_ctrl_i,
    input   wire logic              cpu_mem_write_i,
    input   wire logic              cpu_valid_i,
    // CPU interface out
    output       logic [31:0]       cpu_data_o,
    output       logic              cpu_en_o
);
wire logic              wb_stall_i;
wire logic              wb_ack_i;
wire logic [31:0]       wb_dat_i;
wire logic              wb_err_i;
wire logic              wb_cyc_o;
wire logic              wb_stb_o;
wire logic              wb_we_o;
wire logic [AW-1:0]     wb_adr_o;
wire logic [31:0]       wb_dat_o;
wire logic [3:0]        wb_sel_o;
    two_way_set_assoc_cache_wb #(SETS, CACHE_LINE_SIZE_MULT_POW2, AW) cache0 (cpu_clock_i,
    cpu_addr_i,
    cpu_data_i,
    cpu_mem_ctrl_i,
    cpu_mem_write_i,
    cpu_valid_i,
    wb_stall_i,
    wb_ack_i,
    wb_dat_i,
    wb_err_i,
    cpu_data_o,
    cpu_en_o,
    wb_cyc_o,
    wb_stb_o,
    wb_we_o,
    wb_adr_o,
    wb_dat_o,
    wb_sel_o);

    wb_mem #(AW, 32, FILE_LOAD, FILE) memory (cpu_clock_i, 1'b0, wb_cyc_o, wb_stb_o, wb_we_o, wb_adr_o, wb_dat_o, wb_sel_o, wb_stall_i, wb_ack_i, wb_dat_i, wb_err_i);

endmodule
