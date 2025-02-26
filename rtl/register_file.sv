module register_file #(
    parameter ADDRESS_WIDTH = 5,
                DATA_WIDTH = 32
)(
    input logic clk,
    input logic [ADDRESS_WIDTH-1:0] AD1,
    input logic [ADDRESS_WIDTH-1:0] AD2,
    input logic [ADDRESS_WIDTH-1:0] AD3, // write address
    input logic WE3,
    input logic [DATA_WIDTH-1:0] WD3,
    output logic [DATA_WIDTH-1:0] RD1,
    output logic [DATA_WIDTH-1:0] RD2,
    output logic [DATA_WIDTH-1:0] a0
);

logic [DATA_WIDTH-1:0] register_array [2**ADDRESS_WIDTH-1:0];

always_ff @(negedge clk) begin
    if (AD3 != {ADDRESS_WIDTH{1'b0}}) begin
        if (WE3) register_array[AD3] <= WD3;
    end
end

always_comb begin 
    RD1 = register_array[AD1];
    RD2 = register_array[AD2];
end

assign a0 = register_array[10];

endmodule

