module ALU #(
    DATA_WIDTH = 32
) (
    input logic [DATA_WIDTH-1:0] ALUop1,
    input logic [DATA_WIDTH-1:0] ALUop2,
    input logic [3:0] ALUctrl, // {func7[5],func3[2:0]}
    output logic [DATA_WIDTH-1:0] ALUout,
    //output logic N;
    //output logic Z;
    //output logic C;
    //output logic V;
);

    always_comb begin
        case (ALUctrl)
            // add
            4'b?000: ALUout = ALUop1 + ALUop2;

            // sub
            4'b1000: ALUout = ALUop1 - ALUop2;

            // and
            4'b?111: ALUout = ALUop1 & ALUop2;

            // or
            4'b?110: ALUout = ALUop1 | ALUop2;

            // xor
            4'b?100: ALUout = ALUop1 ^ ALUop2;

            // SLL
            4'b?001: ALUout = ALUop1 << ALUop2[4:0];

            // SRL
            4'b?100: ALUout = ALUop1 >> ALUop2[4:0];

            // SRA
            4'b1101: ALUout = $signed(ALUop1) >>> ALUop2[4:0];

            // SLT (set less than)
            4'b?010: ALUout = $signed(ALUop1) < $signed(ALUop2) ? 32'b1 : 32'b0;

            // SLTU (set less than unsigned)
            4'b?011: ALUout = ALUop1 < ALUop2 ? 32'b1 : 32'b0;

            default: ALUout = 32'b0;
        endcase
    end
endmodule
