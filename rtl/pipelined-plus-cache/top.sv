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
   /* verilator lint_off UNUSED */ 
  logic [DATA_WIDTH-1:0] PC_f;
  logic [DATA_WIDTH-1:0] PC_d;
  logic [DATA_WIDTH-1:0] instr_f;
  logic [DATA_WIDTH-1:0] instr_d;
  logic [DATA_WIDTH-1:0] PCPlus4_f;
  logic [DATA_WIDTH-1:0] PCPlus4_d;
  logic [DATA_WIDTH-1:0] PCPlus4_e;
  logic [DATA_WIDTH-1:0] PCPlus4_m;
  logic [DATA_WIDTH-1:0] PCPlus4_w;
  logic [DATA_WIDTH-1:0] ImmOp;
  logic EQ;
  logic [2:0] ImmSrc;
  logic [DATA_WIDTH-1:0] ALUop1;
  logic [DATA_WIDTH-1:0] ALUop2;
  logic [3:0] ALUctrl;
  logic [DATA_WIDTH-1:0] ALUout;
  logic [ADDRESS_WIDTH-1:0] rs1;
  logic [ADDRESS_WIDTH-1:0] rs2;
  logic [ADDRESS_WIDTH-1:0] rd;
  logic destsrc;
  logic RegWrite;
  logic ALUsrc;
  logic PCsrc;
  logic [2:0] memCtrl;
  logic MemWrite;
  logic UI_control;
  logic RD1_control;
  logic [DATA_WIDTH-1:0] RD1;
  logic [DATA_WIDTH-1:0] RD2;
  logic PC_RD1_control;
  logic four_imm_control;
  logic [DATA_WIDTH-1:0] Imm;
  logic [DATA_WIDTH-1:0] UI_out;
  logic [11:0] read_addr;
  logic [1:0] ResultSrc_m;
  logic [1:0] ResultSrc_w;
  logic en;
  logic rst_n;

  // additional branch predictor logic:
  logic predict_taken;
  logic [DATA_WIDTH-1:0] correct_PC;

  /* verilator lint_on UNUSED */ 


  // remove when implement hazard unit
  initial begin
    en = 1'b1;
    rst_n = 1'b1;
  end

  //instantiating a module for each part of the CPU

  // ------ Fetch stage ------

  pc_top pc (
    .clk(clk),
    .rst(rst),
    .RS1(RD1),
    .PCaddsrc(PC_RD1_control),
    .PCsrc(PCsrc),
    .ImmOp(ImmOp),
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
    .read_data_f(instr_f),
    .read_data_d(instr_d),
    .PC_f(PC_f),
    .PC_d(PC_d),
    .PCPlus4_f(PCPlus4_f),
    .PCPlus4_d(PCPlus4_d)
  );


  // ------ Decode stage ------

  control_unit control_unit (
    .EQ(EQ),
    .instr(instr_d),
    .RegWrite(RegWrite),
    .ALUctrl(ALUctrl),
    .ALUsrc(ALUsrc),
    .ImmSrc(ImmSrc),
    .PCsrc(PCsrc),
    .destsrc(destsrc),
    .memCtrl(memCtrl),
    .MemWrite(MemWrite),
    .UI_control(UI_control),
    .RD1_control(RD1_control),
    .PC_RD1_control(PC_RD1_control),
    .four_imm_control(four_imm_control)
  );

  wire [31:0] regfile_dest_data;

  register_file reg_file (
    .clk(clk),
    .AD1(rs1),
    .AD2(rs2),
    .AD3(rd),
    .WE3(RegWrite),
    .WD3(regfile_dest_data),
    .RD1(RD1),
    .RD2(RD2),
    .a0(a0)
  );

  // double check this in right place
  mux ImmMux(
      .in0(32'd4),
      .in1(ImmOp),
      .sel(four_imm_control),
      .out(Imm)
  );
  
  // double check this in right place
  mux UIMux(
      .in0(32'b0),  
      .in1(PC),
      .sel(UI_control),
      .out(UI_out)
  );

  sign_extend sign_extend (
    .instruction(instr_d),
    .immsrc(ImmSrc),
    .immop(ImmOp)
  );


  // ------ Pipelining decode to execute stage ------

  decode_reg_file decode_reg_file (
    .clk(clk),
    .PC_d(PC_d),
    .RD1_d(RD1_d),
    .RD2_d(RD2_d),
    .PCPlus4_d(PCPlus4_d),
    .PC_e(PC_e),
    .RD1_e(RD1_e),
    .RD2_e(RD2_e),
    .PCPlus4_e(PCPlus4_e)
  );


  // ------ Execute stage ------

  mux Op1Mux(
      .in0(UI_out),  
      .in1(RD1_e),
      .sel(RD1_control),
      .out(ALUop1)
  );

  mux Op2Mux(
      .in0(RD2),
      .in1(Imm),
      .sel(ALUsrc),
      .out(ALUop2)
  );

  ALU alu (
    .ALUop1(ALUop1),
    .ALUop2(ALUop2),
    .ALUctrl(ALUctrl),
    .ALUout(ALUout),
    .EQ(EQ)
  );

  // ------ Pipelining execute to memory stage ------


  // ------ Memory stage ------

  wire [31:0] ALUResult_m;

  data_memory data_memory (
    .clk(clk),
    .mem_write(MemWrite),
    .mem_ctrl(memCtrl),
    .data_i(RD2),
    .addr_i(ALUout[11:0]),
    .data_o(ALUResult_m)
  );


  // ------ Pipelining memory to write stage ------

  mem_reg_file mem_reg_file (
    .clk(clk),
    .en(en),
    .rst_n(rst_n),
    .PCPlus4_m(PCPlus4_m),
    .ALUResult_m(ALUResult_m),
    .ReadData_m(ReadData_m),
    .PCPlus4_w(PCPlus4_w),
    .ALUResult_w(ALUResult_w),
    .ReadData_w(ReadData_w),
    .RegWrite_w(RegWrite_w),
    .RegWrite_m(RegWrite_m),
    .ResultSrc_w(ResultSrc_w),
    .ResultSrc_m(ResultSrc_m)
  );

  // ------ Write stage ------
  mux3 mux3 (
    .in0(ALUResult_w),
    .in1(ReadData_w),
    .in2(PCPlus4_w),
    .sel(ResultSrc_w),
    .out(regfile_dest_data)
);


  // assigning signals that don't have an input.
  assign rs1 = instr[19:15];
  assign rs2 = instr[24:20];
  assign rd = instr[11:7];
  assign read_addr = PC[11:0];
  assign memCtrl = instr[14:12];


endmodule
