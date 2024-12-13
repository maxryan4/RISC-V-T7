module mux3 (
    input logic [1:0] sel,
    input logic [31:0] in0, in1, in2,
    output logic [31:0] out
);

always_comb begin
    case (sel)
        2'b00: out = in0;                  // If sel = 0, select input a
        2'b01: out = in1;                  // If sel = 1, select input b
        2'b11: out = in2;                  // If sel = 2, select input c
        default: out = 32'b0;            // Default case for invalid select signals
    endcase
end
endmodule
