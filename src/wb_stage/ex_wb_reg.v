module ex_wb_reg #(
    parameter DataWidth  = 32,
    parameter TotalNumBank = 8,
    parameter AddrWidth = 5
) (
    input                           clk, rstn,
    input                           des_sat,
    input [3:0]                     des_mask,
    input [(TotalNumBank-1):0]      writeEn,
    input [(AddrWidth-1):0]         writeAddr,
    input [(DataWidth-1):0]         res0,
    input [(DataWidth-1):0]         res1,
    input [(DataWidth-1):0]         res2,
    input [(DataWidth-1):0]         res3,
    `ifdef PE_SoC
        input [3:0]                 ready,
    `endif
    input [19:0]                    flags,
    output reg                      des_sat_w,
    output reg [3:0]                des_mask_w,
    output reg [(TotalNumBank-1):0] writeEn_w,
    output reg [(AddrWidth-1):0]    writeAddr_w,
    output reg [(DataWidth-1):0]    res0_w,
    output reg [(DataWidth-1):0]    res1_w,
    output reg [(DataWidth-1):0]    res2_w,
    output reg [(DataWidth-1):0]    res3_w,
    `ifdef PE_SoC
        output reg [3:0]            ready_w,
    `endif
    output reg [19:0]               flags_w
);
    `ifdef PE_SoC
        always @(posedge clk, negedge rstn) begin
            if (~rstn) begin
                {des_sat_w, des_mask_w, writeEn_w, writeAddr_w, res0_w, res1_w, res2_w, res3_w, ready_w, flags_w} <= 'd0;
            end
            else begin
                {des_sat_w, des_mask_w, writeEn_w, writeAddr_w, res0_w, res1_w, res2_w, res3_w, ready_w, flags_w} <= {des_sat, des_mask, writeEn, writeAddr, res0, res1, res2, res3, ready, flags};
            end
        end 
    `else
        always @(posedge clk, negedge rstn) begin
            if (~rstn) begin
                {des_sat_w, des_mask_w, writeEn_w, writeAddr_w, res0_w, res1_w, res2_w, res3_w, flags_w} <= 'd0;
            end
            else begin
                {des_sat_w, des_mask_w, writeEn_w, writeAddr_w, res0_w, res1_w, res2_w, res3_w, flags_w} <= {des_sat, des_mask, writeEn, writeAddr, res0, res1, res2, res3, flags};
            end
        end 
    `endif

endmodule