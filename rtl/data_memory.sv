module data_memory #(parameter ADDR_WIDTH = 12, parameter FILE_LOAD = 0, parameter FILE = "") (
    input   wire logic                  clk,

    input   wire logic [ADDR_WIDTH-1:0] addr_i,
    input   wire logic [31:0]           data_i,
    input   wire logic [2:0]            mem_ctrl,
    input   wire logic                  mem_write,

    output  wire logic [31:0]           data_o
);
    reg [31:0] RAM [0:2**(ADDR_WIDTH-2)-1];
    wire [31:0] write_data;
    wire [3:0] write_mask;
    initial begin
        if (FILE_LOAD) begin
            $readmemh(FILE, RAM);
        end
    end
    
    for (genvar k = 0; k < 4; k++) begin : _write_memory
        always_ff @(posedge clk) begin
            if (mem_write&write_mask[k]) begin
                RAM[addr_i[ADDR_WIDTH-1:2]][((k+1)*8)-1:k*8] <= write_data[((k+1)*8)-1:k*8];
            end
        end
    end

    load_format load_formatter (RAM[addr_i[ADDR_WIDTH-1:2]], addr_i[1:0], mem_ctrl, data_o);
    store_format store_formatter (data_i, addr_i[1:0], mem_ctrl[1:0], write_data, write_mask);
endmodule

