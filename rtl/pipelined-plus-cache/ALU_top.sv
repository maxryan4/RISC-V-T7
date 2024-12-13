module ALU_top #(
    DATA_WIDTH = 32
) (
    input logic clk,
    input logic [DATA_WIDTH-1:0] ALUop1,
    input logic [DATA_WIDTH-1:0] ALUop2,
    input logic [3:0] ALUctrl, // {func7[5],func3[2:0]}
    input logic mul_sel, // 1 if mul, 0 if ALU

    output logic [DATA_WIDTH-1:0] ALUout,
    output logic EQ, // 1 if branching
    output logic div_ready // 1 if division is ready
);

logic [DATA_WIDTH-1:0] ALU_result; // output from alu module
logic [DATA_WIDTH-1:0] mul_result; // result of multiplication
logic [DATA_WIDTH-1:0] div_result; // result of division
logic [DATA_WIDTH-1:0] M_result; // result of M type instruction
logic [DATA_WIDTH-1:0] quotient; // quotient from division
logic [DATA_WIDTH-1:0] remainder; // remainder from division

ALU ALU (
    .ALUop1(ALUop1),
    .ALUop2(ALUop2),
    .ALUctrl(ALUctrl),
    .ALUout(ALU_result),
    .EQ(EQ)
);

mul mul (
    .op1(ALUop1),
    .op2(ALUop2),
    .mul_ctrl(ALUctrl[1:0]),
    .result(mul_result)
);

div_mc div_mc (
    .clk(clk),
    .start(ALUctrl[2]), // MSB of func3 determines if it is a div or not
    .dividend(ALUop1),
    .divisor(ALUop2),
    .signed_op(ALUctrl[0]), // func3[0] determines if it is a signed division (1 if signed, 0 if not signed)
    .quotient(quotient),
    .remainder(remainder),
    .ready(div_ready) // 1 if division is ready
);

mux div_or_rem(
    .in0(quotient),
    .in1(remainder),
    .sel(ALUctrl[1]), // func3[1] determines if it is a div or rem instruction
    .out(div_result)
);

mux mul_or_div (
    .in0(mul_result),
    .in1(div_result),
    .sel(ALUctrl[2]), // MSB of func3 determines if it is a mul or div instruction
    .out(M_result)
);

mux ALU_or_M ( // select between ALU and M type
    .in0(ALU_result),
    .in1(M_result),
    .sel(mul_sel),
    .out(ALUout)
);

endmodule
