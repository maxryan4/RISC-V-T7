module div_sc #( // does division in one cycle but means that clock speed will be low as very large unit
    DATA_WIDTH = 32,
    DIV_CTRL = 3
) (
    input logic [DATA_WIDTH-1:0] op1,
    input logic [DATA_WIDTH-1:0] op2,
    input logic [DIV_CTRL-1:0] div_ctrl,
    
    output logic [DATA_WIDTH-1:0] result

);

always_comb begin
    if (op2 == 0) begin
        result = 0;
    end 
    else
        case(div_ctrl)
            3'b100: result = $signed(op1) / $signed(op2);
            3'b101: result = $unsigned(op1) / $unsigned(op2);
            3'b110: result = $signed(op1) % $signed(op2);
            3'b111: result = $unsigned(op1) % $unsigned(op2);
            default: result = 0;
        endcase
end
endmodule
