// not finished
module decode_reg_file #(
    parameter 
    DATA_WIDTH = 32,
    READ_DATA_WIDTH = 5,
    SRC_WIDTH = 2,
    ALU_CONTROL_WIDTH = 4,
    MEM_CTRL_WIDTH = 3
)(
    input logic                         clk,
    input logic                         rst_n, // flush active low
    input logic                         en, // stall (if set low will stall)
    input logic                         valid_d, // valid for decode
    input logic                         en_e,

    input logic [DATA_WIDTH-1:0]        PC_d,
    input logic [DATA_WIDTH-1:0]        PCPlus4_d,
    input logic [READ_DATA_WIDTH-1:0]   Rd_d,
    input logic [DATA_WIDTH-1:0]        UI_OUT_d,
    input logic [DATA_WIDTH-1:0]        ImmOp_d,
    input logic [DATA_WIDTH-1:0]        instr_d,

    input logic                         RegWrite_d,
    input logic [SRC_WIDTH - 1:0]       ResultSrc_d,
    input logic                         MemWrite_d,
    input logic                         Jump_d,
    input logic                         Branch_d,
    input logic [ALU_CONTROL_WIDTH-1:0] ALUControl_d,
    input logic                         ALUSrc_d,
    input logic [MEM_CTRL_WIDTH-1:0]    MemCtrl_d,
    input logic                         RD1_control_d,
    input logic                         PC_RD1_control_d,
    input logic [READ_DATA_WIDTH-1:0]   RS1_d,
    input logic [READ_DATA_WIDTH-1:0]   RS2_d,
    input logic                         mul_sel_d,

    input logic                         predict_taken_d,
    input logic [DATA_WIDTH-1:0]        branch_target_d,

    output logic                        valid_e,

    output logic [DATA_WIDTH-1:0]       PC_e,
    output logic [DATA_WIDTH-1:0]       PCPlus4_e,
    output logic [READ_DATA_WIDTH-1:0]  Rd_e,
    output logic [READ_DATA_WIDTH-1:0]  RS1_e,
    output logic [READ_DATA_WIDTH-1:0]  RS2_e,
    output logic [DATA_WIDTH-1:0]       UI_OUT_e,
    output logic [DATA_WIDTH-1:0]       ImmOp_e,
    output logic [DATA_WIDTH-1:0]       instr_e,

    output logic                        RegWrite_e,
    output logic [SRC_WIDTH - 1:0]      ResultSrc_e,
    output logic                        MemWrite_e,
    output logic                        Jump_e,
    output logic                        Branch_e,
    output logic [ALU_CONTROL_WIDTH-1:0]ALUControl_e,
    output logic                        ALUSrc_e,
    output logic [MEM_CTRL_WIDTH-1:0]   MemCtrl_e,
    output logic                        RD1_control_e,
    output logic                        PC_RD1_control_e,
    output logic                        mul_sel_e,
    
    output logic                        predict_taken_e,
    output logic [DATA_WIDTH-1:0]       branch_target_e
);

always_ff @(posedge clk) begin
    if (rst_n) begin
        if(en) begin
            if (valid_d) begin
                PC_e <= PC_d;
                PCPlus4_e <= PCPlus4_d;
                RS1_e <= RS1_d;
                RS2_e <= RS2_d;
                Rd_e <= Rd_d;
                ImmOp_e <= ImmOp_d;
                RegWrite_e <= RegWrite_d;
                ResultSrc_e <= ResultSrc_d;
                MemWrite_e <= MemWrite_d;
                Jump_e <= Jump_d;
                Branch_e <= Branch_d;
                ALUControl_e <= ALUControl_d;
                ALUSrc_e <= ALUSrc_d;
                UI_OUT_e <= UI_OUT_d;
                MemCtrl_e <= MemCtrl_d;
                RD1_control_e <= RD1_control_d;
                PC_RD1_control_e <= PC_RD1_control_d;
                mul_sel_e <= mul_sel_d;
                instr_e <= instr_d;
                predict_taken_e <= predict_taken_d;
                branch_target_e <= branch_target_d;
            end 
            valid_e <= valid_d;
          end else if (en_e) begin
            valid_e <= 1'b0; 
          end
    end
    else begin
        PC_e <= 32'b0;
        PCPlus4_e <= 32'b0;
        Rd_e <= 5'b0;
        ImmOp_e <= 32'b0;
        RegWrite_e <= 1'b0;
        ResultSrc_e <= 2'b0;
        MemWrite_e <= 1'b0;
        Jump_e <= 1'b0;
        Branch_e <= 1'b0;
        ALUControl_e <= 4'b0;
        ALUSrc_e <= 1'b0;
        UI_OUT_e <= 32'b0;
        MemCtrl_e <= 3'b0;
        RD1_control_e <= 1'b0;
        PC_RD1_control_e <= 1'b0;
        valid_e <= 1'b0;
        mul_sel_e <= 1'b0;
        instr_e <= 32'b0;
        predict_taken_e <= 1'b0;
        branch_target_e <= 32'b0;
    end
end

endmodule
