module load_format (
    input   wire logic [31:0]   read_data,
    input   wire logic [1:0]    addr_low,
    input   wire logic [2:0]    mem_ctrl,
    output  wire logic [31:0]   mem_data
);
    localparam BYTE = 2'b00;
    localparam HALFWORD = 2'b01;
    logic [31:0] select;


    logic [7:0] select_byte;
    assign select_byte = addr_low[1:0]==2'b00 ? read_data[7:0] :
                         addr_low[1:0]==2'b01 ? read_data[15:8]: 
                         addr_low[1:0]==2'b10 ? read_data[23:16] :
                         read_data[31:24];

    logic [15:0] select_halfbyte;
    assign select_halfbyte = addr_low[1] ? read_data[31:16] : read_data[15:0];

    logic invert;
    assign invert = !mem_ctrl[2] && ((mem_ctrl[1:0] == HALFWORD) && select_halfbyte[15] || ((mem_ctrl[1:0] == BYTE) && select_byte[7]));
    assign select = mem_ctrl[1:0]==BYTE ? {24{invert}, select_byte} : mem_ctrl[1:0]==HALFWORD ? {16{invert}, select_halfbyte} : read_data;

    assign mem_data = select;
endmodule
