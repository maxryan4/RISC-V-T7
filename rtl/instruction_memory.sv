module instruction_memory #(parameter ADDR_WIDTH = 12, parameter FILE_LOAD = 1, parameter FILE = "") (
    input   wire logic [ADDR_WIDTH-1:0] read_addr,
    output       logic [31:0]           read_data
);
    reg [31:0] ROM [0:2**ADDR_WIDTH-1];

    initial begin
        if (FILE_LOAD) begin
            $readmemh(FILE, ROM);
        end
    end

    assign read_data = ROM[read_addr];
endmodule