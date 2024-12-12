module pc_top #(
    DATA_WIDTH = 32
) (
    input   logic                   clk,
    input   logic                   rst,
    input   logic                   en_f,
    input   logic                   PCsrc,
    input   logic [DATA_WIDTH-1:0]  ImmOp,
    input   logic [DATA_WIDTH-1:0]  RS1,
    input   logic                   PCaddsrc,
    input   logic [DATA_WIDTH-1:0]  PC_e,
    output  logic [DATA_WIDTH-1:0]  PC,
    output  logic [DATA_WIDTH-1:0]  inc_PC,
    output  logic [DATA_WIDTH-1:0]  branch_target,      // branch prediction target             
    output  logic                   predict_taken       // branch prediction (1 = predict branch taken)
);

    // internal signals
    logic [DATA_WIDTH-1:0] branch_PC;
    // logic [DATA_WIDTH-1:0] inc_PC;
    logic [DATA_WIDTH-1:0] next_PCX;
    logic [DATA_WIDTH-1:0] next_PC;
    // instantiating modules

    mux mux_st (
        .in0(PC),
        .in1(next_PCX),
        .sel(en_f),
        .out(next_PC)
    );

    pc_reg pc_reg (
        .clk(clk),
        .rst(rst),
        .next_PC(next_PC),
        .PC(PC)
    );

    adder pc_inc (
        .in0(PC),
        .in1(32'd4),
        .out(inc_PC)
    );
    logic [DATA_WIDTH-1:0] PC_fin;
    mux mux3 (
      .in0(RS1),
      .in1(PC_e),
      .sel(PCaddsrc),
      .out(PC_fin)
    );
    adder pc_branch (
        .in0(PC_fin),
        .in1(ImmOp),
        .out(branch_PC)
    );

    mux pc_mux (
        .in0(branch_predict_PC),
        .in1(branch_PC),
        .sel(PCsrc),
        .out(next_PCX)
    );

    mux branch_predict_mux (
        .in0(inc_PC),
        .in1(branch_target),
        .sel(predict_taken),
        .out(branch_predict_PC)
    );

    
endmodule
