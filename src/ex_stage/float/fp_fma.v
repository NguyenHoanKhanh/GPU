module fp_fma (
  input              reset,
  input              clock,
  input [64:0]       fp_fma_i_data1,
  input [64:0]       fp_fma_i_data2,
  input [64:0]       fp_fma_i_data3,
  input [9:0]        fp_fma_i_class1,
  input [9:0]        fp_fma_i_class2,
  input [9:0]        fp_fma_i_class3,
  input              fp_fma_i_op_fmadd,
  input              fp_fma_i_op_fmsub,
  input              fp_fma_i_op_fnmadd,
  input              fp_fma_i_op_fnmsub,
  input              fp_fma_i_op_fadd,
  input              fp_fma_i_op_fsub,
  input              fp_fma_i_op_fmul,
  input [1:0]        fp_fma_i_fmt,
  input [2:0]        fp_fma_i_rm,
 
  output reg         fp_fma_o_sig,
  output reg [13:0]  fp_fma_o_expo,
  output reg [53:0]  fp_fma_o_mant,
  output reg [1:0]   fp_fma_o_rema,
  output reg [1:0]   fp_fma_o_fmt,
  output reg [2:0]   fp_fma_o_rm,
  output reg [2:0]   fp_fma_o_grs,
  output reg         fp_fma_o_snan,
  output reg         fp_fma_o_qnan,
  output reg         fp_fma_o_dbz,
  output reg         fp_fma_o_infs,
  output reg         fp_fma_o_zero,
  output reg         fp_fma_o_diff,
  output reg         fp_fma_o_ready,

  input [7:0]        lzc_o_c,
  output reg [255:0] lzc_i_a
);

  reg [1:0] r_1_fmt;
  reg [2:0] r_1_rm;
  reg r_1_snan;
  reg r_1_qnan;
  reg r_1_dbz;
  reg r_1_infs;
  reg r_1_zero;
  reg r_1_sign_mul;
  reg [13:0] r_1_exponent_mul;
  reg [163:0] r_1_mantissa_mul;
  reg r_1_sign_add;
  reg [13:0] r_1_exponent_add;
  reg [163:0] r_1_mantissa_add;
  reg r_1_exponent_neg;
  reg r_1_ready;
  
  reg r_2_sign_rnd;
  reg [13:0] r_2_exponent_rnd;
  reg [53:0] r_2_mantissa_rnd;
  reg [1:0] r_2_fmt;
  reg [2:0] r_2_rm;
  reg [2:0] r_2_grs;
  reg r_2_snan;
  reg r_2_qnan;
  reg r_2_dbz;
  reg r_2_infs;
  reg r_2_zero;
  reg r_2_diff;
  reg r_2_ready;

  reg [1:0] rin_1_fmt;
  reg [2:0] rin_1_rm;
  reg rin_1_snan;
  reg rin_1_qnan;
  reg rin_1_dbz;
  reg rin_1_infs;
  reg rin_1_zero;
  reg rin_1_sign_mul;
  reg [13:0] rin_1_exponent_mul;
  reg [163:0] rin_1_mantissa_mul;
  reg rin_1_sign_add;
  reg [13:0] rin_1_exponent_add;
  reg [163:0] rin_1_mantissa_add;
  reg rin_1_exponent_neg;
  reg rin_1_ready;

  reg rin_2_sign_rnd;
  reg [13:0] rin_2_exponent_rnd;
  reg [53:0] rin_2_mantissa_rnd;
  reg [1:0] rin_2_fmt;
  reg [2:0] rin_2_rm;
  reg [2:0] rin_2_grs;
  reg rin_2_snan;
  reg rin_2_qnan;
  reg rin_2_dbz;
  reg rin_2_infs;
  reg rin_2_zero;
  reg rin_2_diff;
  reg rin_2_ready;

  reg [64:0] v_1_a;
  reg [64:0] v_1_b;
  reg [64:0] v_1_c;
  reg [9:0] v_1_class_a;
  reg [9:0] v_1_class_b;
  reg [9:0] v_1_class_c;
  reg [1:0] v_1_fmt;
  reg [2:0] v_1_rm;
  reg v_1_snan;
  reg v_1_qnan;
  reg v_1_dbz;
  reg v_1_infs;
  reg v_1_zero;
  reg v_1_sign_a;
  reg [11:0] v_1_exponent_a;
  reg [52:0] v_1_mantissa_a;
  reg v_1_sign_b;
  reg [11:0] v_1_exponent_b;
  reg [52:0] v_1_mantissa_b;
  reg v_1_sign_c;
  reg [11:0] v_1_exponent_c;
  reg [52:0] v_1_mantissa_c;
  reg v_1_sign_mul;
  reg [13:0] v_1_exponent_mul;
  reg [163:0] v_1_mantissa_mul;
  reg v_1_sign_add;
  reg [13:0] v_1_exponent_add;
  reg [163:0] v_1_mantissa_add;
  reg [163:0] v_1_mantissa_l;
  reg [163:0] v_1_mantissa_r;
  reg [13:0] v_1_exponent_dif;
  reg [6:0] v_1_counter_dif;
  reg v_1_exponent_neg;
  reg v_1_ready;

  reg [1:0] v_2_fmt;
  reg [2:0] v_2_rm;
  reg v_2_snan;
  reg v_2_qnan;
  reg v_2_dbz;
  reg v_2_infs;
  reg v_2_zero;
  reg v_2_diff;
  reg v_2_sign_mul;
  reg [13:0] v_2_exponent_mul;
  reg [163:0] v_2_mantissa_mul;
  reg v_2_sign_add;
  reg [13:0] v_2_exponent_add;
  reg [163:0] v_2_mantissa_add;
  reg v_2_exponent_neg;
  reg v_2_sign_mac;
  reg [13:0] v_2_exponent_mac;
  reg [163:0] v_2_mantissa_mac;
  reg [7:0] v_2_counter_mac;
  reg [13:0] v_2_counter_sub;
  reg [10:0] v_2_bias;
  reg v_2_sign_rnd;
  reg [13:0] v_2_exponent_rnd;
  reg [53:0] v_2_mantissa_rnd;
  reg [2:0] v_2_grs;
  reg v_2_ready;

  always @(*) begin
    v_1_a = fp_fma_i_data1;
    v_1_b = fp_fma_i_data2;
    v_1_c = fp_fma_i_data3;
    v_1_class_a = fp_fma_i_class1;
    v_1_class_b = fp_fma_i_class2;
    v_1_class_c = fp_fma_i_class3;
    v_1_fmt = fp_fma_i_fmt;
    v_1_rm = fp_fma_i_rm;
    v_1_snan = 0;
    v_1_qnan = 0;
    v_1_dbz = 0;
    v_1_infs = 0;
    v_1_zero = 0;
    v_1_ready = fp_fma_i_op_fmadd | fp_fma_i_op_fmsub | fp_fma_i_op_fnmsub | fp_fma_i_op_fnmadd | fp_fma_i_op_fadd | fp_fma_i_op_fsub | fp_fma_i_op_fmul;

    if (fp_fma_i_op_fadd | fp_fma_i_op_fsub) begin
      v_1_c = v_1_b;
      v_1_class_c = v_1_class_b;
      v_1_b = 65'h07FF0000000000000;
      v_1_class_b = 10'h040;
    end

    if (fp_fma_i_op_fmul) begin
      v_1_c = {v_1_a[64] ^ v_1_b[64], 64'h0000000000000000};
      v_1_class_c = 0;
    end

    v_1_sign_a = v_1_a[64];
    v_1_exponent_a = v_1_a[63:52];
    v_1_mantissa_a = {|v_1_exponent_a, v_1_a[51:0]};

    v_1_sign_b = v_1_b[64];
    v_1_exponent_b = v_1_b[63:52];
    v_1_mantissa_b = {|v_1_exponent_b, v_1_b[51:0]};

    v_1_sign_c = v_1_c[64];
    v_1_exponent_c = v_1_c[63:52];
    v_1_mantissa_c = {|v_1_exponent_c, v_1_c[51:0]};

    v_1_sign_add = v_1_sign_c ^ (fp_fma_i_op_fmsub | fp_fma_i_op_fnmadd | fp_fma_i_op_fsub);
    v_1_sign_mul = (v_1_sign_a ^ v_1_sign_b) ^ (fp_fma_i_op_fnmsub | fp_fma_i_op_fnmadd);

    if (v_1_class_a[8] | v_1_class_b[8] | v_1_class_c[8]) begin
      v_1_snan = 1;
    end else if (((v_1_class_a[3] | v_1_class_a[4]) & (v_1_class_b[0] | v_1_class_b[7])) | ((v_1_class_b[3] | v_1_class_b[4]) & (v_1_class_a[0] | v_1_class_a[7]))) begin
      v_1_snan = 1;
    end else if (v_1_class_a[9] | v_1_class_b[9] | v_1_class_c[9]) begin
      v_1_qnan = 1;
    end else if (((v_1_class_a[0] | v_1_class_a[7]) | (v_1_class_b[0] | v_1_class_b[7])) & ((v_1_class_c[0] | v_1_class_c[7]) & (v_1_sign_add != v_1_sign_mul))) begin
      v_1_snan = 1;
    end else if ((v_1_class_a[0] | v_1_class_a[7]) | (v_1_class_b[0] | v_1_class_b[7]) | (v_1_class_c[0] | v_1_class_c[7])) begin
      v_1_infs = 1;
    end

    v_1_exponent_add = $signed({2'h0, v_1_exponent_c});
    v_1_exponent_mul = $signed({2'h0, v_1_exponent_a}) + $signed({2'h0, v_1_exponent_b}) - 14'd2047;

    if (&v_1_exponent_c) begin
      v_1_exponent_add = 14'h0FFF;
    end
    if (&v_1_exponent_a | &v_1_exponent_b) begin
      v_1_exponent_mul = 14'h0FFF;
    end

    v_1_mantissa_add[163:161] = 0;
    v_1_mantissa_add[160:108] = v_1_mantissa_c;
    v_1_mantissa_add[107:0] = 0;
    v_1_mantissa_mul[163:162] = 0;
    v_1_mantissa_mul[161:56] = v_1_mantissa_a * v_1_mantissa_b;
    v_1_mantissa_mul[55:0] = 0;

    v_1_exponent_dif = $signed(v_1_exponent_mul) - $signed(v_1_exponent_add);
    v_1_counter_dif = 0;

    v_1_exponent_neg = v_1_exponent_dif[13];

    if (v_1_exponent_neg) begin
      v_1_counter_dif = 56;
      if ($signed(v_1_exponent_dif) > -56) begin
        v_1_counter_dif = -v_1_exponent_dif[6:0];
      end
      v_1_mantissa_l = v_1_mantissa_add;
      v_1_mantissa_r = v_1_mantissa_mul;
    end else begin
      v_1_counter_dif = 108;
      if ($signed(v_1_exponent_dif) < 108) begin
        v_1_counter_dif = v_1_exponent_dif[6:0];
      end
      v_1_mantissa_l = v_1_mantissa_mul;
      v_1_mantissa_r = v_1_mantissa_add;
    end

    v_1_mantissa_r = v_1_mantissa_r >> v_1_counter_dif;

    if (v_1_exponent_neg) begin
      v_1_mantissa_add = v_1_mantissa_l;
      v_1_mantissa_mul = v_1_mantissa_r;
    end else begin
      v_1_mantissa_add = v_1_mantissa_r;
      v_1_mantissa_mul = v_1_mantissa_l;
    end

    rin_1_fmt = v_1_fmt;
    rin_1_rm = v_1_rm;
    rin_1_snan = v_1_snan;
    rin_1_qnan = v_1_qnan;
    rin_1_dbz = v_1_dbz;
    rin_1_infs = v_1_infs;
    rin_1_zero = v_1_zero;
    rin_1_sign_mul = v_1_sign_mul;
    rin_1_exponent_mul = v_1_exponent_mul;
    rin_1_mantissa_mul = v_1_mantissa_mul;
    rin_1_sign_add = v_1_sign_add;
    rin_1_exponent_add = v_1_exponent_add;
    rin_1_mantissa_add = v_1_mantissa_add;
    rin_1_exponent_neg = v_1_exponent_neg;
    rin_1_ready = v_1_ready;
  end

  always @(*) begin
    v_2_fmt          = r_1_fmt;
    v_2_rm           = r_1_rm;
    v_2_snan         = r_1_snan;
    v_2_qnan         = r_1_qnan;
    v_2_dbz          = r_1_dbz;
    v_2_infs         = r_1_infs;
    v_2_zero         = r_1_zero;
    v_2_sign_mul     = r_1_sign_mul;
    v_2_exponent_mul = r_1_exponent_mul;
    v_2_mantissa_mul = r_1_mantissa_mul;
    v_2_sign_add     = r_1_sign_add;
    v_2_exponent_add = r_1_exponent_add;
    v_2_mantissa_add = r_1_mantissa_add;
    v_2_exponent_neg = r_1_exponent_neg;
    v_2_ready        = r_1_ready;

    if (v_2_exponent_neg) begin
      v_2_exponent_mac = v_2_exponent_add;
    end else begin
      v_2_exponent_mac = v_2_exponent_mul;
    end

    if (v_2_sign_add) begin
      v_2_mantissa_add = ~v_2_mantissa_add;
    end
    if (v_2_sign_mul) begin
      v_2_mantissa_mul = ~v_2_mantissa_mul;
    end

    v_2_mantissa_mac = v_2_mantissa_add + v_2_mantissa_mul + {163'h0,v_2_sign_add} + {163'h0,v_2_sign_mul};
    v_2_sign_mac = v_2_mantissa_mac[163];

    v_2_zero = ~|v_2_mantissa_mac;

    if (v_2_zero) begin
      v_2_sign_mac = v_2_sign_add & v_2_sign_mul;
    end else if (v_2_sign_mac) begin
      v_2_mantissa_mac = -v_2_mantissa_mac;
    end

    v_2_diff = v_2_sign_add ^ v_2_sign_mul;

    v_2_bias = 1918;
    if (v_2_fmt == 1) begin
      v_2_bias = 1022;
    end

    lzc_i_a = {v_2_mantissa_mac[162:0], {93{1'b1}}};
    v_2_counter_mac = ~lzc_o_c;
    v_2_mantissa_mac = v_2_mantissa_mac << v_2_counter_mac;

    v_2_sign_rnd = v_2_sign_mac;
    v_2_exponent_rnd = v_2_exponent_mac - {3'h0, v_2_bias} - {6'h0, v_2_counter_mac};

    v_2_counter_sub = 0;
    if ($signed(v_2_exponent_rnd) <= 0) begin
      v_2_counter_sub = 63;
      if ($signed(v_2_exponent_rnd) > -63) begin
        v_2_counter_sub = 14'h1 - v_2_exponent_rnd;
      end
      v_2_exponent_rnd = 0;
    end

    v_2_mantissa_mac = v_2_mantissa_mac >> v_2_counter_sub[5:0];

    v_2_mantissa_rnd = {30'h0, v_2_mantissa_mac[162:139]};
    v_2_grs = {v_2_mantissa_mac[138:137], |v_2_mantissa_mac[136:0]};
    if (v_2_fmt == 1) begin
      v_2_mantissa_rnd = {1'h0, v_2_mantissa_mac[162:110]};
      v_2_grs = {v_2_mantissa_mac[109:108], |v_2_mantissa_mac[107:0]};
    end

    rin_2_sign_rnd = v_2_sign_rnd;
    rin_2_exponent_rnd = v_2_exponent_rnd;
    rin_2_mantissa_rnd = v_2_mantissa_rnd;
    rin_2_fmt = v_2_fmt;
    rin_2_rm = v_2_rm;
    rin_2_grs = v_2_grs;
    rin_2_snan = v_2_snan;
    rin_2_qnan = v_2_qnan;
    rin_2_dbz = v_2_dbz;
    rin_2_infs = v_2_infs;
    rin_2_diff = v_2_diff;
    rin_2_zero = v_2_zero;
    rin_2_ready = v_2_ready;
  end

  always @(*) begin
    fp_fma_o_sig = r_2_sign_rnd;
    fp_fma_o_expo = r_2_exponent_rnd;
    fp_fma_o_mant = r_2_mantissa_rnd;
    fp_fma_o_rema = 2'h0;
    fp_fma_o_fmt = r_2_fmt;
    fp_fma_o_rm = r_2_rm;
    fp_fma_o_grs = r_2_grs;
    fp_fma_o_snan = r_2_snan;
    fp_fma_o_qnan = r_2_qnan;
    fp_fma_o_dbz = r_2_dbz;
    fp_fma_o_infs = r_2_infs;
    fp_fma_o_zero = r_2_zero;
    fp_fma_o_diff = r_2_diff;
    fp_fma_o_ready = r_2_ready;
  end

  always @(posedge clock, negedge reset) begin
    if (reset == 0) begin
      r_1_fmt <= 'd0;
      r_1_rm <= 'd0;
      r_1_snan <= 'd0;
      r_1_qnan <= 'd0;
      r_1_dbz <= 'd0;
      r_1_infs <= 'd0;
      r_1_zero <= 'd0;
      r_1_sign_mul <= 'd0;
      r_1_exponent_mul <= 'd0;
      r_1_mantissa_mul <= 'd0;
      r_1_sign_add <= 'd0;
      r_1_exponent_add <= 'd0;
      r_1_mantissa_add <= 'd0;
      r_1_exponent_neg <= 'd0;
      r_1_ready <= 'd0;

      r_2_sign_rnd <= 'd0;
      r_2_exponent_rnd <= 'd0;
      r_2_mantissa_rnd <= 'd0;
      r_2_fmt <= 'd0;
      r_2_rm <= 'd0;
      r_2_grs <= 'd0;
      r_2_snan <= 'd0;
      r_2_qnan <= 'd0;
      r_2_dbz <= 'd0;
      r_2_infs <= 'd0;
      r_2_zero <= 'd0;
      r_2_diff <= 'd0;
      r_2_ready <= 'd0;
    end 
    else begin
      r_1_fmt <= rin_1_fmt;
      r_1_rm <= rin_1_rm;
      r_1_snan <= rin_1_snan;
      r_1_qnan <= rin_1_qnan;
      r_1_dbz <= rin_1_dbz;
      r_1_infs <= rin_1_infs;
      r_1_zero <= rin_1_zero;
      r_1_sign_mul <= rin_1_sign_mul;
      r_1_exponent_mul <= rin_1_exponent_mul;
      r_1_mantissa_mul <= rin_1_mantissa_mul;
      r_1_sign_add <= rin_1_sign_add;
      r_1_exponent_add <= rin_1_exponent_add;
      r_1_mantissa_add <= rin_1_mantissa_add;
      r_1_exponent_neg <= rin_1_exponent_neg;
      r_1_ready <= rin_1_ready;

      r_2_sign_rnd <= rin_2_sign_rnd;
      r_2_exponent_rnd <= rin_2_exponent_rnd;
      r_2_mantissa_rnd <= rin_2_mantissa_rnd;
      r_2_fmt <= rin_2_fmt;
      r_2_rm <= rin_2_rm;
      r_2_grs <= rin_2_grs;
      r_2_snan <= rin_2_snan;
      r_2_qnan <= rin_2_qnan;
      r_2_dbz <= rin_2_dbz;
      r_2_infs <= rin_2_infs;
      r_2_zero <= rin_2_zero;
      r_2_diff <= rin_2_diff;
      r_2_ready <= rin_2_ready;
    end
  end

endmodule
