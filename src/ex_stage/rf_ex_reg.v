module rf_ex_reg #(
    parameter DataWidth  = 32,
    parameter TotalNumBank = 8,
    parameter AddrWidth = 5
) (
    input                          clk, rstn, sclr,
    input                          des_sat_r,
    input [3:0]                    des_mask_r,
    input [(TotalNumBank-1):0]     writeEn_r,
    input [(AddrWidth-1):0]        writeAddr_r,
    input [16:0]                   fp_opcode_r,
    input                          fp_en_r,
    input [2:0]                    fp_rm_r,
    input                          op1_negate_r, op1_abs_r,
    input                          op2_negate_r, op2_abs_r,
    input                          op3_negate_r, op3_abs_r,
    input                          ALUSrc_r,
    input [(DataWidth*4)-1:0]      readData1, readData2, readData3, imm_r,
    input                          pipe_r,
    input [(TotalNumBank-1):0]     readEn1_r, readEn2_r, readEn3_r,
    input [(AddrWidth-1):0]        readAddr1_r, readAddr2_r, readAddr3_r,
    output                         des_sat_e,
    output [3:0]                   des_mask_e,
    output [(TotalNumBank-1):0]    writeEn_e,
    output [(AddrWidth-1):0]       writeAddr_e,
    output [16:0]                  fp_opcode_e,
    output                         fp_en_e,
    output [2:0]                   fp_rm_e,
    output                         op1_negate_e, op1_abs_e,
    output                         op2_negate_e, op2_abs_e,
    output                         op3_negate_e, op3_abs_e,
    output                         ALUSrc_e,
    output reg [(DataWidth*4)-1:0] readData1_e, readData2_e, readData3_e,
    output [(DataWidth*4)-1:0]     imm_e,
    output                         pipe_e,
    output [(TotalNumBank-1):0]    readEn1_e, readEn2_e, readEn3_e,
    output [(AddrWidth-1):0]       readAddr1_e, readAddr2_e, readAddr3_e
);

    reg [(33+4*TotalNumBank+4*AddrWidth+4*DataWidth):0] temp;

    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            temp <= {(34+4*TotalNumBank+4*AddrWidth+4*DataWidth){1'b0}};
            {readData1_e, readData2_e, readData3_e} <= {(12*DataWidth){1'bz}};
        end
        else if (sclr) begin
            temp <= {(34+4*TotalNumBank+4*AddrWidth+4*DataWidth){1'b0}};
            {readData1_e, readData2_e, readData3_e} <= {(12*DataWidth){1'bz}};
        end
        else begin
            temp <= {des_sat_r, des_mask_r, writeEn_r, writeAddr_r, fp_opcode_r, fp_en_r, fp_rm_r, op1_negate_r, op1_abs_r, op2_negate_r, op2_abs_r, op3_negate_r, op3_abs_r, ALUSrc_r, imm_r, pipe_r, readEn1_r, readEn2_r, readEn3_r, readAddr1_r, readAddr2_r, readAddr3_r};
            {readData1_e, readData2_e, readData3_e} <= {readData1, readData2, readData3};
        end
    end

    assign {des_sat_e, des_mask_e, writeEn_e, writeAddr_e, fp_opcode_e, fp_en_e, fp_rm_e, op1_negate_e, op1_abs_e, op2_negate_e, op2_abs_e, op3_negate_e, op3_abs_e, ALUSrc_e, imm_e, pipe_e, readEn1_e, readEn2_e, readEn3_e, readAddr1_e, readAddr2_e, readAddr3_e} = temp;

endmodule