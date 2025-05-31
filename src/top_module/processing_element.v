
module PE #(
    parameter DataWidth  = 32,
    parameter TotalNumBank = 2,
    parameter AddrWidth = 5
) (
    `ifdef PE_SoC
        input                       clk, rstn,
        input [127:0]               instr_in,
        output [(DataWidth*4)-1:0]  data_out,
        output [3:0]                ready_out,
        output [9:0]                instr_addr_out
    `else
        input clk, rstn
    `endif
);
    
    wire [9:0] pc_out, next_pc;
    `ifndef PE_SoC
        wire [9:0] instr_addr;
        wire [127:0] instr;
    `else
        wire [9:0] instr_addr_temp;
    `endif
    wire [127:0] instr_d;
    wire stall_f, stall_d, stall_r;
    wire flush_e, flush_e_1, flush_e_2;
    wire fwd1, fwd2, fwd3;
    wire [(TotalNumBank-1):0] readEn1, readEn2, readEn3;
    wire [4:0] readAddr1, readAddr2, readAddr3;
    wire [16:0] fp_opcode;
    wire fp_en, ALUSrc;
    wire [2:0] fp_rm;
    wire [(TotalNumBank-1):0] writeEn;
    wire [4:0] writeAddr;
    wire pipe;

    wire op1_negate_r, op1_abs_r;
    wire [7:0] op1_swizzle_r;
    wire op2_negate_r, op2_abs_r;
    wire [7:0] op2_swizzle_r;
    wire op3_negate_r, op3_abs_r;
    wire [7:0] op3_swizzle_r;
    wire des_sat_r;
    wire [3:0] des_mask_r;
    wire [16:0] fp_opcode_r;
    wire fp_en_r;
    wire [2:0] fp_rm_r;
    wire [(TotalNumBank-1):0] writeEn_r;
    wire [(AddrWidth-1):0] writeAddr_r;
    wire ALUSrc_r;
    wire [(TotalNumBank-1):0] readEn1_r, readEn2_r, readEn3_r;
    wire [(AddrWidth-1):0] readAddr1_r, readAddr2_r, readAddr3_r;
    wire [31:0] imm_r;
    wire pipe_r;

    wire [(DataWidth*4)-1:0] readData1, readData2, readData3;

    wire des_sat_e;
    wire [3:0] des_mask_e;
    wire [(TotalNumBank-1):0] writeEn_e;
    wire [(AddrWidth-1):0] writeAddr_e;
    wire [16:0] fp_opcode_e;
    wire fp_en_e;
    wire [2:0] fp_rm_e;
    wire op1_negate_e, op1_abs_e;
    wire op2_negate_e, op2_abs_e;
    wire op3_negate_e, op3_abs_e;
    wire ALUSrc_e;
    wire [(DataWidth*4)-1:0] readData1_e, readData2_e, readData3_e, imm_e;
    wire pipe_e;

    wire en_abs[0:2], en_negate[0:2];
    wire [(DataWidth*4)-1:0] data_in_neg_abs[0:2];
    wire [(DataWidth-1):0] data_out_neg_abs_0[0:2];
    wire [(DataWidth-1):0] data_out_neg_abs_1[0:2];
    wire [(DataWidth-1):0] data_out_neg_abs_2[0:2];
    wire [(DataWidth-1):0] data_out_neg_abs_3[0:2];
    wire [(DataWidth-1):0] data_in_fpu_1[0:3];
    wire [(DataWidth-1):0] data_in_fpu_2[0:3];
    wire [(DataWidth-1):0] data_in_fpu_3[0:3];
    wire [(DataWidth-1):0] res[0:3];
    wire [4:0] flags[0:3];
    `ifdef PE_SoC
        wire ready[0:3], ready_e_2[0:3], ready_e_out[0:3];
        wire [3:0] ready_final;
    `endif

    wire des_sat_e_2;
    wire [3:0] des_mask_e_2;
    wire [(TotalNumBank-1):0] writeEn_e_2;
    wire [(AddrWidth-1):0] writeAddr_e_2;
    wire pipe_e_2;
    wire [(DataWidth-1):0] res_e_2[0:3];
    wire [4:0] flags_e_2[0:3];
    wire des_sat_out;
    wire [3:0] des_mask_out;
    wire [(TotalNumBank-1):0] writeEn_out;
    wire [(AddrWidth-1):0] writeAddr_out;
    wire pipe_out;
    wire [(DataWidth-1):0] res_out[0:3];
    wire [4:0] flags_out[0:3];

    wire [(DataWidth-1):0] res_final[0:3];
    wire [19:0] flags_final;

    wire des_sat_w;
    wire [3:0] des_mask_w;
    wire [(TotalNumBank-1):0] writeEn_w;
    wire [(AddrWidth-1):0] writeAddr_w;
    wire [(DataWidth-1):0] res_w[0:3];
    wire [(DataWidth*4)-1:0] data_2_rf;

    wire [(TotalNumBank-1):0] readEn1_e, readEn2_e, readEn3_e;
    wire [(AddrWidth-1):0] readAddr1_e, readAddr2_e, readAddr3_e;

    genvar rf_count, neg_abs_count, fpu_count;

    // Fetch stage
    add1 pc_add_1_block (
        `ifdef PE_SoC
            .pc_in(instr_addr_temp), 
        `else
            .pc_in(instr_addr), 
        `endif
        .pc_out(pc_out)
    );

    mux2_1 #(.DWIDTH(10)) pc_input_mux (
        .inpA(pc_out), 
        `ifdef PE_SoC
            .inpB(instr_addr_temp), 
        `else
            .inpB(instr_addr), 
        `endif
        .sel(stall_f),
        .outp(next_pc)
    );

    pc_reg pc_reg_block (
        .clk(clk), 
        .rstn(rstn), 
        .next_pc(next_pc), 
        `ifdef PE_SoC
            .pc(instr_addr_temp)
        `else
            .pc(instr_addr)
        `endif
    );

    `ifndef PE_SoC
        instr_rom instr_rom_block (
            .pc(instr_addr),
            .instr(instr)
        );
    `else
        assign instr_addr_out = instr_addr_temp;
    `endif

    // Decode stage
    fetch_decode_reg fetch_decode_reg_block (
        .clk(clk), 
        .rstn(rstn), 
        .en(~stall_d), 
        `ifdef PE_SoC
            .instr_f(instr_in), 
        `else
            .instr_f(instr), 
        `endif
        .instr_d(instr_d)
    );

    control_unit #(
        .TotalNumBank(TotalNumBank),
        .AddrWidth(AddrWidth)
    ) control_unit_block (
        .instr(instr_d),
        .fp_opcode(fp_opcode),
        .fp_en(fp_en),
        .fp_rm(fp_rm),
        .writeEn(writeEn),
        .writeAddr(writeAddr),
        .pipe(pipe),
        .ALUSrc(ALUSrc)
    );

    reg_dec #(
        .TotalNumBank(TotalNumBank),
        .AddrWidth(AddrWidth)
    ) reg_dec_block (
        .instr(instr_d),
        .readEn1(readEn1),
        .readEn2(readEn2),
        .readEn3(readEn3),
        .readAddr1(readAddr1),
        .readAddr2(readAddr2),
        .readAddr3(readAddr3)
    );

    // RF stage
    decode_rf_reg #(
        .TotalNumBank(TotalNumBank),
        .AddrWidth(AddrWidth)
    ) decode_rf_reg_block (
        .clk(clk), 
        .rstn(rstn), 
        .en(~stall_r),
        .op1_negate(instr_d[20]), 
        .op1_abs(instr_d[21]),
        .op1_swizzle(instr_d[79:72]),
        .op2_negate(instr_d[25]), 
        .op2_abs(instr_d[26]),
        .op2_swizzle(instr_d[103:96]),
        .op3_negate(instr_d[30]), 
        .op3_abs(instr_d[31]),
        .op3_swizzle(instr_d[119:112]),
        .des_sat(instr_d[35]),
        .des_mask(instr_d[39:36]),
        .fp_opcode_d(fp_opcode),
        .fp_en_d(fp_en),
        .fp_rm_d(fp_rm),
        .writeEn_d(writeEn),
        .writeAddr_d(writeAddr),
        .ALUSrc_d(ALUSrc),
        .readEn1_d(readEn1), 
        .readEn2_d(readEn2), 
        .readEn3_d(readEn3),
        .readAddr1_d(readAddr1), 
        .readAddr2_d(readAddr2), 
        .readAddr3_d(readAddr3),
        .imm(instr_d[127:96]),
        .pipe_d(pipe),
        .op1_negate_r(op1_negate_r), 
        .op1_abs_r(op1_abs_r),
        .op1_swizzle_r(op1_swizzle_r),
        .op2_negate_r(op2_negate_r), 
        .op2_abs_r(op2_abs_r),
        .op2_swizzle_r(op2_swizzle_r),
        .op3_negate_r(op3_negate_r), 
        .op3_abs_r(op3_abs_r),
        .op3_swizzle_r(op3_swizzle_r),
        .des_sat_r(des_sat_r),
        .des_mask_r(des_mask_r),
        .fp_opcode_r(fp_opcode_r),
        .fp_en_r(fp_en_r),
        .fp_rm_r(fp_rm_r),
        .writeEn_r(writeEn_r),
        .writeAddr_r(writeAddr_r),
        .ALUSrc_r(ALUSrc_r),
        .readEn1_r(readEn1_r), 
        .readEn2_r(readEn2_r), 
        .readEn3_r(readEn3_r),
        .readAddr1_r(readAddr1_r), 
        .readAddr2_r(readAddr2_r), 
        .readAddr3_r(readAddr3_r),
        .imm_r(imm_r),
        .pipe_r(pipe_r)
    );

    generate
        for (rf_count = 0; rf_count < (TotalNumBank/2); rf_count = rf_count + 1) begin: rf_loop
            reg_file param_reg_file (
                .clk(clk),
                .rstn(rstn),
                .writeEn(writeEn_w[rf_count]),
                .writeAddr(writeAddr_w),
                .writeData(data_2_rf),
                .writeMask(des_mask_w),
                .readEn1(readEn1_r[rf_count]),
                .readEn2(readEn2_r[rf_count]),
                .readEn3(readEn3_r[rf_count]),
                .readAddr1(readAddr1_r),
                .readAddr2(readAddr2_r),
                .readAddr3(readAddr3_r),
                .readSwizzle1(op1_swizzle_r),
                .readSwizzle2(op2_swizzle_r),
                .readSwizzle3(op3_swizzle_r),
                .readData1(readData1),
                .readData2(readData2),
                .readData3(readData3)
            );

            reg_file temp_reg_file (
                .clk(clk),
                .rstn(rstn),
                .writeEn(writeEn_w[rf_count+(TotalNumBank/2)]),
                .writeAddr(writeAddr_w),
                .writeData(data_2_rf),
                .writeMask(des_mask_w),
                .readEn1(readEn1_r[rf_count+(TotalNumBank/2)]),
                .readEn2(readEn2_r[rf_count+(TotalNumBank/2)]),
                .readEn3(readEn3_r[rf_count+(TotalNumBank/2)]),
                .readAddr1(readAddr1_r),
                .readAddr2(readAddr2_r),
                .readAddr3(readAddr3_r),
                .readSwizzle1(op1_swizzle_r),
                .readSwizzle2(op2_swizzle_r),
                .readSwizzle3(op3_swizzle_r),
                .readData1(readData1),
                .readData2(readData2),
                .readData3(readData3)
            );
        end
    endgenerate

    // Execute stage
    rf_ex_reg #(
        .DataWidth(DataWidth),
        .TotalNumBank(TotalNumBank),
        .AddrWidth(AddrWidth)
    ) rf_ex_reg_block (
        .clk(clk), 
        .rstn(rstn), 
        .sclr(flush_e),
        .des_sat_r(des_sat_r),
        .des_mask_r(des_mask_r),
        .writeEn_r(writeEn_r),
        .writeAddr_r(writeAddr_r),
        .fp_opcode_r(fp_opcode_r),
        .fp_en_r(fp_en_r),
        .fp_rm_r(fp_rm_r),
        .op1_negate_r(op1_negate_r), 
        .op1_abs_r(op1_abs_r),
        .op2_negate_r(op2_negate_r), 
        .op2_abs_r(op2_abs_r),
        .op3_negate_r(op3_negate_r), 
        .op3_abs_r(op3_abs_r),
        .ALUSrc_r(ALUSrc_r),
        .readData1(readData1), 
        .readData2(readData2), 
        .readData3(readData3), 
        .imm_r({4{imm_r}}),
        .pipe_r(pipe_r),
        .readEn1_r(readEn1_r), 
        .readEn2_r(readEn2_r), 
        .readEn3_r(readEn3_r),
        .readAddr1_r(readAddr1_r), 
        .readAddr2_r(readAddr2_r), 
        .readAddr3_r(readAddr3_r),
        .des_sat_e(des_sat_e),
        .des_mask_e(des_mask_e),
        .writeEn_e(writeEn_e),
        .writeAddr_e(writeAddr_e),
        .fp_opcode_e(fp_opcode_e),
        .fp_en_e(fp_en_e),
        .fp_rm_e(fp_rm_e),
        .op1_negate_e(op1_negate_e), 
        .op1_abs_e(op1_abs_e),
        .op2_negate_e(op2_negate_e), 
        .op2_abs_e(op2_abs_e),
        .op3_negate_e(op3_negate_e), 
        .op3_abs_e(op3_abs_e),
        .ALUSrc_e(ALUSrc_e),
        .readData1_e(readData1_e), 
        .readData2_e(readData2_e), 
        .readData3_e(readData3_e), 
        .imm_e(imm_e),
        .pipe_e(pipe_e),
        .readEn1_e(readEn1_e), 
        .readEn2_e(readEn2_e), 
        .readEn3_e(readEn3_e),
        .readAddr1_e(readAddr1_e), 
        .readAddr2_e(readAddr2_e), 
        .readAddr3_e(readAddr3_e)
    );

    mux2_1 #(.DWIDTH(128)) negabs1_input_mux (
        .inpA(readData1_e), 
        .inpB(data_2_rf), 
        .sel(fwd1),
        .outp(data_in_neg_abs[0])
    );

    mux3_1 #(.DWIDTH(128)) negabs2_input_mux (
        .inpA(readData2_e),
        .inpB(imm_e),
        .inpC(data_2_rf),
        .sel({fwd2, ALUSrc_e}),
        .outp(data_in_neg_abs[1])
    );

    mux2_1 #(.DWIDTH(128)) negabs3_input_mux (
        .inpA(readData3_e), 
        .inpB(data_2_rf), 
        .sel(fwd3),
        .outp(data_in_neg_abs[2])
    );

    assign en_abs[0] = op1_abs_e;
    assign en_abs[1] = op2_abs_e;
    assign en_abs[2] = op3_abs_e;
    assign en_negate[0] = op1_negate_e;
    assign en_negate[1] = op2_negate_e;
    assign en_negate[2] = op3_negate_e;

    generate
        for (neg_abs_count = 0; neg_abs_count < 3; neg_abs_count = neg_abs_count + 1) begin: neg_abs_loop
            neg_abs neg_abs_block (
                .data_in(data_in_neg_abs[neg_abs_count]),
                .en_neg(en_negate[neg_abs_count]),
                .en_abs(en_abs[neg_abs_count]),
                .data_out_0(data_out_neg_abs_0[neg_abs_count]),
                .data_out_1(data_out_neg_abs_1[neg_abs_count]),
                .data_out_2(data_out_neg_abs_2[neg_abs_count]),
                .data_out_3(data_out_neg_abs_3[neg_abs_count])
            );
        end
    endgenerate

    assign data_in_fpu_1[0] = data_out_neg_abs_0[0];
    assign data_in_fpu_1[1] = data_out_neg_abs_1[0];
    assign data_in_fpu_1[2] = data_out_neg_abs_2[0];
    assign data_in_fpu_1[3] = data_out_neg_abs_3[0];
    assign data_in_fpu_2[0] = data_out_neg_abs_0[1];
    assign data_in_fpu_2[1] = data_out_neg_abs_1[1];
    assign data_in_fpu_2[2] = data_out_neg_abs_2[1];
    assign data_in_fpu_2[3] = data_out_neg_abs_3[1];
    assign data_in_fpu_3[0] = data_out_neg_abs_0[2];
    assign data_in_fpu_3[1] = data_out_neg_abs_1[2];
    assign data_in_fpu_3[2] = data_out_neg_abs_2[2];
    assign data_in_fpu_3[3] = data_out_neg_abs_3[2];

    generate
        for (fpu_count = 0; fpu_count < 4; fpu_count = fpu_count + 1) begin: fpu_loop
            fp_unit fp_unit_block (
                .reset(rstn),
                .clock(clk),
                .fp_unit_i_data1(data_in_fpu_1[fpu_count]),
                .fp_unit_i_data2(data_in_fpu_2[fpu_count]),
                .fp_unit_i_data3(data_in_fpu_3[fpu_count]),
                .fp_unit_i_op_fmadd(fp_opcode_e[16]),
                .fp_unit_i_op_fmsub(fp_opcode_e[15]),
                .fp_unit_i_op_fnmadd(fp_opcode_e[14]),
                .fp_unit_i_op_fnmsub(fp_opcode_e[13]),
                .fp_unit_i_op_fadd(fp_opcode_e[12]),
                .fp_unit_i_op_fsub(fp_opcode_e[11]),
                .fp_unit_i_op_fmul(fp_opcode_e[10]),
                .fp_unit_i_op_fsgnj(fp_opcode_e[9]),
                .fp_unit_i_op_fcmp(fp_opcode_e[8]),
                .fp_unit_i_op_fmax(fp_opcode_e[7]),
                .fp_unit_i_op_fclass(fp_opcode_e[6]),
                .fp_unit_i_op_fmv_i2f(fp_opcode_e[5]),
                .fp_unit_i_op_fmv_f2i(fp_opcode_e[4]),
                .fp_unit_i_op_fcvt_i2f(fp_opcode_e[3]),
                .fp_unit_i_op_fcvt_f2i(fp_opcode_e[2]),
                .fp_unit_i_op_fcvt_op(fp_opcode_e[1:0]),
                .fp_unit_i_fmt(2'b00),
                .fp_unit_i_rm(fp_rm_e),
                .fp_unit_i_enable(fp_en_e),
                .fp_unit_o_result(res[fpu_count]),
                .fp_unit_o_flags(flags[fpu_count]),
                `ifdef PE_SoC
                    .fp_unit_o_ready(ready[fpu_count])
                `else
                    .fp_unit_o_ready()
                `endif
            );
        end
    endgenerate

    ex_pipeline_reg #(
        .DataWidth(DataWidth),
        .TotalNumBank(TotalNumBank),
        .AddrWidth(AddrWidth)
    ) ex_pipeline_reg_block_1 (
        .clk(clk), 
        .rstn(rstn), 
        .sclr(flush_e_1),
        .des_sat_e(des_sat_e),
        .des_mask_e(des_mask_e),
        .writeEn_e(writeEn_e),
        .writeAddr_e(writeAddr_e),
        .res0(res[0]), 
        .res1(res[1]), 
        .res2(res[2]), 
        .res3(res[3]),
        .flags0(flags[0]), 
        .flags1(flags[1]), 
        .flags2(flags[2]), 
        .flags3(flags[3]),
        `ifdef PE_SoC
            .ready0(ready[0]), 
            .ready1(ready[1]), 
            .ready2(ready[2]), 
            .ready3(ready[3]),
        `endif
        .pipe_e(pipe_e),
        .des_sat_o(des_sat_e_2),
        .des_mask_o(des_mask_e_2),
        .writeEn_o(writeEn_e_2),
        .writeAddr_o(writeAddr_e_2),
        .res0_o(res_e_2[0]), 
        .res1_o(res_e_2[1]), 
        .res2_o(res_e_2[2]), 
        .res3_o(res_e_2[3]),
        .flags0_o(flags_e_2[0]), 
        .flags1_o(flags_e_2[1]), 
        .flags2_o(flags_e_2[2]), 
        .flags3_o(flags_e_2[3]),
        `ifdef PE_SoC
            .ready0_o(ready_e_2[0]), 
            .ready1_o(ready_e_2[1]), 
            .ready2_o(ready_e_2[2]), 
            .ready3_o(ready_e_2[3]),
        `endif
        .pipe_o(pipe_e_2)
    ); 

    ex_pipeline_reg #(
        .DataWidth(DataWidth),
        .TotalNumBank(TotalNumBank),
        .AddrWidth(AddrWidth)
    ) ex_pipeline_reg_block_2 (
        .clk(clk), 
        .rstn(rstn), 
        .sclr(flush_e_2),
        .des_sat_e(des_sat_e_2),
        .des_mask_e(des_mask_e_2),
        .writeEn_e(writeEn_e_2),
        .writeAddr_e(writeAddr_e_2),
        .res0(res_e_2[0]), 
        .res1(res_e_2[1]), 
        .res2(res_e_2[2]), 
        .res3(res_e_2[3]),
        .flags0(flags_e_2[0]), 
        .flags1(flags_e_2[1]), 
        .flags2(flags_e_2[2]), 
        .flags3(flags_e_2[3]),
        `ifdef PE_SoC
            .ready0(ready_e_2[0]), 
            .ready1(ready_e_2[1]), 
            .ready2(ready_e_2[2]), 
            .ready3(ready_e_2[3]),
        `endif
        .pipe_e(pipe_e_2),
        .des_sat_o(des_sat_out),
        .des_mask_o(des_mask_out),
        .writeEn_o(writeEn_out),
        .writeAddr_o(writeAddr_out),
        .res0_o(res_out[0]), 
        .res1_o(res_out[1]), 
        .res2_o(res_out[2]), 
        .res3_o(res_out[3]),
        .flags0_o(flags_out[0]), 
        .flags1_o(flags_out[1]), 
        .flags2_o(flags_out[2]), 
        .flags3_o(flags_out[3]),
        `ifdef PE_SoC
            .ready0_o(ready_e_out[0]), 
            .ready1_o(ready_e_out[1]), 
            .ready2_o(ready_e_out[2]), 
            .ready3_o(ready_e_out[3]),
        `endif
        .pipe_o(pipe_out)
    ); 

    mux2_1 #(.DWIDTH(32)) fpu_res0_mux (
        .inpA(res_out[0]), 
        .inpB(res[0]), 
        .sel(pipe_out),
        .outp(res_final[0])
    );

    mux2_1 #(.DWIDTH(32)) fpu_res1_mux (
        .inpA(res_out[1]), 
        .inpB(res[1]), 
        .sel(pipe_out),
        .outp(res_final[1])
    );

    mux2_1 #(.DWIDTH(32)) fpu_res2_mux (
        .inpA(res_out[2]), 
        .inpB(res[2]), 
        .sel(pipe_out),
        .outp(res_final[2])
    );

    mux2_1 #(.DWIDTH(32)) fpu_res3_mux (
        .inpA(res_out[3]), 
        .inpB(res[3]), 
        .sel(pipe_out),
        .outp(res_final[3])
    );

    mux2_1 #(.DWIDTH(20)) fpu_flags_mux (
        .inpA({flags_out[3], flags_out[2], flags_out[1], flags_out[0]}), 
        .inpB({flags[3], flags[2], flags[1], flags[0]}), 
        .sel(pipe_out),
        .outp(flags_final)
    );

    `ifdef PE_SoC
        mux2_1 #(.DWIDTH(4)) fpu_ready_mux (
            .inpA({ready_e_out[3], ready_e_out[2], ready_e_out[1], ready_e_out[0]}), 
            .inpB({ready[3], ready[2], ready[1], ready[0]}), 
            .sel(pipe_out),
            .outp(ready_final)
        );
    `endif

    // Writeback stage
    ex_wb_reg #(
        .DataWidth(DataWidth),
        .TotalNumBank(TotalNumBank),
        .AddrWidth(AddrWidth)
    ) ex_wb_reg_block (
        .clk(clk), 
        .rstn(rstn),
        .des_sat(des_sat_out),
        .des_mask(des_mask_out),
        .writeEn(writeEn_out),
        .writeAddr(writeAddr_out),
        .res0(res_final[0]),
        .res1(res_final[1]),
        .res2(res_final[2]),
        .res3(res_final[3]),
        `ifdef PE_SoC
            .ready(ready_final),
        `endif
        .flags(flags_final),
        .des_sat_w(des_sat_w),
        .des_mask_w(des_mask_w),
        .writeEn_w(writeEn_w),
        .writeAddr_w(writeAddr_w),
        .res0_w(res_w[0]),
        .res1_w(res_w[1]),
        .res2_w(res_w[2]),
        .res3_w(res_w[3]),
        `ifdef PE_SoC
            .ready_w(ready_out),
        `endif
        .flags_w()
    );

    saturate_merge saturate_merge_block (
        .en_sat(des_sat_w),
        .data_res_0(res_w[0]),
        .data_res_1(res_w[1]),
        .data_res_2(res_w[2]),
        .data_res_3(res_w[3]),
        .data_2_rf(data_2_rf)
    );

    `ifdef PE_SoC
        assign data_out = data_2_rf;
    `endif

    hazard_unit #(.DataWidth(DataWidth), .TotalNumBank(TotalNumBank), .AddrWidth(AddrWidth)) hazard_unit_block (
        .readEn1_e(readEn1_e),
        .readEn2_e(readEn2_e),
        .readEn3_e(readEn3_e),
        .readAddr1_e(readAddr1_e),
        .readAddr2_e(readAddr2_e),
        .readAddr3_e(readAddr3_e),
        .writeEn_w(writeEn_w),
        .writeAddr_w(writeAddr_w),
        .writeEn_e(writeEn_e),
        .writeAddr_e(writeAddr_e),
        .writeEn_e_1(writeEn_e_2),
        .writeAddr_e_1(writeAddr_e_2),
        .writeEn_e_2(writeEn_out),
        .writeAddr_e_2(writeAddr_out),
        .readEn1_r(readEn1_r), 
        .readEn2_r(readEn2_r), 
        .readEn3_r(readEn3_r),
        .readAddr1_r(readAddr1_r), 
        .readAddr2_r(readAddr2_r), 
        .readAddr3_r(readAddr3_r),
        .stall_f(stall_f), 
        .stall_d(stall_d), 
        .stall_r(stall_r),
        .flush_e(flush_e), 
        .flush_e_1(flush_e_1), 
        .flush_e_2(flush_e_2), 
        .fwd1(fwd1), 
        .fwd2(fwd2), 
        .fwd3(fwd3)
    );

endmodule