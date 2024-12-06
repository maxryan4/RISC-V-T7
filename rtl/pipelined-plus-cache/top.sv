module top #(
  parameter int DATA_WIDTH = 32,
  parameter int ADDRESS_WIDTH = 5
) (
  input logic clk,
  input logic rst,
  output logic [DATA_WIDTH-1:0] a0
);

  // every PCat is carried from one module to another
  // labels are (mostly) the exact same as the diagram on github.
  /* verilator lint_on UNUSED*/ 
  logic [DATA_WIDTH-1:0] PC_f;
  logic [DATA_WIDTH-1:0] PC_d;
  logic [DATA_WIDTH-1:0] PC_e;
  logic [DATA_WIDTH-1:0] instr_f;
  logic [DATA_WIDTH-1:0] instr_d;
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
  logic [DATA_WIDTH-1:0] RD1_d;
  logic [DATA_WIDTH-1:0] RD2_d;
  logic [DATA_WIDTH-1:0] RD2_e;
  logic [4:0] Rd_d;
  logic [4:0] Rd_e;
  logic [DATA_WIDTH-1:0] ImmExt_d;
  logic [DATA_WIDTH-1:0] ImmExt_e;
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

  logic en;
  logic rst_n;
  logic valid_f;
  logic valid_d;
  logic valid_e;
  logic valid_m;
  /* verilator lint_on UNUSED */ 


  // remove when implement hazard unit
  initial begin
    en = 1'b1;
    rst_n = 1'b1;
    valid_f = 1'b1;
    //valid_d = 1'b1;
    //valid_e = 1'b1;
    //valid_m = 1'b1;
  end

  //instantiating a module for each part of the CPU


  // ------ Fetch stage ------

  pc_top pc (
    .clk(clk),
    .rst(rst),
    .RS1(RD1_e),
    .PCaddsrc(PC_RD1_control_e),
    .PCsrc(PCSrc_e),
    .ImmOp(ImmOp_e),
    .PC(PC_f),
    .inc_PC(PCPlus4_f)
  );

  instruction_memory instruction_memory (
    .read_addr(read_addr[11:2]),
    .read_data(instr_f)
  );


  // ------ Pipelining fetch to decode stage ------

  fetch_reg_file fetch_reg_file (
    .clk(clk),
    .en(en),
    .rst_n(rst_n),
    .valid_f(valid_f),
    .read_data_f(instr_f),
    .read_data_d(instr_d),
    .PC_f(PC_f),
    .valid_d(valid_d),
    .PC_d(PC_d),
    .PCPlus4_f(PCPlus4_f),
    .PCPlus4_d(PCPlus4_d)
  );


  // ------ Decode stage ------

  control_unit control_unit (
    .EQ(EQ),
    .instr(instr_d),
    .RegWrite(RegWrite_d),
    .ALUctrl(ALUControl_d),
    .ALUsrc(ALUSrc_d),
    .ImmSrc(ImmSrc),
    .PCsrc(Jump_d),
    .Branch(Branch_d),
    .Jump(Jump_d),
    .destsrc(ResultSrc_d),
    .memCtrl(MemCtrl_d),
    .MemWrite(MemWrite_d),
    .UI_control(UI_control),
    .RD1_control(RD1_control_d),
    .PC_RD1_control(PC_RD1_control_d),
    .four_imm_control(four_imm_control)
  );

  wire [31:0] Result_w;

  register_file reg_file (
    .clk(clk),
    .AD1(rs1),
    .AD2(rs2),
    .AD3(Rd_w),
    .WE3(RegWrite_w),
    .WD3(Result_w),
    .RD1(RD1_d),
    .RD2(RD2_d),
    .a0(a0)
  );

  sign_extend sign_extend (
    .instruction(instr_d),
    .immsrc(ImmSrc),
    .immop(ImmOp_d)
  );

  mux ImmMux(
    .in0(32'd4),
    .in1(ImmOp_d),
    .sel(four_imm_control),
    .out(ImmExt_d)
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
    .en(en),
    .valid_d(valid_d),

    .PC_d(PC_d),
    .PCPlus4_d(PCPlus4_d),
    .RD1_d(RD1_d),
    .RD2_d(RD2_d),
    .ImmExt_d(ImmExt_d),
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

    .valid_e(valid_e),
    .PC_e(PC_e),
    .PCPlus4_e(PCPlus4_e),
    .RD1_e(RD1_e),
    .RD2_e(RD2_e),
    .ImmExt_e(ImmExt_e),
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
    .PC_RD1_control_e(PC_RD1_control_e)
  );


  // ------ Execute stage ------

  mux Op1Mux(
      .in0(UI_out_e),  
      .in1(RD1_e),
      .sel(RD1_control_e),
      .out(ALUop1)
  );

  mux Op2Mux(
      .in0(RD2_e),
      .in1(ImmExt_e),
      .sel(ALUSrc_e),
      .out(ALUop2)
  );

  ALU alu (
    .ALUop1(ALUop1),
    .ALUop2(ALUop2),
    .ALUctrl(ALUControl_e),
    .ALUout(ALUResult_e),
    .EQ(EQ)
  );

  always_comb begin
    PCSrc_e = Jump_e || (Branch_e && EQ);
    WriteData_e = RD2_e;
  end


  // ------ Pipelining execute to memory stage ------

  execute_reg_file execute_reg_file (
    .clk(clk),
    .rst_n(rst_n),
    .en(en),
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

  wire [31:0] ALUResult_m;

  data_memory data_memory (
    .clk(clk),
    .mem_write(MemWrite_m),
    .mem_ctrl(MemCtrl_m),
    .data_i(WriteData_m),
    .addr_i(ALUResult_m[11:0]),
    .data_o(ReadData_m)
  );


  // ------ Pipelining memory to write stage ------

  mem_reg_file mem_reg_file (
    .clk(clk),
    .en(en),
    .rst_n(rst_n),
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
  assign rs1 = instr_d[19:15];
  assign rs2 = instr_d[24:20];
  assign Rd_d = instr_d[11:7];
  assign read_addr = PC_f[11:0];
  //assign memCtrl = instr[14:12]; // this is already done in control_unit (i think)


endmodule
