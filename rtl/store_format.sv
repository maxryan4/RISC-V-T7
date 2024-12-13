module store_format (
    input   wire logic [31:0]   reg_data,
    input   wire logic [1:0]    addr_low,
    input   wire logic [1:0]    mem_ctrl,
    output  wire logic [31:0]   mem_data,
    output  wire logic [3:0]    mem_we
);
    localparam BYTE = 2'b00;
    localparam HALFWORD = 2'b01;
    localparam WORD = 2'b10;
    assign mem_data = mem_ctrl[1:0]==BYTE ? {4{reg_data[7:0]}} : mem_ctrl[1:0]==HALFWORD ? {2{reg_data[15:0]}} : reg_data;
    assign mem_we[0] = ((mem_ctrl==BYTE)&&(addr_low==2'b00))|((mem_ctrl==HALFWORD)&&(addr_low[1]==1'b0))|(mem_ctrl==WORD);
    assign mem_we[1] = ((mem_ctrl==BYTE)&&(addr_low==2'b01))|((mem_ctrl==HALFWORD)&&(addr_low[1]==1'b0))|(mem_ctrl==WORD);
    assign mem_we[2] = ((mem_ctrl==BYTE)&&(addr_low==2'b10))|((mem_ctrl==HALFWORD)&&(addr_low[1]==1'b1))|(mem_ctrl==WORD);
    assign mem_we[3] = ((mem_ctrl==BYTE)&&(addr_low==2'b11))|((mem_ctrl==HALFWORD)&&(addr_low[1]==1'b1))|(mem_ctrl==WORD);
endmodule
