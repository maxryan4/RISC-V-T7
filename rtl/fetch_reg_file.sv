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

    input logic                         predict_taken_f,
    input logic [DATA_WIDTH-1:0]        branch_target_f,

    output logic                        valid_d,

    output logic [DATA_WIDTH-1:0]       read_data_d,
    output logic [DATA_WIDTH-1:0]       PC_d,
    output logic [DATA_WIDTH-1:0]       PCPlus4_d,
    output logic                        predict_taken_d,
    output logic [DATA_WIDTH-1:0]       branch_target_d
);

always_ff @(posedge clk) begin
    if (rst_n) begin
        if (en) begin
            read_data_d <= read_data_f;
            PC_d <= PC_f;
            PCPlus4_d <= PCPlus4_f;
            valid_d <= 1'b1;
            //valid_d <= valid_f;
            predict_taken_d <= predict_taken_f;
            branch_target_d <= branch_target_f;
        end
    end
    else begin
        read_data_d <= 32'b0;
        PC_d <= 32'b0;
        PCPlus4_d <= 32'b0;
        valid_d <= 1'b0;
        predict_taken_d <= 1'b0;
        branch_target_d <= 32'b0;
    end
end

endmodule
