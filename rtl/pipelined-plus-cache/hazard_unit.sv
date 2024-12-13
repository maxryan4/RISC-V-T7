module hazard_unit(
    input wire [4:0] execute_reg,
   
    input wire valid_e,
    input wire valid_m,
    input wire load_m,
    input wire valid_w,

   input wire [4:0]  dest_m,
    input wire [4:0] dest_w,

    input wire [31:0] data_m,
    input wire [31:0] data_w,

    output logic forward,
    output logic hazard,
    output logic [31:0] data
);
    always_comb begin
        if(valid_e) begin
            if(valid_m==1&&execute_reg==dest_m&&!(dest_m==0))begin
                forward=!load_m;
                hazard=load_m;
                data=data_m;
            end else if(valid_w==1&&execute_reg==dest_w&&!(dest_w==0))begin
                forward=1;
                hazard=0;
                data=data_w;
            end else begin
                forward=0;
                hazard=0;
                data=0;
            end
        end else begin
            forward=0;
            hazard=0;
            data=0;
        end
    end

endmodule
