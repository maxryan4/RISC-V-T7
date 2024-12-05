module mem_reg_file #(
    parameter DATA_WIDTH = 32
)(
    input logic                         clk,
    input logic                         rst_n, // flush active low
    input logic                         en, // stall (if set low will stall)

    input logic [DATA_WIDTH-1:0]        PCPlus4_m,
    input logic [DATA_WIDTH-1:0]        ALUResult_m,
    input logic [DATA_WIDTH-1:0]        ReadData_m,
    input logic                         RegWrite_m,
    input logic [1:0]                   ResultSrc_m,

    output logic [DATA_WIDTH-1:0]       PCPlus4_w,
    output logic [DATA_WIDTH-1:0]       ALUResult_w,
    output logic [DATA_WIDTH-1:0]       ReadData_w,
    output logic                        RegWrite_w,
    output logic [1:0]                  ResultSrc_w
);

always_ff @(posedge clk or negedge rst_n) begin
    if (rst_n) begin
        if(en) begin
            PCPlus4_w <= PCPlus4_m;
            ALUResult_w <= ALUResult_m;
            ReadData_w <= ReadData_m;
            RegWrite_w <= RegWrite_m;
            ResultSrc_w <= ResultSrc_m;
        end
    end
    else begin
        PCPlus4_w <= 32'b0;
        ALUResult_w <= 32'b0;
        ReadData_w <= 32'b0;
        RegWrite_w <= 1'b0;
        ResultSrc_w <= 2'b00;
    end
end

endmodule
