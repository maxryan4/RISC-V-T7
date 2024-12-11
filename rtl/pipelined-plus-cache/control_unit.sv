module control_unit (
    input wire [31:0] instr,
    output logic RegWrite,
    output logic [3:0] ALUctrl,
    output logic ALUsrc,
    output logic [2:0] ImmSrc,
    output logic Branch,
    output logic Jump,
    output logic [1:0] destsrc,//resultscr
    output logic [2:0] memCtrl,
    output logic MemWrite,
    output logic UI_control,
    output logic RD1_control,
    output logic PC_RD1_control,
    output logic four_imm_control
);
    always_comb begin
        if (instr[6:0]==7'b1101111 ||instr[6:0]==7'b1100111) begin
            four_imm_control=0;
        end else begin
            four_imm_control=1;
        end
        if (instr[6:0]==7'b0110111) begin
            UI_control=0;
        end else begin
            UI_control=1;
        end
        if (instr[6:0]==7'b0110111||instr[6:0]==7'b0010111||instr[6:0]==7'b1101111 ||instr[6:0]==7'b1100111) begin
            RD1_control=0;
        end else begin
            RD1_control=1;
        end
        if (instr[6:0]==7'b1100111 ) begin
            PC_RD1_control=0;
        end else begin
            PC_RD1_control=1;
        end
        memCtrl = instr[14:12];
        case(instr[6:0])
            7'b0110011:begin//not imme
                RegWrite=1;
                ALUctrl={instr[30],instr[14:12]};
                ALUsrc=0;
                ImmSrc=0;
                Branch=0;
                Jump=0;
                destsrc=0;
                MemWrite=0;
            end
            7'b0010011:begin//imme
                RegWrite=1;
                ALUctrl={1'b0,instr[14:12]};
                // in the unique case of srai, the MSB is non zero.
                if (instr[14:12] == 3'b101) begin
                    ALUctrl[3] = instr[30];
                end
                ALUsrc=1;
                ImmSrc=0;
                Branch=0;
                Jump=0;
                destsrc=0;
                MemWrite=0;
            end
            7'b0000011:begin// Loads
                RegWrite=1;
                ALUctrl=0;
                ALUsrc=1;
                ImmSrc=0;
                Branch=0;
                Jump=0;
                destsrc=1;
                MemWrite=0;
            end
            7'b1100011:begin//BEQ
                RegWrite=0;
                ALUctrl={1'b0,instr[14:12]};
                ALUsrc=0;
                ImmSrc=1;
                Branch=1;
                Jump=0;
                destsrc=0;
                MemWrite=0;
            end
            7'b0100011:begin//SW
                RegWrite=0;
                ALUctrl=0;
                ALUsrc=1;
                ImmSrc=2;
                Branch=0;
                Jump=0;
                destsrc=0;
                MemWrite=1;
            end
            7'b0110111:begin//LUI
                RegWrite=1;
                ALUctrl=0;
                ALUsrc=1;
                ImmSrc=3;
                Branch=0;
                Jump=0;
                destsrc=0;
                MemWrite=0;
            end
            7'b0010111 :begin//AUIPC
                RegWrite=1;
                ALUctrl=0;
                ALUsrc=1;
                ImmSrc=3;
                Branch=0;
                Jump=0;
                destsrc=0;
                MemWrite=0;
            end
            7'b1101111  :begin//JAL
                RegWrite=1;
                ALUctrl=0;
                ALUsrc=1;
                ImmSrc=4;
                Branch=0;
                Jump=1;
                destsrc=3; // changed from 0 to 3 so we can write PC+4 to register
                MemWrite=0;
            end
            7'b1100111 :begin//JALR
                RegWrite=1;
                ALUctrl=0;
                ALUsrc=1;
                ImmSrc=0;
                Branch=0;
                Jump=1;
                destsrc=3; // changed from 0 to 3 so we can write PC+4 to register
                MemWrite=0;
            end                        
            default: begin
                RegWrite=0;
                ALUctrl=0;
                ALUsrc=0;
                ImmSrc=0;
                Branch=0;
                Jump=0;
                destsrc=0;
                MemWrite=0;
            end
        endcase
    end

endmodule

