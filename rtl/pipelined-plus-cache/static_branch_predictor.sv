module static_branch_predictor #(
    DATA_WIDTH = 32
) (

    input logic Branch_d,                    
    input logic [DATA_WIDTH-1:0] PC_d,
    input logic [DATA_WIDTH-1:0] ImmExt_d,      // offset for branch from decode stage
    
    input logic Branch_e,                       
    input logic EQ,                             // EQ = 1 if branching
    input logic [DATA_WIDTH-1:0] PC_e,          // PC from execute stage
    input logic [DATA_WIDTH-1:0] ImmExt_e,      // offset for branch from execute stage
    input logic [DATA_WIDTH-1:0] PCPlus4_e,     // PCPlus4 from execute stage

    output logic predict_taken,                 // branch prediction (1 = predict branch taken)
    output logic [DATA_WIDTH-1:0] correct_PC    // actual PC if prediction is wrong
);

    logic [DATA_WIDTH-1:0] branch_target;       // target address of branch


    // STATIC BRANCH PREDICTION: TAKEN FOR BACKWARD BRANCH, NOT TAKEN FOR FORWARD
    always_comb begin
        branch_target = PC_d + ImmExt_d;             // compute branch target address

        if (Branch_d) begin     // if branch instruction
            predict_taken = (branch_target < PC_d) ? 1'b1 : 1'b0;   // if target address < PC it is backward branch
                                                                    // so assume branch IS TAKEN
        end else begin
            predict_taken = 1'b0;               // default for non-branch instr
        end
    end 

    // ACTUAL BRANCH OUTCOME
    assign correct_PC = (Branch_e && EQ) ? (PC_e + ImmExt_e) : PCPlus4_e;   // compute correct PC in case prediction wrong

endmodule