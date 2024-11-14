module data_memory #(parameter ADDR_WIDTH = 12) (
    input   wire logic                  clk,

    input   wire logic                  wen,
    input   wire logic [31:0]           write_data,
    input   wire logic [ADDR_WIDTH-1:0] write_addr,

    input   wire logic [ADDR_WIDTH-1:0] read_addr,
    output       logic [31:0]           read_data
);


    reg [31:0] RAM [0:2**ADDR_WIDTH-1];

    always_ff @(posedge clk) begin
        RAM[write_addr] <= wen ? write_data : RAM[write_addr];
    end

    assign read_data = RAM[read_addr];
endmodule
