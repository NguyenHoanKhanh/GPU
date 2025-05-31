
module fp_unit (
    input             reset,
    input             clock,
    input [31:0]      fp_unit_i_data1,
    input [31:0]      fp_unit_i_data2,
    input [31:0]      fp_unit_i_data3,
    input             fp_unit_i_op_fmadd,       // 16
    input             fp_unit_i_op_fmsub,       // 15
    input             fp_unit_i_op_fnmadd,      // 14
    input             fp_unit_i_op_fnmsub,      // 13
    input             fp_unit_i_op_fadd,        // 12
    input             fp_unit_i_op_fsub,        // 11
    input             fp_unit_i_op_fmul,        // 10
    input             fp_unit_i_op_fsgnj,       // 9
    input             fp_unit_i_op_fcmp,        // 8
    input             fp_unit_i_op_fmax,        // 7
    input             fp_unit_i_op_fclass,      // 6
    input             fp_unit_i_op_fmv_i2f,     // 5
    input             fp_unit_i_op_fmv_f2i,     // 4
    input             fp_unit_i_op_fcvt_i2f,    // 3
    input             fp_unit_i_op_fcvt_f2i,    // 2
    input [1:0]       fp_unit_i_op_fcvt_op,     // 1 0
    input [1:0]       fp_unit_i_fmt,
    input [2:0]       fp_unit_i_rm,
    input             fp_unit_i_enable,

    output [31:0]     fp_unit_o_result,
    output [4:0]      fp_unit_o_flags,
    output            fp_unit_o_ready
);

  wire [63:0] lzc1_64_i_a;
  wire [5:0] lzc1_64_o_c;
  wire lzc1_64_o_v;
  wire [63:0] lzc2_64_i_a;
  wire [5:0] lzc2_64_o_c;
  wire lzc2_64_o_v;
  wire [63:0] lzc3_64_i_a;
  wire [5:0] lzc3_64_o_c;
  wire lzc3_64_o_v;
  wire [63:0] lzc4_64_i_a;
  wire [5:0] lzc4_64_o_c;
  wire lzc4_64_o_v;

  wire [255:0] lzc_256_i_a;
  wire [7:0] lzc_256_o_c;
  wire lzc_256_o_v;

  wire [63:0] fp_ext1_i_data;
  wire [1:0]  fp_ext1_i_fmt;
  wire [64:0] fp_ext1_o_result;
  wire [9:0]  fp_ext1_o_classification;
  wire [63:0] fp_ext2_i_data;
  wire [1:0]  fp_ext2_i_fmt;
  wire [64:0] fp_ext2_o_result;
  wire [9:0]  fp_ext2_o_classification;
  wire [63:0] fp_ext3_i_data;
  wire [1:0]  fp_ext3_i_fmt;
  wire [64:0] fp_ext3_o_result;
  wire [9:0]  fp_ext3_o_classification;

  wire [64:0] fp_cmp_i_data1;
  wire [64:0] fp_cmp_i_data2;
  wire [2:0]  fp_cmp_i_rm;
  wire [9:0]  fp_cmp_i_class1;
  wire [9:0]  fp_cmp_i_class2;
  wire [63:0] fp_cmp_o_result;
  wire [4:0]  fp_cmp_o_flags;

  wire [63:0] fp_max_i_data1;
  wire [63:0] fp_max_i_data2;
  wire [64:0] fp_max_i_ext1;
  wire [64:0] fp_max_i_ext2;
  wire [1:0]  fp_max_i_fmt;
  wire [2:0]  fp_max_i_rm;
  wire [9:0]  fp_max_i_class1;
  wire [9:0]  fp_max_i_class2;
  wire [63:0] fp_max_o_result;
  wire [4:0]  fp_max_o_flags;

  wire [63:0] fp_sgnj_i_data1;
  wire [63:0] fp_sgnj_i_data2;
  wire [1:0]  fp_sgnj_i_fmt;
  wire [2:0]  fp_sgnj_i_rm;
  wire [63:0] fp_sgnj_o_result;
  
  wire [64:0] fp_fma_i_data1;
  wire [64:0] fp_fma_i_data2;
  wire [64:0] fp_fma_i_data3;
  wire [9:0] fp_fma_i_class1;
  wire [9:0] fp_fma_i_class2;
  wire [9:0] fp_fma_i_class3;
  wire fp_fma_i_op_fmadd;
  wire fp_fma_i_op_fmsub;
  wire fp_fma_i_op_fnmadd;
  wire fp_fma_i_op_fnmsub;
  wire fp_fma_i_op_fadd;
  wire fp_fma_i_op_fsub;
  wire fp_fma_i_op_fmul;
  wire [1:0] fp_fma_i_fmt;
  wire [2:0] fp_fma_i_rm;
  wire fp_fma_o_sig;
  wire [13:0] fp_fma_o_expo;
  wire [53:0] fp_fma_o_mant;
  wire [1:0] fp_fma_o_rema;
  wire [1:0] fp_fma_o_fmt;
  wire [2:0] fp_fma_o_rm;
  wire [2:0] fp_fma_o_grs;
  wire fp_fma_o_snan;
  wire fp_fma_o_qnan;
  wire fp_fma_o_dbz;
  wire fp_fma_o_infs;
  wire fp_fma_o_zero;
  wire fp_fma_o_diff;
  wire fp_fma_o_ready;

  wire fp_rnd_i_sig;
  wire [13:0] fp_rnd_i_expo;
  wire [53:0] fp_rnd_i_mant;
  wire [1:0] fp_rnd_i_rema;
  wire [1:0] fp_rnd_i_fmt;
  wire [2:0] fp_rnd_i_rm;
  wire [2:0] fp_rnd_i_grs;
  wire fp_rnd_i_snan;
  wire fp_rnd_i_qnan;
  wire fp_rnd_i_dbz;
  wire fp_rnd_i_infs;
  wire fp_rnd_i_zero;
  wire fp_rnd_i_diff;
  wire [63:0] fp_rnd_o_result;
  wire [4:0]  fp_rnd_o_flags;

  wire [64:0] fp_cvt_f2i_i_data;
  wire [1:0] fp_cvt_f2i_i_op_fcvt_op;
  wire [2:0] fp_cvt_f2i_i_rm;
  wire [9:0] fp_cvt_f2i_i_classification;
  wire [63:0] fp_cvt_f2i_o_result;
  wire [4:0]  fp_cvt_f2i_o_flags;

  wire [63:0] fp_cvt_i2f_i_data;
  wire [1:0] fp_cvt_i2f_i_op_fcvt_op;
  wire [1:0] fp_cvt_i2f_i_fmt;
  wire [2:0] fp_cvt_i2f_i_rm;
  wire fp_cvt_i2f_o_sig;
  wire [13:0] fp_cvt_i2f_o_expo;
  wire [53:0] fp_cvt_i2f_o_mant;
  wire [1:0] fp_cvt_i2f_o_rema;
  wire [1:0] fp_cvt_i2f_o_fmt;
  wire [2:0] fp_cvt_i2f_o_rm;
  wire [2:0] fp_cvt_i2f_o_grs;
  wire fp_cvt_i2f_o_snan;
  wire fp_cvt_i2f_o_qnan;
  wire fp_cvt_i2f_o_dbz;
  wire fp_cvt_i2f_o_infs;
  wire fp_cvt_i2f_o_zero;
  wire fp_cvt_i2f_o_diff;

  lzc_64 lzc_64_comp_1 (
      .a(lzc1_64_i_a),
      .c(lzc1_64_o_c),
      .v(lzc1_64_o_v)
  );

  lzc_64 lzc_64_comp_2 (
      .a(lzc2_64_i_a),
      .c(lzc2_64_o_c),
      .v(lzc2_64_o_v)
  );

  lzc_64 lzc_64_comp_3 (
      .a(lzc3_64_i_a),
      .c(lzc3_64_o_c),
      .v(lzc3_64_o_v)
  );

  lzc_64 lzc_64_comp_4 (
      .a(lzc4_64_i_a),
      .c(lzc4_64_o_c),
      .v(lzc4_64_o_v)
  );

  lzc_256 lzc_256_comp (
      .a(lzc_256_i_a),
      .c(lzc_256_o_c),
      .v(lzc_256_o_v)
  );

  fp_ext fp_ext_comp_1 (
      .fp_ext_i_data(fp_ext1_i_data),
      .fp_ext_i_fmt(fp_ext1_i_fmt),
      .fp_ext_o_result(fp_ext1_o_result),
      .fp_ext_o_classification(fp_ext1_o_classification),
      .lzc_o_c(lzc1_64_o_c),
      .lzc_i_a(lzc1_64_i_a)
  );

  fp_ext fp_ext_comp_2 (
      .fp_ext_i_data(fp_ext2_i_data),
      .fp_ext_i_fmt(fp_ext2_i_fmt),
      .fp_ext_o_result(fp_ext2_o_result),
      .fp_ext_o_classification(fp_ext2_o_classification),
      .lzc_o_c(lzc2_64_o_c),
      .lzc_i_a(lzc2_64_i_a)
  );

  fp_ext fp_ext_comp_3 (
      .fp_ext_i_data(fp_ext3_i_data),
      .fp_ext_i_fmt(fp_ext3_i_fmt),
      .fp_ext_o_result(fp_ext3_o_result),
      .fp_ext_o_classification(fp_ext3_o_classification),
      .lzc_o_c(lzc3_64_o_c),
      .lzc_i_a(lzc3_64_i_a)
  );

  fp_cmp fp_cmp_comp (
      .iData1(fp_cmp_i_data1),
      .iData2(fp_cmp_i_data2),
      .iRm(fp_cmp_i_rm),
      .iClass1(fp_cmp_i_class1),
      .iClass2(fp_cmp_i_class2),
      .oResult(fp_cmp_o_result),
      .oFlags(fp_cmp_o_flags)
  );

  fp_max fp_max_comp (
      .fp_max_i_data1(fp_max_i_data1),
      .fp_max_i_data2(fp_max_i_data2),
      .fp_max_i_ext1(fp_max_i_ext1),
      .fp_max_i_ext2(fp_max_i_ext2),
      .fp_max_i_fmt(fp_max_i_fmt),
      .fp_max_i_rm(fp_max_i_rm),
      .fp_max_i_class1(fp_max_i_class1),
      .fp_max_i_class2(fp_max_i_class2),
      .fp_max_o_result(fp_max_o_result),
      .fp_max_o_flags(fp_max_o_flags)
  );

  fp_sgnj fp_sgnj_comp (
      .fp_sgnj_i_data1(fp_sgnj_i_data1),
      .fp_sgnj_i_data2(fp_sgnj_i_data2),
      .fp_sgnj_i_fmt(fp_sgnj_i_fmt),
      .fp_sgnj_i_rm(fp_sgnj_i_rm),
      .fp_sgnj_o_result(fp_sgnj_o_result)
  );

  fp_cvt fp_cvt_comp (
      .iData_f2i(fp_cvt_f2i_i_data),
      .iFcvt_op_f2i(fp_cvt_f2i_i_op_fcvt_op),
      .iRm_f2i(fp_cvt_f2i_i_rm),
      .iClassification_f2i(fp_cvt_f2i_i_classification),
      .oResult_f2i(fp_cvt_f2i_o_result),
      .oFlags_f2i(fp_cvt_f2i_o_flags),
      .iData_i2f(fp_cvt_i2f_i_data),
      .iFcvt_op_i2f(fp_cvt_i2f_i_op_fcvt_op),
      .iFmt_i2f(fp_cvt_i2f_i_fmt),
      .iRm_i2f(fp_cvt_i2f_i_rm),
      .sig_i2f(fp_cvt_i2f_o_sig),
      .expo_i2f(fp_cvt_i2f_o_expo),
      .mant_i2f(fp_cvt_i2f_o_mant),
      .rema_i2f(fp_cvt_i2f_o_rema),
      .fmt_i2f(fp_cvt_i2f_o_fmt),
      .rm_i2f(fp_cvt_i2f_o_rm),
      .grs_i2f(fp_cvt_i2f_o_grs),
      .snan_i2f(fp_cvt_i2f_o_snan),
      .qnan_i2f(fp_cvt_i2f_o_qnan),
      .dbz_i2f(fp_cvt_i2f_o_dbz),
      .infs_i2f(fp_cvt_i2f_o_infs),
      .zero_i2f(fp_cvt_i2f_o_zero),
      .diff_i2f(fp_cvt_i2f_o_diff),
      .lzc_o_c(lzc4_64_o_c),
      .lzc_i_a(lzc4_64_i_a)
  );

  fp_fma fp_fma_comp (
      .reset(reset),
      .clock(clock),
      .fp_fma_i_data1(fp_fma_i_data1),
      .fp_fma_i_data2(fp_fma_i_data2),
      .fp_fma_i_data3(fp_fma_i_data3),
      .fp_fma_i_class1(fp_fma_i_class1),
      .fp_fma_i_class2(fp_fma_i_class2),
      .fp_fma_i_class3(fp_fma_i_class3),
      .fp_fma_i_op_fmadd(fp_fma_i_op_fmadd),
      .fp_fma_i_op_fmsub(fp_fma_i_op_fmsub),
      .fp_fma_i_op_fnmadd(fp_fma_i_op_fnmadd),
      .fp_fma_i_op_fnmsub(fp_fma_i_op_fnmsub),
      .fp_fma_i_op_fadd(fp_fma_i_op_fadd),
      .fp_fma_i_op_fsub(fp_fma_i_op_fsub),
      .fp_fma_i_op_fmul(fp_fma_i_op_fmul),
      .fp_fma_i_fmt(fp_fma_i_fmt),
      .fp_fma_i_rm(fp_fma_i_rm),
      .fp_fma_o_sig(fp_fma_o_sig),
      .fp_fma_o_expo(fp_fma_o_expo),
      .fp_fma_o_mant(fp_fma_o_mant),
      .fp_fma_o_rema(fp_fma_o_rema),
      .fp_fma_o_fmt(fp_fma_o_fmt),
      .fp_fma_o_rm(fp_fma_o_rm),
      .fp_fma_o_grs(fp_fma_o_grs),
      .fp_fma_o_snan(fp_fma_o_snan),
      .fp_fma_o_qnan(fp_fma_o_qnan),
      .fp_fma_o_dbz(fp_fma_o_dbz),
      .fp_fma_o_infs(fp_fma_o_infs),
      .fp_fma_o_zero(fp_fma_o_zero),
      .fp_fma_o_diff(fp_fma_o_diff),
      .fp_fma_o_ready(fp_fma_o_ready),
      .lzc_o_c(lzc_256_o_c),
      .lzc_i_a(lzc_256_i_a)
  );

  fp_rnd fp_rnd_comp (
      .fp_rnd_i_sig(fp_rnd_i_sig),
      .fp_rnd_i_expo(fp_rnd_i_expo),
      .fp_rnd_i_mant(fp_rnd_i_mant),
      .fp_rnd_i_rema(fp_rnd_i_rema),
      .fp_rnd_i_fmt(fp_rnd_i_fmt),
      .fp_rnd_i_rm(fp_rnd_i_rm),
      .fp_rnd_i_grs(fp_rnd_i_grs),
      .fp_rnd_i_snan(fp_rnd_i_snan),
      .fp_rnd_i_qnan(fp_rnd_i_qnan),
      .fp_rnd_i_dbz(fp_rnd_i_dbz),
      .fp_rnd_i_infs(fp_rnd_i_infs),
      .fp_rnd_i_zero(fp_rnd_i_zero),
      .fp_rnd_i_diff(fp_rnd_i_diff),
      .fp_rnd_o_result(fp_rnd_o_result),
      .fp_rnd_o_flags(fp_rnd_o_flags)
  );

  fp_exe fp_exe_comp (
      .fp_exe_i_data1({32'd0, fp_unit_i_data1}),
      .fp_exe_i_data2({32'd0, fp_unit_i_data2}),
      .fp_exe_i_data3({32'd0, fp_unit_i_data3}),
      .fp_exe_i_op_fmadd(fp_unit_i_op_fmadd),
      .fp_exe_i_op_fmsub(fp_unit_i_op_fmsub),
      .fp_exe_i_op_fnmadd(fp_unit_i_op_fnmadd),
      .fp_exe_i_op_fnmsub(fp_unit_i_op_fnmsub),
      .fp_exe_i_op_fadd(fp_unit_i_op_fadd),
      .fp_exe_i_op_fsub(fp_unit_i_op_fsub),
      .fp_exe_i_op_fmul(fp_unit_i_op_fmul),
      .fp_exe_i_op_fsgnj(fp_unit_i_op_fsgnj),
      .fp_exe_i_op_fcmp(fp_unit_i_op_fcmp),
      .fp_exe_i_op_fmax(fp_unit_i_op_fmax),
      .fp_exe_i_op_fclass(fp_unit_i_op_fclass),
      .fp_exe_i_op_fmv_i2f(fp_unit_i_op_fmv_i2f),
      .fp_exe_i_op_fmv_f2i(fp_unit_i_op_fmv_f2i),
      .fp_exe_i_op_fcvt_i2f(fp_unit_i_op_fcvt_i2f),
      .fp_exe_i_op_fcvt_f2i(fp_unit_i_op_fcvt_f2i),
      .fp_exe_i_op_fcvt_op(fp_unit_i_op_fcvt_op),
      .fp_exe_i_fmt(fp_unit_i_fmt),
      .fp_exe_i_rm(fp_unit_i_rm),
      .fp_exe_i_enable(fp_unit_i_enable),
      .fp_exe_o_result(fp_unit_o_result),
      .fp_exe_o_flags(fp_unit_o_flags),
      .fp_exe_o_ready(fp_unit_o_ready),
      .fp_ext1_o_result(fp_ext1_o_result),
      .fp_ext1_o_classification(fp_ext1_o_classification),
      .fp_ext1_i_data(fp_ext1_i_data),
      .fp_ext1_i_fmt(fp_ext1_i_fmt),
      .fp_ext2_o_result(fp_ext2_o_result),
      .fp_ext2_o_classification(fp_ext2_o_classification),
      .fp_ext2_i_data(fp_ext2_i_data),
      .fp_ext2_i_fmt(fp_ext2_i_fmt),
      .fp_ext3_o_result(fp_ext3_o_result),
      .fp_ext3_o_classification(fp_ext3_o_classification),
      .fp_ext3_i_data(fp_ext3_i_data),
      .fp_ext3_i_fmt(fp_ext3_i_fmt),
      .fp_cmp_o_result(fp_cmp_o_result),
      .fp_cmp_o_flags(fp_cmp_o_flags),
      .fp_cmp_i_data1(fp_cmp_i_data1),
      .fp_cmp_i_data2(fp_cmp_i_data2),
      .fp_cmp_i_rm(fp_cmp_i_rm),
      .fp_cmp_i_class1(fp_cmp_i_class1),
      .fp_cmp_i_class2(fp_cmp_i_class2),
      .fp_max_o_result(fp_max_o_result),
      .fp_max_o_flags(fp_max_o_flags),
      .fp_max_i_data1(fp_max_i_data1),
      .fp_max_i_data2(fp_max_i_data2),
      .fp_max_i_ext1(fp_max_i_ext1),
      .fp_max_i_ext2(fp_max_i_ext2),
      .fp_max_i_fmt(fp_max_i_fmt),
      .fp_max_i_rm(fp_max_i_rm),
      .fp_max_i_class1(fp_max_i_class1),
      .fp_max_i_class2(fp_max_i_class2),
      .fp_sgnj_o_result(fp_sgnj_o_result),
      .fp_sgnj_i_data1(fp_sgnj_i_data1),
      .fp_sgnj_i_data2(fp_sgnj_i_data2),
      .fp_sgnj_i_fmt(fp_sgnj_i_fmt),
      .fp_sgnj_i_rm(fp_sgnj_i_rm),
      .fp_cvt_f2i_i_data(fp_cvt_f2i_i_data),
      .fp_cvt_f2i_i_op_fcvt_op(fp_cvt_f2i_i_op_fcvt_op),
      .fp_cvt_f2i_i_rm(fp_cvt_f2i_i_rm),
      .fp_cvt_f2i_i_classification(fp_cvt_f2i_i_classification),
      .fp_cvt_f2i_o_result(fp_cvt_f2i_o_result),
      .fp_cvt_f2i_o_flags(fp_cvt_f2i_o_flags),
      .fp_cvt_i2f_i_data(fp_cvt_i2f_i_data),
      .fp_cvt_i2f_i_op_fcvt_op(fp_cvt_i2f_i_op_fcvt_op),
      .fp_cvt_i2f_i_fmt(fp_cvt_i2f_i_fmt),
      .fp_cvt_i2f_i_rm(fp_cvt_i2f_i_rm),
      .fp_cvt_i2f_o_sig(fp_cvt_i2f_o_sig),
      .fp_cvt_i2f_o_expo(fp_cvt_i2f_o_expo),
      .fp_cvt_i2f_o_mant(fp_cvt_i2f_o_mant),
      .fp_cvt_i2f_o_rema(fp_cvt_i2f_o_rema),
      .fp_cvt_i2f_o_fmt(fp_cvt_i2f_o_fmt),
      .fp_cvt_i2f_o_rm(fp_cvt_i2f_o_rm),
      .fp_cvt_i2f_o_grs(fp_cvt_i2f_o_grs),
      .fp_cvt_i2f_o_snan(fp_cvt_i2f_o_snan),
      .fp_cvt_i2f_o_qnan(fp_cvt_i2f_o_qnan),
      .fp_cvt_i2f_o_dbz(fp_cvt_i2f_o_dbz),
      .fp_cvt_i2f_o_infs(fp_cvt_i2f_o_infs),
      .fp_cvt_i2f_o_zero(fp_cvt_i2f_o_zero),
      .fp_cvt_i2f_o_diff(fp_cvt_i2f_o_diff),
      .fp_fma_o_sig(fp_fma_o_sig),
      .fp_fma_o_expo(fp_fma_o_expo),
      .fp_fma_o_mant(fp_fma_o_mant),
      .fp_fma_o_rema(fp_fma_o_rema),
      .fp_fma_o_fmt(fp_fma_o_fmt),
      .fp_fma_o_rm(fp_fma_o_rm),
      .fp_fma_o_grs(fp_fma_o_grs),
      .fp_fma_o_snan(fp_fma_o_snan),
      .fp_fma_o_qnan(fp_fma_o_qnan),
      .fp_fma_o_dbz(fp_fma_o_dbz),
      .fp_fma_o_infs(fp_fma_o_infs),
      .fp_fma_o_zero(fp_fma_o_zero),
      .fp_fma_o_diff(fp_fma_o_diff),
      .fp_fma_o_ready(fp_fma_o_ready),
      .fp_fma_i_data1(fp_fma_i_data1),
      .fp_fma_i_data2(fp_fma_i_data2),
      .fp_fma_i_data3(fp_fma_i_data3),
      .fp_fma_i_class1(fp_fma_i_class1),
      .fp_fma_i_class2(fp_fma_i_class2),
      .fp_fma_i_class3(fp_fma_i_class3),
      .fp_fma_i_op_fmadd(fp_fma_i_op_fmadd),
      .fp_fma_i_op_fmsub(fp_fma_i_op_fmsub),
      .fp_fma_i_op_fnmadd(fp_fma_i_op_fnmadd),
      .fp_fma_i_op_fnmsub(fp_fma_i_op_fnmsub),
      .fp_fma_i_op_fadd(fp_fma_i_op_fadd),
      .fp_fma_i_op_fsub(fp_fma_i_op_fsub),
      .fp_fma_i_op_fmul(fp_fma_i_op_fmul),
      .fp_fma_i_fmt(fp_fma_i_fmt),
      .fp_fma_i_rm(fp_fma_i_rm),
      .fp_rnd_o_result(fp_rnd_o_result),
      .fp_rnd_o_flags(fp_rnd_o_flags),
      .fp_rnd_i_sig(fp_rnd_i_sig),
      .fp_rnd_i_expo(fp_rnd_i_expo),
      .fp_rnd_i_mant(fp_rnd_i_mant),
      .fp_rnd_i_rema(fp_rnd_i_rema),
      .fp_rnd_i_fmt(fp_rnd_i_fmt),
      .fp_rnd_i_rm(fp_rnd_i_rm),
      .fp_rnd_i_grs(fp_rnd_i_grs),
      .fp_rnd_i_snan(fp_rnd_i_snan),
      .fp_rnd_i_qnan(fp_rnd_i_qnan),
      .fp_rnd_i_dbz(fp_rnd_i_dbz),
      .fp_rnd_i_infs(fp_rnd_i_infs),
      .fp_rnd_i_zero(fp_rnd_i_zero),
      .fp_rnd_i_diff(fp_rnd_i_diff)
  );

endmodule
