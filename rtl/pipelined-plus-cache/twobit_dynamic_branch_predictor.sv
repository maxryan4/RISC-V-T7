module twobit_dynamic_branch_predictor #(
    parameter DATA_WIDTH = 32,
    parameter BTB_ROWS = 16     // number of rows in branch target buffer
) (
    input logic                     clk,
    input logic                     rst,
    input logic [DATA_WIDTH-1:0]    RD,     // current instructino
    input logic [DATA_WIDTH-1:0]    PC_f,

    input logic                     branch_actual_taken,    // checks if branch is actually taken
    input logic [DATA_WIDTH-1:0]    branch_actual_target,

    output logic                    predict_taken_f,
    output logic [DATA_WIDTH-1:0]   branch_target_f

);

    // this is the branch target buffer
    typedef struct packed {
        logic                   valid;  // valid = 0 if BTB entry ignored in lookup
        logic [DATA_WIDTH-1:0]  tag;    // stores upper bits of PC to check entry  is current PC
        logic [DATA_WIDTH-1:0]  target; // target PC when branch taken
        logic [1:0]             pred;   // 2 bit predictor counter: 11 = ST, 10 = WT, 01 = WN, 00 = SN
        logic                   uncond; // uncond = 1 if *unconditional* jump
    } BTB_cols;

    BTB_cols BTB [BTB_ROWS-1:0];        // array of BTB entries
    
    logic [3:0]             index_f;    // index for BTB lookup
    logic [DATA_WIDTH-1:0]  tag_f;      // tag for index collisions 

    //--------------------------------

    assign index = PC_f[5:2];           // used as index for BTB lookup
    assign tag = PC_f[DATA_WIDTH-1:6];

    always_comb begin
        predict_taken_f = 1'b0;           // default values
        branch_target_f = PC_f;           // default values

        if ((RD[6:0] == 7'b1100011) || (RD[6:0] == 7'b1101111)) begin            // check if instr is a jump
            if (BTB[index_f].valid && (BTB[index_f].tag == tag_f)) begin         // check if entry valid and tag matches
                if (BTB[index_f].uncond || (BTB[index_f].pred[1] == 1'b1)) begin // check if uncond or ST (11) or WT (10)  
                    predict_taken_f = 1'b1;                   // if unconditional inst or ST or WT then predict taken and branch  
                    branch_target_f = BTB[index_f].target;
                end
            end
        end
    end


    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int i = 0; i < BTB_ROWS; i++) begin
                BTB[i].valid <= 1'b0;       // set valid bit of all BTB entry to 0 if rst asserted
                BTB[i].pred  <= 2'b10;       // set pred to weakly taken
            end
        end

        // all this is to update BTB when we actually know if branch taken or not
        else begin
            logic [3:0] update_index = branch_actual_target[5:2];
                                    // if instr = cond. jump   or if instr = JAL uncond. jump
            if (branch_actual_taken || (RD[6:0] == 7'b1100011) || (RD[6:0] == 7'b1101111)) begin
                BTB[update_index].valid  <= 1'b1;       
                BTB[update_index].tag    <= branch_actual_target[DATA_WIDTH-1:6];   // update tag
                BTB[update_index].target <= branch_actual_target;                   // update target PC
                BTB[update_index].uncond   <= (RD[6:0] == 7'b1101111);              // JAL uncond. jump
            end

            // this updates 2 bit predictor
            if (branch_actual_taken) begin                  // if branch is actually taken
                if (BTB[update_index].pred < 2'b11) begin   // and pred not already ST (11), increment by 1
                    BTB[update_index].pred <= BTB[update_index].pred + 2'b01;
                end
            end else begin                                  // if branch is not actually taken
                if (BTB[update_index].pred > 2'b00) begin   // and pred not already SN (00), decrement by 1
                    BTB[update_index].pred <= BTB[update_index].pred - 2'b01;
                end
            end
        end
    end

endmodule
