module static_branch_predictor #(
    DATA_WIDTH = 32
) (

    input logic [DATA_WIDTH-1:0] RD,
    input logic [DATA_WIDTH-1:0] PC_f,  
    output logic [DATA_WIDTH-1:0] branch_target,                 
    output logic predict_taken                      // branch prediction (1 = predict branch taken)

);

    logic [DATA_WIDTH-1:0] branch_target;           // target address of branch

    always_comb begin
        case (instr[6:0])
            // Branche Instructions
            7'b1100011: branch_target = PC_f + {{20{RD[31]}},RD[7],RD[30:25],RD[11:8],1'b0};
            
            // JAL
            7'b1101111: branch_target = PC_f + {{12{RD[31]}},RD[19:12],RD[20],RD[30:21],1'b0};

            // no case for JALR as we don't have RS1 in fetch stage yet

        endcase
        
        if (RD[6:0] == 7'b1100011) begin            // if branch instruction
            predict_taken = (branch_target < PC_f) ? 1'b1 : 1'b0;
        end else begin
            predict_taken = 1'b0;
        end
    end

endmodule
