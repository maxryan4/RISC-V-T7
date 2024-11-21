module top #(
    DATA_WIDTH = 32
) (
    input   logic                   clk,
    input   logic                   rst,
    input   logic                   PCsrc,
    input   logic [DATA_WIDTH-1:0]  ImmOp,
    output  logic [DATA_WIDTH-1:0]  PC    
);

    // internal signals
    logic [DATA_WIDTH-1:0] branch_PC;
    logic [DATA_WIDTH-1:0] inc_PC;
    logic [DATA_WIDTH-1:0] next_PC;

    // instantiating modules
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

    adder pc_branch (
        .in0(PC),
        .in1(ImmOp),
        .out(branch_PC)
    );

    mux pc_mux (
        .in0(inc_PC),
        .in1(branch_PC),
        .sel(PCsrc),
        .out(next_PC)
    );

endmodule
