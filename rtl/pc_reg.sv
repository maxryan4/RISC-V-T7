module pc_reg #(
    DATA_WIDTH = 32
) (
    input   logic                   clk,
    input   logic                   rst,
    input   logic [DATA_WIDTH-1:0]  next_PC,
    output  logic [DATA_WIDTH-1:0]  PC
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            PC <= 32'b0;
        else
            PC <= next_PC;
    end

endmodule

