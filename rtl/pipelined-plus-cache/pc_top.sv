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
    input   logic [DATA_WIDTH-1:0]  instr_f,
    input   logic                   branch_actual_taken,    // checks if branch is actually taken
    input   logic                   type_j,
    input   logic [DATA_WIDTH-1:0]  PC_P4,
    output  logic [DATA_WIDTH-1:0]  PC,
    output  logic [DATA_WIDTH-1:0]  inc_PC,
    output  logic [DATA_WIDTH-1:0]  branch_target,      // branch prediction target             
    output  logic                   predict_taken,       // branch prediction (1 = predict branch taken)
    output  logic [DATA_WIDTH-1:0]  branch_pc_e
);

    // internal signals
    logic [DATA_WIDTH-1:0] branch_PC;
    // logic [DATA_WIDTH-1:0] inc_PC;
    logic [DATA_WIDTH-1:0] next_PCX;
    logic [DATA_WIDTH-1:0] next_PC;
    logic [DATA_WIDTH-1:0] branch_predict_PC;
    // instantiating modules

    mux mux_st (
        .in0(PC),
        .in1(next_PCX),
        .sel(en_f || PCsrc),
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
    wire [31:0] branch_PC_sel = branch_actual_taken ? branch_PC : PC_P4;
    mux pc_mux (
        .in0(branch_predict_PC),
        .in1(branch_PC_sel),
        .sel(PCsrc),
        .out(next_PCX)
    );

    mux branch_predict_mux (
        .in0(inc_PC),
        .in1(branch_target),
        .sel(predict_taken),
        .out(branch_predict_PC)
    );

    onebit_dynamic_branch_predictor dyn_bp (
        .clk(clk),
        .RD_f(instr_f),
        .PC_f(PC),
        .mispredict(PCsrc),
        .branch_actual_taken(branch_actual_taken),
        .branch_actual_target(branch_PC),
        .type_j(type_j),
        .predict_taken_f(predict_taken),
        .branch_target_f(branch_target),
        .branch_pc(PC_e)
    );    
    assign branch_pc_e = branch_PC;
endmodule
