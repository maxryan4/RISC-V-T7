module loadFormat (
    input   wire logic [31:0]   read_data,
    input   wire logic [1:0]    addrLow,
    input   wire logic [2:0]    memCtrl,
    output  wire logic [31:0]   memData
);
    localparam BYTE = 2'b00;
    localparam HALFWORD = 2'b01;
    logic [31:0] select;

    logic [7:0] select_byte;
    assign select_byte = addrLow[1:0]==2'b00 ? read_data[7:0] :
                         addrLow[1:0]==2'b01 ? read_data[15:8]: 
                         addrLow[1:0]==2'b10 ? read_data[23:16] :
                         read_data[31:24];

    logic [15:0] select_halfbyte;
    assign select_halfbyte = addrLow[1] ? read_data[31:16] : read_data[15:0];
    
    assign select = memCtrl[1:0]==BYTE ? {24'h0,select_byte} : memCtrl[1:0]==HALFWORD ? {16'h0, select_halfbyte} : read_data;

    logic [31:0] sign_extended_val;
    assign sign_extended_val = memCtrl[0] ? {{16{select[15]}}, select[15:0]} : {{24{select[7]}}, select[7:0]};

    assign memData = memCtrl[2] ? sign_extended_val : select;
endmodule

