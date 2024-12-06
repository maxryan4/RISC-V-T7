module execute_reg_file #(
    parameter 
    DATA_WIDTH = 32,
    READ_DATA_WIDTH = 5,
    SRC_WIDTH = 2,
    MEM_CTRL_WIDTH = 3
)(
    input logic                         clk,
    input logic                         rst_n, // flush active low
    input logic                         en, // stall (if set low will stall)
    input logic                         valid_e, // valid for execute

    input logic [DATA_WIDTH-1:0]        PCPlus4_e,
    input logic [DATA_WIDTH-1:0]        ALUResult_e,
    input logic [DATA_WIDTH-1:0]        WriteData_e,
    input logic [READ_DATA_WIDTH-1:0]   Rd_e,

    input logic                         RegWrite_e,
    input logic [SRC_WIDTH - 1:0]       ResultSrc_e,    
    input logic                         MemWrite_e,
    input logic [MEM_CTRL_WIDTH-1:0]    MemCtrl_e,

    output logic                       valid_m,

    output logic [DATA_WIDTH-1:0]       PCPlus4_m,
    output logic [DATA_WIDTH-1:0]       ALUResult_m,
    output logic [DATA_WIDTH-1:0]       WriteData_m,
    output logic [READ_DATA_WIDTH-1:0]  Rd_m,

    output logic                        RegWrite_m,
    output logic [SRC_WIDTH - 1:0]      ResultSrc_m,
    output logic                        MemWrite_m,
    output logic [MEM_CTRL_WIDTH-1:0]   MemCtrl_m
);

always_ff @(posedge clk) begin
    if (rst_n) begin
        if (en && valid_e) begin
            PCPlus4_m <= PCPlus4_e;
            ALUResult_m <= ALUResult_e;
            WriteData_m <= WriteData_e;
            Rd_m <= Rd_e;

            RegWrite_m <= RegWrite_e;
            ResultSrc_m <= ResultSrc_e;
            MemWrite_m <= MemWrite_e;
            MemCtrl_m <= MemCtrl_e;
        end
        valid_m <= valid_e;
    end
    else begin
        PCPlus4_m <= 32'b0;
        ALUResult_m <= 32'b0;
        WriteData_m <= 32'b0;
        Rd_m <= 5'b0;
        
        RegWrite_m <= 1'b0;
        ResultSrc_m <= 2'b0;
        MemWrite_m <= 1'b0;
        MemCtrl_m <= 3'b0;
    end
end

endmodule
