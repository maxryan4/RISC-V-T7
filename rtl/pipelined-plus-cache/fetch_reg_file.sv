module fetch_reg_file #(
    parameter DATA_WIDTH = 32
)(
    input logic                         clk,
    input logic                         rst_n, // flush active low
    input logic                         en, // stall (if set low will stall)
    input logic                         valid_f, // valid for fetch

    input logic [DATA_WIDTH-1:0]        read_data_f,
    input logic [DATA_WIDTH-1:0]        PC_f,
    input logic [DATA_WIDTH-1:0]        PCPlus4_f,

    output logic                       valid_d,

    output logic [DATA_WIDTH-1:0]       read_data_d,
    output logic [DATA_WIDTH-1:0]       PC_d,
    output logic [DATA_WIDTH-1:0]       PCPlus4_d
);

always_ff @(posedge clk or negedge rst_n) begin
    if (rst_n) begin
        if (en && valid_f) begin
            valid_d <= valid_f;
            read_data_d <= read_data_f;
            PC_d <= PC_f;
            PCPlus4_d <= PCPlus4_f;
        end
    end
    else begin
        read_data_d <= 32'b0;
        PC_d <= 32'b0;
        PCPlus4_d <= 32'b0;
    end
end

endmodule
