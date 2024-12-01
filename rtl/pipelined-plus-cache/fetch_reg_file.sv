// need to add way to flush 
module fetch_reg_file #(
    parameter DATA_WIDTH = 32
)(
    input logic                         clk,
    input logic [DATA_WIDTH-1:0]        read_data_f,
    input logic [DATA_WIDTH-1:0]        PC_f,
    input logic [DATA_WIDTH-1:0]        PCPlus4_f,

    output logic [DATA_WIDTH-1:0]       read_data_d,
    output logic [DATA_WIDTH-1:0]       PC_d,
    output logic [DATA_WIDTH-1:0]       PCPlus4_d
);

always_ff @(posedge clk) begin
    read_data_d <= read_data_f;
    PC_d <= PC_f;
    PCPlus4_d <= PCPlus4_f;
end

endmodule
