module control_unit (
    input wire EQ,
    input wire [31:0] instr,
    output logic RegWrite,
    output logic [3:0] ALUctrl,
    output logic ALUsrc,
    output logic [2:0] ImmSrc,
    output logic PCsrc,
    output logic destsrc
);
    always_comb begin
        
        case(instr[6:0])
            7'b0010011:begin//ADDI
                RegWrite=1;
                ALUctrl=4'b0000;
                ALUsrc=1;
                ImmSrc=0;
                PCsrc=0;
                destsrc=0;
            end
            7'b0000011:begin// Loads
                RegWrite=1;
                ALUctrl=0;
                ALUsrc=1;
                ImmSrc=0;
                PCsrc=0;
                destsrc=1;
            end
            7'b1100011:begin//BEQ
                RegWrite=0;
                ALUctrl=0;
                ALUsrc=0;
                ImmSrc=1;
                PCsrc=EQ;
                destsrc=0;
            end
            default: begin
                RegWrite=0;
                ALUctrl=0;
                ALUsrc=0;
                ImmSrc=0;
                PCsrc=0;
                destsrc=0;
            end
        endcase
    end

endmodule
