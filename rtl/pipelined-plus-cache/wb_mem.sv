module wb_mem #(parameter WB_AW = 12, parameter WB_DW = 32, parameter FILE_LOAD = 0, parameter FILE = "", localparam WB_SL = WB_DW/8) (
    input   wire logic              clk_i,
    input   wire logic              rst_i,

    input   wire logic              wb_cyc_i,
    input   wire logic              wb_stb_i,
    input   wire logic              wb_we_i,
    input   wire logic [WB_AW-1:0]  wb_adr_i,
    input   wire logic [WB_DW-1:0]  wb_dat_i,
    input   wire logic [WB_SL-1:0]  wb_sel_i,

    output       logic              wb_stall_o,
    output       logic              wb_ack_o,
    output       logic [WB_DW-1:0]  wb_dat_o,
    output       logic              wb_err_o
);
    reg [WB_DW-1:0] RAM[0:(2**WB_AW)-1];

    initial begin
        if (FILE_LOAD) begin
            $readmemh(FILE, RAM);
        end else begin
            for (integer i = 0; i < 2**WB_AW; i++) begin
                RAM[i] = '0;
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            wb_ack_o <= '0;
            wb_err_o <= '0;
            wb_stall_o <= '0;
        end else if (wb_cyc_i&wb_stb_i) begin
            wb_ack_o <= '1;
            wb_err_o <= '0;
            wb_stall_o <= '0;
            if (!wb_we_i) begin
                wb_dat_o <= RAM[wb_adr_i];
            end
        end else begin
            wb_ack_o <= '0;
            wb_err_o <= '0;
            wb_stall_o <= '0;
        end
    end
for (genvar i = 0; i < WB_SL; i++) begin : _write_ram_per_bitmask
    always_ff @(posedge clk_i) begin
        if (wb_cyc_i&wb_stb_i&wb_sel_i[i]) begin
            RAM[wb_adr_i][8*(i+1)-1:8*i] <= wb_dat_i[8*(i+1)-1:8*i];
        end
    end
end
endmodule
