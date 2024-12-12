module div_mc #( // takes 32 cycles to do a division to reduce impact on clock speed
    DATA_WIDTH = 32
) (
    input  logic clk,
    input  logic rst,
    input  logic start,
    input  logic [DATA_WIDTH-1:0] dividend, // number to be divided by
    input  logic [DATA_WIDTH-1:0] divisor, // number to divide by
    input  logic signed_op, // 1 for signed division and 0 for unsigned
    output logic [DATA_WIDTH-1:0] quotient,
    output logic [DATA_WIDTH-1:0] remainder,
    output logic ready
);

// Internal signals
logic [DATA_WIDTH-1:0] dividend_reg;
logic [DATA_WIDTH-1:0] divisor_reg;
logic [DATA_WIDTH-1:0] quotient_reg;
logic [DATA_WIDTH-1:0] remainder_reg;
logic [5:0]  count;
logic sign_dividend;
logic sign_result;
logic busy; // 1 if division is in progress


always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        dividend_reg <= 32'b0;
        divisor_reg  <= 32'b0;
        quotient_reg <= 32'b0;
        remainder_reg <= 32'b0;
        count <= 6'b0;
        ready <= 1'b0;
        busy <= 1'b0;
    end 
    else if (start && !busy) begin
        if (divisor == 32'b0) begin // handle division by zero
            ready <= 1'b1;
            busy <= 1'b0;
            quotient <= signed_op ? 32'hFFFFFFFF : 32'h7FFFFFFF; // Max value for error in both signed and unsigned case
            remainder <= dividend; // Remainder is the dividend in case of division by zero as there is no meaningful result
        end 
        else begin
            ready <= 1'b0;
            busy <= 1'b1;
            // Handle signed operands if required
            if (signed_op) begin
                sign_dividend <= dividend[DATA_WIDTH-1];
                if (dividend == 32'h80000000) begin  // handle -2^31 (the smallest signed 32-bit value) case as can't negate -2^31 as would cause overflow
                    dividend_reg <= dividend;  // Keep the dividend as is
                    divisor_reg <= divisor[DATA_WIDTH-1] ? -divisor : divisor;  // Negate divisor if negative
                    sign_result <= dividend[DATA_WIDTH-1] ^ divisor[DATA_WIDTH-1];
                end 
                else begin
                    dividend_reg <= dividend[DATA_WIDTH-1] ? -dividend : dividend;
                    divisor_reg <= divisor[DATA_WIDTH-1] ? -divisor : divisor;
                    sign_result <= dividend[DATA_WIDTH-1] ^ divisor[DATA_WIDTH-1];
                end
            end 
            else begin
                dividend_reg <= dividend;
                divisor_reg <= divisor;
                sign_dividend <= 1'b0;
                sign_result <= 1'b0;
            end

            quotient_reg <= 32'b0;
            remainder_reg <= 32'b0;
            count <= 6'b0;
        end 
    end
    else if (busy) begin
        if (count < 32) begin // division is in progress
            remainder_reg <= {remainder_reg[DATA_WIDTH-2:0], dividend_reg[DATA_WIDTH-1]};
            dividend_reg <= {dividend_reg[DATA_WIDTH-2:0], 1'b0};
            
            if (remainder_reg >= divisor_reg) begin
                remainder_reg <= remainder_reg - divisor_reg;
                quotient_reg <= {quotient_reg[DATA_WIDTH-2:0], 1'b1};
            end 
            else begin
                quotient_reg <= {quotient_reg[DATA_WIDTH-2:0], 1'b0};
            end

            count <= count + 1;
        end
        else begin // division is complete
            busy <= 1'b0;
            ready <= 1'b1;
            
            if (signed_op) begin
                quotient <= sign_result ? -quotient_reg : quotient_reg;
                remainder <= sign_dividend ? -remainder_reg : remainder_reg;
            end 
            else begin
                quotient <= quotient_reg;
                remainder <= remainder_reg;
            end
        end
    end
end
endmodule
