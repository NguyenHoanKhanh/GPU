module decode_rf_reg #(
    parameter TotalNumBank = 8,
    parameter AddrWidth = 5
) (
    input                       clk, rstn, en,
    input                       op1_negate, op1_abs,
    input [7:0]                 op1_swizzle,
    input                       op2_negate, op2_abs,
    input [7:0]                 op2_swizzle,
    input                       op3_negate, op3_abs,
    input [7:0]                 op3_swizzle,
    input                       des_sat,
    input [3:0]                 des_mask,
    input [16:0]                fp_opcode_d,
    input                       fp_en_d,
    input [2:0]                 fp_rm_d,
    input [(TotalNumBank-1):0]  writeEn_d,
    input [(AddrWidth-1):0]     writeAddr_d,
    input                       ALUSrc_d,
    input [(TotalNumBank-1):0]  readEn1_d, readEn2_d, readEn3_d,
    input [(AddrWidth-1):0]     readAddr1_d, readAddr2_d, readAddr3_d,
    input [31:0]                imm,
    input                       pipe_d,
    output                      op1_negate_r, op1_abs_r,
    output [7:0]                op1_swizzle_r,
    output                      op2_negate_r, op2_abs_r,
    output [7:0]                op2_swizzle_r,
    output                      op3_negate_r, op3_abs_r,
    output [7:0]                op3_swizzle_r,
    output                      des_sat_r,
    output [3:0]                des_mask_r,
    output [16:0]               fp_opcode_r,
    output                      fp_en_r,
    output [2:0]                fp_rm_r,
    output [(TotalNumBank-1):0] writeEn_r,
    output [(AddrWidth-1):0]    writeAddr_r,
    output                      ALUSrc_r,
    output [(TotalNumBank-1):0] readEn1_r, readEn2_r, readEn3_r,
    output [(AddrWidth-1):0]    readAddr1_r, readAddr2_r, readAddr3_r,
    output [31:0]               imm_r,
    output                      pipe_r
);

    reg [(89+4*TotalNumBank+4*AddrWidth):0] temp;

    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            temp <= {(90+4*TotalNumBank+4*AddrWidth){1'b0}};
        end
        else if (en) begin
            temp <= {op1_negate, op1_abs, op1_swizzle, op2_negate, op2_abs, op2_swizzle, op3_negate, op3_abs, op3_swizzle, des_sat, des_mask, fp_opcode_d, fp_en_d, fp_rm_d, writeEn_d, writeAddr_d, ALUSrc_d, readEn1_d, readEn2_d, readEn3_d, readAddr1_d, readAddr2_d, readAddr3_d, imm, pipe_d};
        end
        else begin
            temp <= temp;
        end
    end

    assign {op1_negate_r, op1_abs_r, op1_swizzle_r, op2_negate_r, op2_abs_r, op2_swizzle_r, op3_negate_r, op3_abs_r, op3_swizzle_r, des_sat_r, des_mask_r, fp_opcode_r, fp_en_r, fp_rm_r, writeEn_r, writeAddr_r, ALUSrc_r, readEn1_r, readEn2_r, readEn3_r, readAddr1_r, readAddr2_r, readAddr3_r, imm_r, pipe_r} = temp;

endmodule