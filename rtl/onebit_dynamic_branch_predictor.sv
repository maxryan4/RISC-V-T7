module onebit_dynamic_branch_predictor #(
    parameter DATA_WIDTH = 32,
    parameter BTB_ROWS = 16     // number of rows in branch target buffer
) (
    input logic                     clk,
    input logic [DATA_WIDTH-1:0]    RD_f,     // current instructino
    input logic [DATA_WIDTH-1:0]    PC_f,

    input logic                     mispredict,
    input logic                     branch_actual_taken,    // checks if branch is actually taken
    input logic [DATA_WIDTH-1:0]    branch_actual_target,
    input logic                     type_j,
    input logic [DATA_WIDTH-1:0]    branch_pc,

    output logic                    predict_taken_f,
    output logic [DATA_WIDTH-1:0]   branch_target_f

);

    // this is the branch target buffer
    typedef struct packed {
        logic                   valid;  // valid = 0 if BTB entry ignored in lookup
        logic [DATA_WIDTH-7:0]  tag;    // stores upper bits of PC to check entry  is current PC
        logic [DATA_WIDTH-1:0]  target; // target PC when branch taken
        logic                   pred;   // 1 bit predictor counter: T (taken: 1), N (not taken: 0)
        logic                   uncond; // uncond = 1 if *unconditional* jump
    } BTB_cols;

    BTB_cols BTB [BTB_ROWS-1:0];        // array of BTB entries
    
    logic [3:0]             index_f;    // index for BTB lookup
    logic [DATA_WIDTH-7:0]  tag_f;      // tag for index collisions 

    //--------------------------------

    assign index_f = PC_f[5:2];           // used as index for BTB lookup
    assign tag_f = PC_f[DATA_WIDTH-1:6];

    always_comb begin
        predict_taken_f = 1'b0;           // default values
        branch_target_f = '0;           // default values

        if ((RD_f[6:0] == 7'b1100011) || (RD_f[6:0] == 7'b1101111)) begin           // check if instr is a jump
            if (BTB[index_f].valid && (BTB[index_f].tag == tag_f)) begin        // check if entry valid and tag matches
                if (BTB[index_f].uncond || (BTB[index_f].pred == 1'b1)) begin   // check if uncond or taken (1)
                    predict_taken_f = 1'b1;                   // if unconditional inst or ST or WT then predict taken and branch  
                    branch_target_f = BTB[index_f].target;
                end
            end
        end
    end

    initial begin
        for (int i = 0; i < BTB_ROWS; i++) begin
            BTB[i].valid = 1'b0;       // set valid bit of all BTB entry to 0
            BTB[i].pred  = 1'b0;       // assume not taken
        end
    end

    logic [3:0] update_index = branch_pc[5:2];
    logic [DATA_WIDTH-7:0] tag = branch_pc[DATA_WIDTH-1:6];

    always_ff @(posedge clk) begin
    // if instr = cond. jump   or if instr = JAL uncond. jump
      if (mispredict) begin
          BTB[update_index].valid  <= 1'b1;       
          BTB[update_index].tag    <= tag;   // update tag
          BTB[update_index].target <= branch_actual_target;                   // update target PC
          BTB[update_index].uncond   <= type_j;              // JAL uncond. jump
          BTB[update_index].pred <= branch_actual_taken;
      end
    end

endmodule
