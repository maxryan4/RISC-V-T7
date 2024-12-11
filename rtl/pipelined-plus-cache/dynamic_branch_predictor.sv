module dynamic_branch_predictor #(
    parameter DATA_WIDTH = 32,
    parameter BTB_ROWS = 16     // number of rows in branch target buffer
) (
    input logic                     clk,
    input logic                     rst,
    input logic [DATA_WIDTH-1:0]    RD,     // current instructino
    input logic [DATA_WIDTH-1:0]    PC_f
);

    // this is the branch target buffer
    typedef struct packed {
        logic                   valid,  // valid = 0 if BTB entry ignored in lookup
        logic [DATA_WIDTH-1:0]  tag,    // stores upper bits of PC to check entry  is current PC
        logic [DATA_WIDTH-1:0]  target, // target PC when branch taken
        logic [1:0]             pred,   // 2 bit predictor counter: 11 = ST, 10 = WT, 01 = WN, 00 = SN
        logic                   type    // type = 1 if *unconditional* jump
    } BTB_cols;

    BTB_cols BTB [BTB_ROWS-1:0];        // array of BTB entries
    
    logic [3:0]             index_f;    // index for BTB lookup
    logic [DATA_WIDTH-1:0]  tag_f;      // tag for index collisions 

    //--------------------------------

    assign index = PC_f[5:2]            // used as index for BTB lookup
    assign tag = PC_f[DATA_WIDTH-1:6]

    always_comb begin
        predict_taken = 1'b0;           // default values
        branch_target = PC_f;           // default values

        if (BTB[index_f].valid && (BTB[index_f].tag == tag_f)) begin        // check if entry valid and tag matches
            if (BTB[index_f].type || (BTB[index_f].pred[1] == 1'b1)) begin  // check if uncond or ST (11) or WT (10)  
                predict_taken = 1'b1;                   // if unconditional inst or ST or WT then predict taken and branch  
                branch_target = BTB[index_f].target;
            end
        end
    end

    always_ff @(posedge clk or negedge rst) begin

        if (rst) begin
            for (int i = 0; i < BTB_ROWS; i++) begin
                BTB[i].valid <= 1'b0;       // set valid bit of all BTB entry to 0 if rst asserted
            end
        end

        else begin
            
        
        end

    end


endmodule