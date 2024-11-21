module loadFormat (
    input   wire logic [31:0]   read_data,
    input   wire logic [1:0]    addrLow,
    input   wire logic [2:0]    memCtrl,
    output  wire logic [31:0]   memData
);
    logic [31:0] select;
    assign select = memCtrl[1:0]==2'b00 ? (addrLow[1:0]==2'b00 ? {24'h0,read_data[7:0]} :
    addrLow[1:0]==2'b01 ? {24'h0, read_data[15:8]} : addrLow[1:0]==2'b10 ? {24'h0, read_data[23:16]} : {24'h0, read_data[31:24]}) 
    : memCtrl[1:0]==2'b01 ? (addrLow[1] ? {16'h0, read_data[31:16]} : {16'h0, read_data[15:0]}) : read_data;

    logic [31:0] sign_extended_val;
    assign sign_extended_val = memCtrl[0] ? {{16{select[15]}}, select[15:0]} : {{24{select[7]}}, select[7:0]};

    assign memData = memCtrl[2] ? sign_extended_val : select;
endmodule
