module sign_extend (
    input wire [31:0] instruction,
    input wire [2:0] immsrc,
    output logic [31:0] immop
);
    always_comb begin
        immop = 'x;
        case(immsrc)
            0:immop={{21{instruction[31]}},instruction[30:20]};
            1:immop={{20{instruction[31]}},instruction[7],instruction[30:25],instruction[11:8],1'b0};
        endcase
    end
endmodule