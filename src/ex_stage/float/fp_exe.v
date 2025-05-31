module fp_exe (
  input [63:0]          fp_exe_i_data1,
  input [63:0]          fp_exe_i_data2,
  input [63:0]          fp_exe_i_data3,
  input                 fp_exe_i_op_fmadd,
  input                 fp_exe_i_op_fmsub,
  input                 fp_exe_i_op_fnmadd,
  input                 fp_exe_i_op_fnmsub,
  input                 fp_exe_i_op_fadd,
  input                 fp_exe_i_op_fsub,
  input                 fp_exe_i_op_fmul,
  input                 fp_exe_i_op_fsgnj,
  input                 fp_exe_i_op_fcmp,
  input                 fp_exe_i_op_fmax,
  input                 fp_exe_i_op_fclass,
  input                 fp_exe_i_op_fmv_i2f,
  input                 fp_exe_i_op_fmv_f2i,
  input                 fp_exe_i_op_fcvt_i2f,
  input                 fp_exe_i_op_fcvt_f2i,
  input [1:0]           fp_exe_i_op_fcvt_op,
  input [1:0]           fp_exe_i_fmt,
  input [2:0]           fp_exe_i_rm,
  input                 fp_exe_i_enable,
  output reg [31:0]     fp_exe_o_result,
  output reg [4:0]      fp_exe_o_flags,
  output reg            fp_exe_o_ready,

  input [64:0]          fp_ext1_o_result,
  input [9:0]           fp_ext1_o_classification,
  output reg [63:0]     fp_ext1_i_data,
  output reg [1:0]      fp_ext1_i_fmt,
  input [64:0]          fp_ext2_o_result,
  input [9:0]           fp_ext2_o_classification,
  output reg [63:0]     fp_ext2_i_data,
  output reg [1:0]      fp_ext2_i_fmt,
  input [64:0]          fp_ext3_o_result,
  input [9:0]           fp_ext3_o_classification,
  output reg [63:0]     fp_ext3_i_data,
  output reg [1:0]      fp_ext3_i_fmt,

  input [63:0]          fp_cmp_o_result,
  input [4:0]           fp_cmp_o_flags,
  output reg [64:0]     fp_cmp_i_data1,
  output reg [64:0]     fp_cmp_i_data2,
  output reg [2:0]      fp_cmp_i_rm,
  output reg [9:0]      fp_cmp_i_class1,
  output reg [9:0]      fp_cmp_i_class2,

  input [63:0]          fp_max_o_result,
  input [4:0]           fp_max_o_flags,
  output reg [63:0]     fp_max_i_data1,
  output reg [63:0]     fp_max_i_data2,
  output reg [64:0]     fp_max_i_ext1,
  output reg [64:0]     fp_max_i_ext2,
  output reg [1:0]      fp_max_i_fmt,
  output reg [2:0]      fp_max_i_rm,
  output reg [9:0]      fp_max_i_class1,
  output reg [9:0]      fp_max_i_class2,

  input [63:0]          fp_sgnj_o_result,
  output reg [63:0]     fp_sgnj_i_data1,
  output reg [63:0]     fp_sgnj_i_data2,
  output reg [1:0]      fp_sgnj_i_fmt,
  output reg [2:0]      fp_sgnj_i_rm,

  input [63:0]          fp_cvt_f2i_o_result,
  input [4:0]           fp_cvt_f2i_o_flags,
  output reg [64:0]     fp_cvt_f2i_i_data,
  output reg [1:0]      fp_cvt_f2i_i_op_fcvt_op,
  output reg [2:0]      fp_cvt_f2i_i_rm,
  output reg [9:0]      fp_cvt_f2i_i_classification,

  input                 fp_cvt_i2f_o_sig,
  input [13:0]          fp_cvt_i2f_o_expo,
  input [53:0]          fp_cvt_i2f_o_mant,
  input [1:0]           fp_cvt_i2f_o_rema,
  input [1:0]           fp_cvt_i2f_o_fmt,
  input [2:0]           fp_cvt_i2f_o_rm,
  input [2:0]           fp_cvt_i2f_o_grs,
  input                 fp_cvt_i2f_o_snan,
  input                 fp_cvt_i2f_o_qnan,
  input                 fp_cvt_i2f_o_dbz,
  input                 fp_cvt_i2f_o_infs,
  input                 fp_cvt_i2f_o_zero,
  input                 fp_cvt_i2f_o_diff,
  output reg [63:0]     fp_cvt_i2f_i_data,
  output reg [1:0]      fp_cvt_i2f_i_op_fcvt_op,
  output reg [1:0]      fp_cvt_i2f_i_fmt,
  output reg [2:0]      fp_cvt_i2f_i_rm,

  input                 fp_fma_o_sig,
  input [13:0]          fp_fma_o_expo,
  input [53:0]          fp_fma_o_mant,
  input [1:0]           fp_fma_o_rema,
  input [1:0]           fp_fma_o_fmt,
  input [2:0]           fp_fma_o_rm,
  input [2:0]           fp_fma_o_grs,
  input                 fp_fma_o_snan,
  input                 fp_fma_o_qnan,
  input                 fp_fma_o_dbz,
  input                 fp_fma_o_infs,
  input                 fp_fma_o_zero,
  input                 fp_fma_o_diff,
  input                 fp_fma_o_ready,
  output reg [64:0]     fp_fma_i_data1,
  output reg [64:0]     fp_fma_i_data2,
  output reg [64:0]     fp_fma_i_data3,
  output reg [9:0]      fp_fma_i_class1,
  output reg [9:0]      fp_fma_i_class2,
  output reg [9:0]      fp_fma_i_class3,
  output reg            fp_fma_i_op_fmadd,
  output reg            fp_fma_i_op_fmsub,
  output reg            fp_fma_i_op_fnmadd,
  output reg            fp_fma_i_op_fnmsub,
  output reg            fp_fma_i_op_fadd,
  output reg            fp_fma_i_op_fsub,
  output reg            fp_fma_i_op_fmul,
  output reg [1:0]      fp_fma_i_fmt,
  output reg [2:0]      fp_fma_i_rm,

  input [63:0]          fp_rnd_o_result,
  input [4:0]           fp_rnd_o_flags,
  output reg            fp_rnd_i_sig,
  output reg [13:0]     fp_rnd_i_expo,
  output reg [53:0]     fp_rnd_i_mant,
  output reg [1:0]      fp_rnd_i_rema,
  output reg [1:0]      fp_rnd_i_fmt,
  output reg [2:0]      fp_rnd_i_rm,
  output reg [2:0]      fp_rnd_i_grs,
  output reg            fp_rnd_i_snan,
  output reg            fp_rnd_i_qnan,
  output reg            fp_rnd_i_dbz,
  output reg            fp_rnd_i_infs,
  output reg            fp_rnd_i_zero,
  output reg            fp_rnd_i_diff
);

  reg [63:0] data1;
  reg [63:0] data2;
  reg [63:0] data3;
  reg op_fmadd;
  reg op_fmsub;
  reg op_fnmadd;
  reg op_fnmsub;
  reg op_fadd;
  reg op_fsub;
  reg op_fmul;
  reg op_fsgnj;
  reg op_fcmp;
  reg op_fmax;
  reg op_fclass;
  reg op_fmv_i2f;
  reg op_fmv_f2i;
  reg op_fcvt_i2f;
  reg op_fcvt_f2i;
  reg [1:0] op_fcvt_op;

  reg [1:0] fmt;
  reg [2:0] rm;

  reg [63:0] result;
  reg [4:0] flags;
  reg ready;

  reg [1:0] fmt_ext;

  reg [64:0] extend1;
  reg [64:0] extend2;
  reg [64:0] extend3;

  reg [9:0] class1;
  reg [9:0] class2;
  reg [9:0] class3;
  
  reg fp_rnd_sig;
  reg [13:0] fp_rnd_expo;
  reg [53:0] fp_rnd_mant;
  reg [1:0] fp_rnd_rema;
  reg [1:0] fp_rnd_fmt;
  reg [2:0] fp_rnd_rm;
  reg [2:0] fp_rnd_grs;
  reg fp_rnd_snan;
  reg fp_rnd_qnan;
  reg fp_rnd_dbz;
  reg fp_rnd_infs;
  reg fp_rnd_zero;
  reg fp_rnd_diff;

  always @(*) begin
    if (fp_exe_i_enable) begin
      data1 = fp_exe_i_data1;
      data2 = fp_exe_i_data2;
      data3 = fp_exe_i_data3;
      op_fmadd = fp_exe_i_op_fmadd;
      op_fmsub = fp_exe_i_op_fmsub;
      op_fnmadd = fp_exe_i_op_fnmadd;
      op_fnmsub = fp_exe_i_op_fnmsub;
      op_fadd = fp_exe_i_op_fadd;
      op_fsub = fp_exe_i_op_fsub;
      op_fmul = fp_exe_i_op_fmul;
      op_fsgnj = fp_exe_i_op_fsgnj;
      op_fcmp = fp_exe_i_op_fcmp;
      op_fmax = fp_exe_i_op_fmax;
      op_fclass = fp_exe_i_op_fclass;
      op_fmv_i2f = fp_exe_i_op_fmv_i2f;
      op_fmv_f2i = fp_exe_i_op_fmv_f2i;
      op_fcvt_i2f = fp_exe_i_op_fcvt_i2f;
      op_fcvt_f2i = fp_exe_i_op_fcvt_f2i;
      op_fcvt_op = fp_exe_i_op_fcvt_op;
      fmt = fp_exe_i_fmt;
      rm = fp_exe_i_rm;
    end else begin
      data1 = 0;
      data2 = 0;
      data3 = 0;
      op_fmadd = 0;
      op_fmsub = 0;
      op_fnmadd = 0;
      op_fnmsub = 0;
      op_fadd = 0;
      op_fsub = 0;
      op_fmul = 0;
      op_fsgnj = 0;
      op_fcmp = 0;
      op_fmax = 0;
      op_fclass = 0;
      op_fmv_i2f = 0;
      op_fmv_f2i = 0;
      op_fcvt_i2f = 0;
      op_fcvt_f2i = 0;
      op_fcvt_op = 0;
      fmt = 0;
      rm = 0;
    end

    result = 0;
    flags  = 0;
    ready  = fp_exe_i_enable;
    fmt_ext = fp_exe_i_fmt;

    fp_ext1_i_data = data1;
    fp_ext1_i_fmt = fmt_ext;
    fp_ext2_i_data = data2;
    fp_ext2_i_fmt = fmt_ext;
    fp_ext3_i_data = data3;
    fp_ext3_i_fmt = fmt_ext;

    extend1 = fp_ext1_o_result;
    extend2 = fp_ext2_o_result;
    extend3 = fp_ext3_o_result;

    class1 = fp_ext1_o_classification;
    class2 = fp_ext2_o_classification;
    class3 = fp_ext3_o_classification;

    fp_cmp_i_data1 = extend1;
    fp_cmp_i_data2 = extend2;
    fp_cmp_i_rm = rm;
    fp_cmp_i_class1 = class1;
    fp_cmp_i_class2 = class2;

    fp_max_i_data1 = data1;
    fp_max_i_data2 = data2;
    fp_max_i_ext1 = extend1;
    fp_max_i_ext2 = extend2;
    fp_max_i_fmt = fmt;
    fp_max_i_rm = rm;
    fp_max_i_class1 = class1;
    fp_max_i_class2 = class2;

    fp_sgnj_i_data1 = data1;
    fp_sgnj_i_data2 = data2;
    fp_sgnj_i_fmt = fmt;
    fp_sgnj_i_rm = rm;

    fp_fma_i_data1 = extend1;
    fp_fma_i_data2 = extend2;
    fp_fma_i_data3 = extend3;
    fp_fma_i_fmt = fmt;
    fp_fma_i_rm = rm;
    fp_fma_i_op_fmadd = op_fmadd;
    fp_fma_i_op_fmsub = op_fmsub;
    fp_fma_i_op_fnmadd = op_fnmadd;
    fp_fma_i_op_fnmsub = op_fnmsub;
    fp_fma_i_op_fadd = op_fadd;
    fp_fma_i_op_fsub = op_fsub;
    fp_fma_i_op_fmul = op_fmul;
    fp_fma_i_class1 = class1;
    fp_fma_i_class2 = class2;
    fp_fma_i_class3 = class3;

    fp_cvt_i2f_i_data = data1;
    fp_cvt_i2f_i_op_fcvt_op = op_fcvt_op;
    fp_cvt_i2f_i_fmt = fmt;
    fp_cvt_i2f_i_rm = rm;

    fp_cvt_f2i_i_data = extend1;
    fp_cvt_f2i_i_op_fcvt_op = op_fcvt_op;
    fp_cvt_f2i_i_rm = rm;
    fp_cvt_f2i_i_classification = class1;

    fp_rnd_sig = 0;
    fp_rnd_expo = 0;
    fp_rnd_mant = 0;
    fp_rnd_rema = 0;
    fp_rnd_fmt = 0;
    fp_rnd_rm = 0;
    fp_rnd_grs = 0;
    fp_rnd_snan = 0;
    fp_rnd_qnan = 0;
    fp_rnd_dbz = 0;
    fp_rnd_infs = 0;
    fp_rnd_zero = 0;
    fp_rnd_diff = 0;

    if (fp_fma_o_ready) begin
      fp_rnd_sig = fp_fma_o_sig;
      fp_rnd_expo = fp_fma_o_expo;
      fp_rnd_mant = fp_fma_o_mant;
      fp_rnd_rema = fp_fma_o_rema;
      fp_rnd_fmt = fp_fma_o_fmt;
      fp_rnd_rm = fp_fma_o_rm;
      fp_rnd_grs = fp_fma_o_grs;
      fp_rnd_snan = fp_fma_o_snan;
      fp_rnd_qnan = fp_fma_o_qnan;
      fp_rnd_dbz = fp_fma_o_dbz;
      fp_rnd_infs = fp_fma_o_infs;
      fp_rnd_zero = fp_fma_o_zero;
      fp_rnd_diff = fp_fma_o_diff;
    end else if (op_fcvt_i2f) begin
      fp_rnd_sig = fp_cvt_i2f_o_sig;
      fp_rnd_expo = fp_cvt_i2f_o_expo;
      fp_rnd_mant = fp_cvt_i2f_o_mant;
      fp_rnd_rema = fp_cvt_i2f_o_rema;
      fp_rnd_fmt = fp_cvt_i2f_o_fmt;
      fp_rnd_rm = fp_cvt_i2f_o_rm;
      fp_rnd_grs = fp_cvt_i2f_o_grs;
      fp_rnd_snan = fp_cvt_i2f_o_snan;
      fp_rnd_qnan = fp_cvt_i2f_o_qnan;
      fp_rnd_dbz = fp_cvt_i2f_o_dbz;
      fp_rnd_infs = fp_cvt_i2f_o_infs;
      fp_rnd_zero = fp_cvt_i2f_o_zero;
      fp_rnd_diff = fp_cvt_i2f_o_diff;
    end

    fp_rnd_i_sig = fp_rnd_sig;
    fp_rnd_i_expo = fp_rnd_expo;
    fp_rnd_i_mant = fp_rnd_mant;
    fp_rnd_i_rema = fp_rnd_rema;
    fp_rnd_i_fmt = fp_rnd_fmt;
    fp_rnd_i_rm = fp_rnd_rm;
    fp_rnd_i_grs = fp_rnd_grs;
    fp_rnd_i_snan = fp_rnd_snan;
    fp_rnd_i_qnan = fp_rnd_qnan;
    fp_rnd_i_dbz = fp_rnd_dbz;
    fp_rnd_i_infs = fp_rnd_infs;
    fp_rnd_i_zero = fp_rnd_zero;
    fp_rnd_i_diff = fp_rnd_diff;

    if (fp_fma_o_ready) begin
      result = fp_rnd_o_result;
      flags  = fp_rnd_o_flags;
      ready  = 1;
    end else if (op_fmadd | op_fmsub | op_fnmadd | op_fnmsub | op_fadd | op_fadd | op_fsub | op_fmul) begin
      ready = 0;
    end else if (op_fcmp) begin
      result = fp_cmp_o_result;
      flags  = fp_cmp_o_flags;
    end else if (op_fsgnj) begin
      result = fp_sgnj_o_result;
      flags  = 0;
    end else if (op_fmax) begin
      result = fp_max_o_result;
      flags  = fp_max_o_flags;
    end else if (op_fcmp) begin
      result = fp_cmp_o_result;
      flags  = fp_cmp_o_flags;
    end else if (op_fclass) begin
      result = {54'h0, class1};
      flags  = 0;
    end else if (op_fmv_f2i) begin
      result = data1;
      flags  = 0;
    end else if (op_fmv_i2f) begin
      result = data1;
      flags  = 0;
    end else if (op_fcvt_i2f) begin
      result = fp_rnd_o_result;
      flags  = fp_rnd_o_flags;
    end else if (op_fcvt_f2i) begin
      result = fp_cvt_f2i_o_result;
      flags  = fp_cvt_f2i_o_flags;
    end

    fp_exe_o_result = result[31:0];
    fp_exe_o_flags  = flags;
    fp_exe_o_ready  = ready;
  end

endmodule
