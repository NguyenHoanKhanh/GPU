module neg_abs (
    input [127:0] data_in,
    input         en_neg,
    input         en_abs,
    output [31:0] data_out_0,
    output [31:0] data_out_1,
    output [31:0] data_out_2,
    output [31:0] data_out_3
);

    reg [31:0] temp_data_0;
    reg [31:0] temp_data_1;
    reg [31:0] temp_data_2;
    reg [31:0] temp_data_3;
    
    always @(*) begin
        temp_data_0 = data_in[31:0];
        temp_data_1 = data_in[63:32];
        temp_data_2 = data_in[95:64];
        temp_data_3 = data_in[127:96];

        if ((en_abs == 1'b1) & (en_neg == 1'b0)) begin
            temp_data_0[31] = 1'b0;
            temp_data_1[31] = 1'b0;
            temp_data_2[31] = 1'b0;
            temp_data_3[31] = 1'b0;
        end
        else if ((en_abs == 1'b0) & (en_neg == 1'b1)) begin
            temp_data_0[31] = temp_data_0[31] ^ 1'b1;
            temp_data_1[31] = temp_data_1[31] ^ 1'b1;
            temp_data_2[31] = temp_data_2[31] ^ 1'b1;
            temp_data_3[31] = temp_data_3[31] ^ 1'b1;
        end
        else begin
            temp_data_0 = temp_data_0;
            temp_data_1 = temp_data_1;
            temp_data_2 = temp_data_2;
            temp_data_3 = temp_data_3;
        end 
    end

    assign data_out_0 = temp_data_0;
    assign data_out_1 = temp_data_1;
    assign data_out_2 = temp_data_2;
    assign data_out_3 = temp_data_3;

endmodule