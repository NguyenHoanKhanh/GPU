module saturate_merge (
    input           en_sat,
    input [31:0]    data_res_0,
    input [31:0]    data_res_1,
    input [31:0]    data_res_2,
    input [31:0]    data_res_3,
    output [127:0]  data_2_rf
);
    
    reg [31:0] temp_data_0;
    reg [31:0] temp_data_1;
    reg [31:0] temp_data_2;
    reg [31:0] temp_data_3;

    function [31:0] check_saturate(input [31:0] data);
        begin
            check_saturate = data;

            if (check_saturate[31] == 1'b1) begin
                check_saturate = 32'd0;
            end
            else if (check_saturate[30:23] >= 8'h7F) begin
                check_saturate = 32'h3F800000;
            end
            else begin
                check_saturate = check_saturate;
            end
        end
    endfunction

    always @(*) begin
        temp_data_0 = data_res_0;
        temp_data_1 = data_res_1;
        temp_data_2 = data_res_2;
        temp_data_3 = data_res_3;

        if (en_sat) begin
            temp_data_0 = check_saturate(temp_data_0);
            temp_data_1 = check_saturate(temp_data_1);
            temp_data_2 = check_saturate(temp_data_2);
            temp_data_3 = check_saturate(temp_data_3);
        end 
        else begin
            temp_data_0 = temp_data_0;
            temp_data_1 = temp_data_1;
            temp_data_2 = temp_data_2;
            temp_data_3 = temp_data_3;
        end   
    end

    assign data_2_rf = {temp_data_3, temp_data_2, temp_data_1, temp_data_0};
endmodule