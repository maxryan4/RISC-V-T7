module mul #(
    parameter DATA_WIDTH = 32
)(
    input logic [DATA_WIDTH-1:0] a,
    input logic [DATA_WIDTH-1:0] b,
    input logic [1:0] mul_ctrl, // func3[1:0]

    output logic [DATA_WIDTH-1:0] result
);

logic [DATA_WIDTH*2-1:0] full_result;

always_comb begin
    case (mul_ctrl)
        // MUL
        2'b00: begin
            full_result = a * b;
            result = full_result[DATA_WIDTH-1:0];
        end

        // MULH: Signed high 32 bits
        2'b01: begin
            full_result = $signed(a) * $signed(b);
            result = full_result[2*DATA_WIDTH-1:DATA_WIDTH];
        end

        // MULHSU: Mixed signed/unsigned high 32 bits
        2'b10: begin
            full_result = $signed(a) * $unsigned(b);
            result = full_result[2*DATA_WIDTH-1:DATA_WIDTH];
        end

        // MULHU: Unsigned high 32 bits
        2'b11: begin
            full_result = $unsigned(a) * $unsigned(b);
            result = full_result[2*DATA_WIDTH-1:DATA_WIDTH];
        end

        default: result = 32'b0;

    endcase
end

endmodule
