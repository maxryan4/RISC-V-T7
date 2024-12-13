module top #(
  parameter int DATA_WIDTH = 32,
  parameter int ADDRESS_WIDTH = 5
) (
  input logic clk,
  input logic rst,
  input logic trigger,
  output logic [DATA_WIDTH-1:0] a0
);

  // every PCat is carried from one module to another
  // labels are (mostly) the exact same as the diagram on github.
  /* verilator lint_off UNUSED*/ 
  logic [DATA_WIDTH-1:0] PC_f;
  logic [DATA_WIDTH-1:0] PC_d;
  logic [DATA_WIDTH-1:0] PC_e;
  logic [DATA_WIDTH-1:0] instr_f;
  logic [DATA_WIDTH-1:0] instr_d;
  logic [DATA_WIDTH-1:0] instr_e;
  logic [DATA_WIDTH-1:0] PCPlus4_f;
  logic [DATA_WIDTH-1:0] PCPlus4_d;
  logic [DATA_WIDTH-1:0] PCPlus4_e;
  logic [DATA_WIDTH-1:0] PCPlus4_m;
  logic [DATA_WIDTH-1:0] PCPlus4_w;
  logic [DATA_WIDTH-1:0] ImmOp_d;
  logic [DATA_WIDTH-1:0] ImmOp_e;
  logic EQ;
  logic [2:0] ImmSrc;
  logic [DATA_WIDTH-1:0] ALUop1;
  logic [DATA_WIDTH-1:0] ALUop2;
  logic [3:0] ALUControl_d;
  logic [ADDRESS_WIDTH-1:0] rs1;
  logic [ADDRESS_WIDTH-1:0] rs2;
  logic RegWrite_d;
  logic RegWrite_e;
  logic RegWrite_m;
  logic RegWrite_w;
  logic UI_control;
  logic RD1_control_d;
  logic RD1_control_e;
  logic PC_RD1_control_d;
  logic PC_RD1_control_e;
  logic four_imm_control;
  logic [11:0] read_addr;
  logic [1:0] ResultSrc_m;
  logic [1:0] ResultSrc_w;
  logic [1:0] ResultSrc_e;
  logic [1:0] ResultSrc_d;
  logic [DATA_WIDTH-1:0] ALUResult_e;
  logic [DATA_WIDTH-1:0] ALUResult_m;
  logic [DATA_WIDTH-1:0] ALUResult_w;
  logic [DATA_WIDTH-1:0] WriteData_e;
  logic [DATA_WIDTH-1:0] WriteData_m;
  logic [DATA_WIDTH-1:0] ReadData_m;
  logic [DATA_WIDTH-1:0] ReadData_w;
  logic [DATA_WIDTH-1:0] RD1_e;
  logic PCSrc_e;
  logic ALUSrc_d;
  logic Jump_d;
  logic Branch_d;
  logic MemWrite_d;
  logic [4:0] Rd_w;
  logic [DATA_WIDTH-1:0] RD2_e;
  logic [4:0] Rd_d;
  logic [4:0] Rd_e;
  logic [DATA_WIDTH-1:0] UI_out_d;
  logic [DATA_WIDTH-1:0] UI_out_e;
  logic [2:0] MemCtrl_d;
  logic ALUSrc_e;
  logic Jump_e;
  logic Branch_e;
  logic MemWrite_e;
  logic [2:0] MemCtrl_e;
  logic [2:0] MemCtrl_m;
  logic MemWrite_m;
  logic [4:0] Rd_m;
  logic [3:0] ALUControl_e;
  logic [31:0] branch_target;
  logic        predict_taken;
  logic [31:0] branch_target_d;
  logic        predict_taken_d;
  logic [31:0] branch_target_e;
  logic        predict_taken_e;
  logic [31:0] branch_pc_e;
  logic en;
  logic rst_n;
  logic valid_f;
  logic valid_d;
  logic valid_e;
  logic valid_m;
  logic hazard1;
  logic hazard2;
  logic hazard;
  logic f_RD1;
  logic f_RD2;
  logic [4:0] RS1_e;
  logic [4:0] RS2_e;
  logic [DATA_WIDTH-1:0] RS1_fdata;
  logic [DATA_WIDTH-1:0] RS2_fdata;
  logic [DATA_WIDTH-1:0] RD1_forwarded;
  logic [DATA_WIDTH-1:0] RD2_forwarded;
  logic mul_sel_d;
  logic mul_sel_e;
  logic div_ready;
  logic stall_div;
  
  wire en_f, en_d, en_e, en_m;
  wire branch_actual_taken = valid_e&((Branch_e&EQ)|Jump_e);
  /* verilator lint_on UNUSED */ 


  initial begin
    valid_f = 1'b1;
  end

  //instantiating a module for each part of the CPU


  // ------ Fetch stage ------

  pc_top pc (
    .clk(clk),
    .rst(rst),
    .en_f(en_f),
    .RS1(RD1_forwarded),
    .PCaddsrc(PC_RD1_control_e),
    .PCsrc(PCSrc_e),
    .ImmOp(ImmOp_e),
    .PC(PC_f),
    .inc_PC(PCPlus4_f),
    .PC_e(PC_e),
    .instr_f(instr_f),
    .branch_actual_taken(branch_actual_taken),
    .type_j(Jump_e),
    .branch_target(branch_target),
    .predict_taken(predict_taken),
    .branch_pc_e(branch_pc_e),
    .PC_P4(PCPlus4_e)
  );

  instruction_memory instruction_memory (
    .read_addr(read_addr[11:2]),
    .read_data(instr_f)
  );


  // ------ Pipelining fetch to decode stage ------

  fetch_reg_file fetch_reg_file (
    .clk(clk),
    .en(en_f),
    .rst_n(rst_n),
    .valid_f(valid_f),
    .read_data_f(instr_f),
    .read_data_d(instr_d),
    .PC_f(PC_f),
    .valid_d(valid_d),
    .PC_d(PC_d),
    .PCPlus4_f(PCPlus4_f),
    .PCPlus4_d(PCPlus4_d),
    .branch_target_f(branch_target),
    .predict_taken_f(predict_taken),
    .branch_target_d(branch_target_d),
    .predict_taken_d(predict_taken_d)
  );

  /*
  logic en;
  logic rst_n;
  logic valid_f;
  logic valid_d;
  logic valid_e;
  logic valid_m;
  */
  
  mux Rs1Select(
    .in0(RD1_e),
    .in1(RS1_fdata),
    .sel(f_RD1),
    .out(RD1_forwarded)
  );

  mux Rs2Select(
    .in0(RD2_e),
    .in1(RS2_fdata),
    .sel(f_RD2),
    .out(RD2_forwarded)
  );

  // ------ Pipelining Hazard Unit ------ 
  wire load_m = ResultSrc_m==2'd1;

  hazard_unit hazard_unit1(
    .execute_reg(RS1_e),
    .load_m(load_m),
    .valid_e(valid_e),
    .valid_m(valid_m),
    .valid_w(RegWrite_w),
    .dest_m(Rd_m),
    .dest_w(Rd_w),
    .data_m(ALUResult_m),
    .data_w(Result_w),

    .forward(f_RD1),
    .hazard(hazard1),
    .data(RS1_fdata)
  );

  hazard_unit hazard_unit2 (
    .execute_reg(RS2_e),
    .load_m(load_m),
    .valid_e(valid_e),
    .valid_m(valid_m),
    .valid_w(RegWrite_w),
    .dest_m(Rd_m),
    .dest_w(Rd_w),
    .data_m(ALUResult_m),
    .data_w(Result_w),

    .forward(f_RD2),
    .hazard(hazard2),
    .data(RS2_fdata)
  );

  // ------ Decode stage ------

  control_unit control_unit (
    .instr(instr_d),
    .RegWrite(RegWrite_d),
    .ALUctrl(ALUControl_d),
    .ALUsrc(ALUSrc_d),
    .ImmSrc(ImmSrc),
    .Branch(Branch_d),
    .Jump(Jump_d),
    .destsrc(ResultSrc_d),
    .memCtrl(MemCtrl_d),
    .MemWrite(MemWrite_d),
    .UI_control(UI_control),
    .RD1_control(RD1_control_d),
    .PC_RD1_control(PC_RD1_control_d),
    .four_imm_control(four_imm_control),
    .mul_sel(mul_sel_d)
  );

  wire [31:0] Result_w;

  register_file reg_file (
    .clk(clk),
    .AD1(rs1),
    .AD2(rs2),
    .AD3(Rd_w),
    .WE3(RegWrite_w),
    .WD3(Result_w),
    .RD1(RD1_e),
    .RD2(RD2_e),
    .a0(a0)
  );

  sign_extend sign_extend (
    .instruction(instr_d),
    .immsrc(ImmSrc),
    .immop(ImmOp_d)
  );

