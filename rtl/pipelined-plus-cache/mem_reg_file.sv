// not finished
module mem_reg_file #(
    parameter DATA_WIDTH = 32
)(
    input logic                         clk,
    input logic [DATA_WIDTH-1:0]        PCPlus4_m,
    input logic [DATA_WIDTH-1:0]        ALUResult_m,
    input logic [DATA_WIDTH-1:0]        ReadData_m,
    input logic                         RegWrite_m,
    input logic [1:0]                   ResultSrc_m,

    output logic [DATA_WIDTH-1:0]       PCPlus4_w,
    output logic [DATA_WIDTH-1:0]       ALUResult_w,
    output logic [DATA_WIDTH-1:0]       ReadData_w,
    output logic                        RegWrite_w,
    output logic [1:0]                  ResultSrc_w,

);

always_ff @(posedge clk) begin
    PCPlus4_w <= PCPlus4_m;
    ALUResult_w <= ALUResult_m;
    ReadData_w <= ReadData_m;
    RegWrite_w <= RegWrite_m;
    ResultSrc_w <= ResultSrc_m;
end

endmodule
