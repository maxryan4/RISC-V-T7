module ALU_top #(
    DATA_WIDTH = 32
) (
    input logic [DATA_WIDTH-1:0] ALUop1,
    input logic [DATA_WIDTH-1:0] ALUop2,
    input logic [3:0] ALUctrl, // {func7[5],func3[2:0]}
    input logic mul_sel, // 1 if mul, 0 if ALU

    output logic [DATA_WIDTH-1:0] ALUout,
    output logic EQ // 1 if branching
);

logic [DATA_WIDTH-1:0] ALU_result;
logic [DATA_WIDTH-1:0] mul_result;

ALU ALU (
    .ALUop1(ALUop1),
    .ALUop2(ALUop2),
    .ALUctrl(ALUctrl),
    .ALUout(ALU_result),
    .EQ(EQ)
);

mul mul (
    .a(ALUop1),
    .b(ALUop2),
    .mul_ctrl(ALUctrl[1:0]),
    .result(mul_result)
);

mux ALU_or_mul (
    .in0(ALU_result),
    .in1(mul_result),
    .sel(mul_sel),
    .out(ALUout)
);

endmodule