mux UIMux(
    .in0(32'b0),  
    .in1(PC_d),
    .sel(UI_control),
    .out(UI_out_d)
);


  // ------ Pipelining decode to execute stage ------

  decode_reg_file decode_reg_file(
    .clk(clk),
    .rst_n(rst_n),
    .en(en_d),
    .en_e(en_e),
    .valid_d(valid_d),

    .PC_d(PC_d),
    .PCPlus4_d(PCPlus4_d),
    .Rd_d(Rd_d),
    .ImmOp_d(ImmOp_d),
    .RegWrite_d(RegWrite_d),
    .ResultSrc_d(ResultSrc_d),
    .MemWrite_d(MemWrite_d),
    .Jump_d(Jump_d),
    .Branch_d(Branch_d),
    .ALUControl_d(ALUControl_d),
    .ALUSrc_d(ALUSrc_d),
    .UI_OUT_d(UI_out_d),
    .MemCtrl_d(MemCtrl_d),
    .RD1_control_d(RD1_control_d),
    .PC_RD1_control_d(PC_RD1_control_d),
    .RS1_d(instr_d[19:15]),
    .RS2_d(instr_d[24:20]),
    .mul_sel_d(mul_sel_d),
    .instr_d(instr_d),
    .branch_target_d(branch_target_d),
    .predict_taken_d(predict_taken_d),
    .branch_target_e(branch_target_e),
    .predict_taken_e(predict_taken_e),

    .RS1_e(RS1_e),
    .RS2_e(RS2_e),
    .valid_e(valid_e),
    .PC_e(PC_e),
    .PCPlus4_e(PCPlus4_e),
    .Rd_e(Rd_e),
    .ImmOp_e(ImmOp_e),
    .RegWrite_e(RegWrite_e),
    .ResultSrc_e(ResultSrc_e),
    .MemWrite_e(MemWrite_e),
    .Jump_e(Jump_e),
    .Branch_e(Branch_e),
    .ALUControl_e(ALUControl_e),
    .ALUSrc_e(ALUSrc_e),
    .UI_OUT_e(UI_out_e),
    .MemCtrl_e(MemCtrl_e),
    .RD1_control_e(RD1_control_e),
    .PC_RD1_control_e(PC_RD1_control_e),
    .mul_sel_e(mul_sel_e),
    .instr_e(instr_e)
  );


  // ------ Execute stage ------

  mux Op1Mux(
      .in0(UI_out_e),  
      .in1(RD1_forwarded),
      .sel(RD1_control_e),
      .out(ALUop1)
  );

  mux Op2Mux(
      .in0(RD2_forwarded),
      .in1(ImmOp_e),
      .sel(ALUSrc_e),
      .out(ALUop2)
  );

  ALU_top ALU_top (
    .clk(clk),
    .ALUop1(ALUop1),
    .ALUop2(ALUop2),
    .ALUctrl(ALUControl_e),
    .ALUout(ALUResult_e),
    .EQ(EQ),
    .mul_sel(mul_sel_e),
    .div_ready(div_ready)
  );

  // check to see if should stall for division
  always_comb begin 
    stall_div = 1'b0;
  end

  always_comb begin
    PCSrc_e = ((Jump_e&!predict_taken_e || (Branch_e && (EQ^predict_taken_e))))&valid_e;
    WriteData_e = RD2_forwarded;
  end


  // ------ Pipelining execute to memory stage ------

  execute_reg_file execute_reg_file (
    .clk(clk),
    .rst_n(1'b1),
    .en(en_e),
    .en_m(en_m),
    .valid_e(valid_e),
    
    .PCPlus4_e(PCPlus4_e),
    .ALUResult_e(ALUResult_e),
    .WriteData_e(WriteData_e),
    .Rd_e(Rd_e),
    .RegWrite_e(RegWrite_e),
    .ResultSrc_e(ResultSrc_e),
    .MemWrite_e(MemWrite_e),
    .MemCtrl_e(MemCtrl_e),

    .valid_m(valid_m),
    .PCPlus4_m(PCPlus4_m),
    .ALUResult_m(ALUResult_m),
    .WriteData_m(WriteData_m),
    .Rd_m(Rd_m),
    .RegWrite_m(RegWrite_m),
    .ResultSrc_m(ResultSrc_m),
    .MemWrite_m(MemWrite_m),
    .MemCtrl_m(MemCtrl_m)
  );


  // ------ Memory stage ------
  
  wire mem_op_valid = (load_m|MemWrite_m)&valid_m;
  mem_top #(18, 64, 0) data_memory_cache (
    .cpu_clock_i(clk),
    .cpu_addr_i(ALUResult_m[19:0]),
    .cpu_data_i(WriteData_m),
    .cpu_mem_ctrl_i(MemCtrl_m),
    .cpu_mem_write_i(MemWrite_m),
    .cpu_valid_i(mem_op_valid),
    .cpu_data_o(ReadData_m),
    .cpu_en_o(en_m)
  );
  // ------ Pipelining memory to write stage ------

  mem_reg_file mem_reg_file (
    .clk(clk),
    .en(en_m),
    .en_w(RegWrite_w),
    .rst_n(1'b1),
    .valid_m(valid_m),
    .PCPlus4_m(PCPlus4_m),
    .ALUResult_m(ALUResult_m),
    .ReadData_m(ReadData_m),
    .PCPlus4_w(PCPlus4_w),
    .ALUResult_w(ALUResult_w),
    .ReadData_w(ReadData_w),
    .RegWrite_w(RegWrite_w),
    .RegWrite_m(RegWrite_m),
    .ResultSrc_w(ResultSrc_w),
    .ResultSrc_m(ResultSrc_m),
    .Rd_m(Rd_m),
    .Rd_w(Rd_w)
  );


  // ------ Write stage ------

  mux3 mux3 (
    .in0(ALUResult_w),
    .in1(ReadData_w),
    .in2(PCPlus4_w),
    .sel(ResultSrc_w),
    .out(Result_w)
);


  // assigning signals that don't have an input.
  assign hazard = hazard1 | hazard2;
  assign rs1 = RS1_e;
  assign rs2 = RS2_e;
  assign Rd_d = instr_d[11:7];
  assign read_addr = PC_f[11:0];
  assign en_f = en_d;
  assign en_d = en_e;
  assign en_e = !hazard&en_m & !stall_div;
  //assign en_m = !cpu_stall_o;
  //assign en_m = 1'b1;
  assign rst_n = (!PCSrc_e&!rst);

endmodule

