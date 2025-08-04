module ext_mem #(
    parameter AW = 18,
    parameter DW = 32,
    parameter FILE_LOAD = 1,
    parameter FILE = "../rtl/memory/gaussian.mem",
    localparam SL = DW / 8
) (
    input wire logic clk_i,
    input wire logic rst_i,

    input wire logic          cyc_i,
    input wire logic          stb_i,
    input wire logic          we_i,
    input wire logic [AW-1:0] adr_i,
    input wire logic [DW-1:0] dat_i,
    input wire logic [SL-1:0] sel_i,

    output logic          stall_o,
    output logic          ack_o,
    output logic [DW-1:0] dat_o,
    output logic          err_o
);
  reg [DW-1:0] RAM[0:(2**AW)-1];
  reg [DW/4-1:0] temp_ram[0:(2**AW)*4-1];

  initial begin
    if (FILE_LOAD) begin

      $readmemh(FILE, temp_ram, 18'h10000);  // Load raw data into a temporary ROM

      // Reverse the byte order for each word
      for (int i = 18'h10000; i < (2 ** AW) * 4; i += 4) begin
        RAM[i/4] = {temp_ram[i+3], temp_ram[i+2], temp_ram[i+1], temp_ram[i]};
      end

    end else begin
      for (integer i = 0; i < 2 ** AW; i++) begin
        RAM[i] = '0;
      end
    end

  end


  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      ack_o   <= '0;
      err_o   <= '0;
      stall_o <= '0;
    end else if (cyc_i & stb_i) begin
      ack_o   <= '1;
      err_o   <= '0;
      stall_o <= '0;
      if (!we_i) begin
        dat_o <= RAM[adr_i];
      end
    end else begin
      ack_o   <= '0;
      err_o   <= '0;
      stall_o <= '0;
    end
  end
  for (genvar i = 0; i < SL; i++) begin : _write_ram_per_bitmask
    always_ff @(posedge clk_i) begin
      if (cyc_i & stb_i & sel_i[i]) begin
        RAM[adr_i][8*(i+1)-1:8*i] <= dat_i[8*(i+1)-1:8*i];
      end
    end
  end
endmodule
