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
  logic [DATA_WIDTH-1:0] PC;
   /* verilator lint_on UNUSED */ 
  logic [DATA_WIDTH-1:0] instr;
  logic [DATA_WIDTH-1:0] ImmOp;
  logic EQ;
  logic [2:0] ImmSrc;
  logic [DATA_WIDTH-1:0] ALUop1;
  logic [DATA_WIDTH-1:0] ALUop2;
  logic [DATA_WIDTH-1:0] regOp2;
  logic [3:0] ALUctrl;
  logic [DATA_WIDTH-1:0] ALUout;
  logic [ADDRESS_WIDTH-1:0] rs1;
  logic [ADDRESS_WIDTH-1:0] rs2;
  logic [ADDRESS_WIDTH-1:0] rd;
  logic destsrc;
  logic RegWrite;
  logic ALUsrc;
  logic PCsrc;
  /* verilator lint_off UNUSED */ 
  logic [11:0] read_addr;
  /* verilator lint_on UNUSED */ 

  //instantiating a module for each part of the CPU
  pc_top pc (
    .clk(clk),
    .rst(rst),
    .PCsrc(PCsrc),
    .ImmOp(ImmOp),
    .PC(PC)
  );

  instruction_memory instruction_memory (
    .read_addr(read_addr[11:2]),
    .read_data(instr)
  );

  control_unit control_unit (
    .EQ(EQ),
    .instr(instr),
    .RegWrite(RegWrite),
    .ALUctrl(ALUctrl),
    .ALUsrc(ALUsrc),
    .ImmSrc(ImmSrc),
    .PCsrc(PCsrc),
    .destsrc(destsrc)
  );
  wire [31:0] regfile_dest_data;
  register_file reg_file (
    .clk(clk),
    .AD1(rs1),
    .AD2(rs2),
    .AD3(rd),
    .WE3(RegWrite),
    .WD3(regfile_dest_data),
    .RD1(ALUop1),
    .RD2(regOp2),
    .a0(a0)
  );

  mux mux (
      .in0(regOp2),
      .in1(ImmOp),
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

  

  sign_extend sign_extend (
    .instruction(instr),
    .immsrc(ImmSrc),
    .immop(ImmOp)
  );
  wire [31:0] data_out;
  data_memory data_memory (
    .clk(clk), .wen(destsrc), .write_data(regOp2), .write_addr(ALUout[11:0]), .read_addr(ALUout[11:0]), .read_data(data_out)
  );


  mux mux2 (
    .in0(ALUout),
    .in1(data_out),
    .sel(destsrc),
    .out(regfile_dest_data)
);


  // assigning signals that don't have an input.
  assign rs1 = instr[19:15];
  assign rs2 = instr[24:20];
  assign rd = instr[11:7];
  assign read_addr = PC[11:0];


endmodule

