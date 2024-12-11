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
        logic                   valid,
        logic [DATA_WIDTH-1:0]  tag,
        logic [DATA_WIDTH-1:0]  target,
        logic [1:0]             pred,
        logic                   type
    } BTB_cols;

    BTB_cols BTB [BTB_ROWS-1:0];        // array of BTB entries


endmodule