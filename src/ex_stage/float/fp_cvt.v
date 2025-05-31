module fp_cvt (
  input [64:0]        iData_f2i,
  input [1:0]         iFcvt_op_f2i,
  input [2:0]         iRm_f2i,
  input [9:0]         iClassification_f2i,
  output reg [63:0]   oResult_f2i,
  output reg [4:0]    oFlags_f2i,
  
  input [63:0]        iData_i2f,
  input [1:0]         iFcvt_op_i2f,
  input [1:0]         iFmt_i2f,
  input [2:0]         iRm_i2f,
  output reg          sig_i2f,
  output reg [13:0]   expo_i2f,
  output reg [53:0]   mant_i2f,
  output reg [1:0]    rema_i2f,
  output reg [1:0]    fmt_i2f,
  output reg [2:0]    rm_i2f,
  output reg [2:0]    grs_i2f,
  output reg          snan_i2f,
  output reg          qnan_i2f,
  output reg          dbz_i2f,
  output reg          infs_i2f,
  output reg          zero_i2f,
  output reg          diff_i2f,

  input [5:0]         lzc_o_c,
  output reg [63:0]   lzc_i_a
);

  reg [64:0] v_f2i_data;
  reg [1:0] v_f2i_op;
  reg [2:0] v_f2i_rm;
  reg [9:0] v_f2i_classification;
  reg [63:0] v_f2i_result;
  reg [4:0] v_f2i_flags;
  reg v_f2i_snan;
  reg v_f2i_qnan;
  reg v_f2i_infs;
  reg v_f2i_zero;
  reg v_f2i_sign_cvt;
  reg [12:0] v_f2i_exponent_cvt;
  reg [119:0] v_f2i_mantissa_cvt;
  reg [7:0] v_f2i_exponent_bias;
  reg [64:0] v_f2i_mantissa_uint;
  reg [2:0] v_f2i_grs;
  reg v_f2i_odd;
  reg v_f2i_rnded;
  reg v_f2i_oor;
  reg v_f2i_or_1;
  reg v_f2i_or_2;
  reg v_f2i_or_3;
  reg v_f2i_or_4;
  reg v_f2i_or_5;
  reg v_f2i_oor_64u;
  reg v_f2i_oor_64s;
  reg v_f2i_oor_32u;
  reg v_f2i_oor_32s;

  reg [63:0] v_i2f_data;
  reg [1:0] v_i2f_op;
  reg [1:0] v_i2f_fmt;
  reg [2:0] v_i2f_rm;
  reg v_i2f_snan;
  reg v_i2f_qnan;
  reg v_i2f_dbz;
  reg v_i2f_infs;
  reg v_i2f_zero;
  reg v_i2f_sign_uint;
  reg [5:0] v_i2f_exponent_uint;
  reg [63:0] v_i2f_mantissa_uint;
  reg [5:0] v_i2f_counter_uint;
  reg [9:0] v_i2f_exponent_bias;
  reg v_i2f_sign_rnd;
  reg [13:0] v_i2f_exponent_rnd;
  reg [53:0] v_i2f_mantissa_rnd;
  reg [2:0] v_i2f_grs;

  always @(*) begin
    v_f2i_data = iData_f2i;
    v_f2i_op = iFcvt_op_f2i;
    v_f2i_rm = iRm_f2i;
    v_f2i_classification = iClassification_f2i;

    v_f2i_flags = 0;
    v_f2i_result = 0;

    v_f2i_snan = v_f2i_classification[8];
    v_f2i_qnan = v_f2i_classification[9];
    v_f2i_infs = v_f2i_classification[0] | v_f2i_classification[7];
    v_f2i_zero = 0;

    if (v_f2i_op == 0) begin
      v_f2i_exponent_bias = 34;
    end else if (v_f2i_op == 1) begin
      v_f2i_exponent_bias = 35;
    end else if (v_f2i_op == 2) begin
      v_f2i_exponent_bias = 66;
    end else begin
      v_f2i_exponent_bias = 67;
    end

    v_f2i_sign_cvt = v_f2i_data[64];
    v_f2i_exponent_cvt = v_f2i_data[63:52] - 13'd2044;
    v_f2i_mantissa_cvt = {68'h1, v_f2i_data[51:0]};

    if ((v_f2i_classification[3] | v_f2i_classification[4]) == 1) begin
      v_f2i_mantissa_cvt[52] = 0;
    end

    v_f2i_oor = 0;

    if ($signed(v_f2i_exponent_cvt) > $signed({5'h0, v_f2i_exponent_bias})) begin
      v_f2i_oor = 1;
    end else if ($signed(v_f2i_exponent_cvt) > 0) begin
      v_f2i_mantissa_cvt = v_f2i_mantissa_cvt << v_f2i_exponent_cvt;
    end

    v_f2i_mantissa_uint = v_f2i_mantissa_cvt[119:55];

    v_f2i_grs = {v_f2i_mantissa_cvt[54:53], (|v_f2i_mantissa_cvt[52:0])};
    v_f2i_odd = v_f2i_mantissa_uint[0] | (|v_f2i_grs[1:0]);

    v_f2i_flags[0] = |v_f2i_grs;

    v_f2i_rnded = 0;
    if (v_f2i_rm == 0) begin  //rne
      if (v_f2i_grs[2] & v_f2i_odd) begin
        v_f2i_rnded = 1;
      end
    end else if (v_f2i_rm == 2) begin  //rdn
      if (v_f2i_sign_cvt & v_f2i_flags[0]) begin
        v_f2i_rnded = 1;
      end
    end else if (v_f2i_rm == 3) begin  //rup
      if (~v_f2i_sign_cvt & v_f2i_flags[0]) begin
        v_f2i_rnded = 1;
      end
    end else if (v_f2i_rm == 4) begin  //rmm
      if (v_f2i_grs[2] & v_f2i_flags[0]) begin
        v_f2i_rnded = 1;
      end
    end

    v_f2i_mantissa_uint = v_f2i_mantissa_uint + {64'h0, v_f2i_rnded};

    v_f2i_or_1 = v_f2i_mantissa_uint[64];
    v_f2i_or_2 = v_f2i_mantissa_uint[63];
    v_f2i_or_3 = |v_f2i_mantissa_uint[62:32];
    v_f2i_or_4 = v_f2i_mantissa_uint[31];
    v_f2i_or_5 = |v_f2i_mantissa_uint[30:0];

    v_f2i_zero = v_f2i_or_1 | v_f2i_or_2 | v_f2i_or_3 | v_f2i_or_4 | v_f2i_or_5;

    v_f2i_oor_64u = v_f2i_or_1;
    v_f2i_oor_64s = v_f2i_or_1;
    v_f2i_oor_32u = v_f2i_or_1 | v_f2i_or_2 | v_f2i_or_3;
    v_f2i_oor_32s = v_f2i_or_1 | v_f2i_or_2 | v_f2i_or_3;

    if (v_f2i_sign_cvt) begin
      if (v_f2i_op == 0) begin
        v_f2i_oor_32s = v_f2i_oor_32s | (v_f2i_or_4 & v_f2i_or_5);
      end else if (v_f2i_op == 1) begin
        v_f2i_oor = v_f2i_oor | v_f2i_zero;
      end else if (v_f2i_op == 2) begin
        v_f2i_oor_64s = v_f2i_oor_64s | (v_f2i_or_2 & (v_f2i_or_3 | v_f2i_or_4 | v_f2i_or_5));
      end else if (v_f2i_op == 3) begin
        v_f2i_oor = v_f2i_oor | v_f2i_zero;
      end
    end else begin
      v_f2i_oor_64s = v_f2i_oor_64s | v_f2i_or_2;
      v_f2i_oor_32s = v_f2i_oor_32s | v_f2i_or_4;
    end

    v_f2i_oor_64u = (v_f2i_op == 3) & (v_f2i_oor_64u | v_f2i_oor | v_f2i_infs | v_f2i_snan | v_f2i_qnan);
    v_f2i_oor_64s = (v_f2i_op == 2) & (v_f2i_oor_64s | v_f2i_oor | v_f2i_infs | v_f2i_snan | v_f2i_qnan);
    v_f2i_oor_32u = (v_f2i_op == 1) & (v_f2i_oor_32u | v_f2i_oor | v_f2i_infs | v_f2i_snan | v_f2i_qnan);
    v_f2i_oor_32s = (v_f2i_op == 0) & (v_f2i_oor_32s | v_f2i_oor | v_f2i_infs | v_f2i_snan | v_f2i_qnan);

    if (v_f2i_sign_cvt) begin
      v_f2i_mantissa_uint = -v_f2i_mantissa_uint;
    end

    if (v_f2i_op == 0) begin
      v_f2i_result = {32'h0, v_f2i_mantissa_uint[31:0]};
      if (v_f2i_oor_32s) begin
        v_f2i_result = 64'h000000007FFFFFFF;
        v_f2i_flags  = 5'b10000;
        if (v_f2i_sign_cvt) begin
          if (~(v_f2i_snan | v_f2i_qnan)) begin
            v_f2i_result = 64'h0000000080000000;
          end
        end
      end
    end else if (v_f2i_op == 1) begin
      v_f2i_result = {32'h0, v_f2i_mantissa_uint[31:0]};
      if (v_f2i_oor_32u) begin
        v_f2i_result = 64'h00000000FFFFFFFF;
        v_f2i_flags  = 5'b10000;
        if (v_f2i_sign_cvt) begin
          if (~(v_f2i_snan | v_f2i_qnan)) begin
            v_f2i_result = 64'h0000000000000000;
          end
        end
      end
    end else if (v_f2i_op == 2) begin
      v_f2i_result = v_f2i_mantissa_uint[63:0];
      if (v_f2i_oor_64s) begin
        v_f2i_result = 64'h7FFFFFFFFFFFFFFF;
        v_f2i_flags  = 5'b10000;
        if (v_f2i_sign_cvt) begin
          if (~(v_f2i_snan | v_f2i_qnan)) begin
            v_f2i_result = 64'h8000000000000000;
          end
        end
      end
    end else if (v_f2i_op == 3) begin
      v_f2i_result = v_f2i_mantissa_uint[63:0];
      if (v_f2i_oor_64u) begin
        v_f2i_result = 64'hFFFFFFFFFFFFFFFF;
        v_f2i_flags  = 5'b10000;
        if (v_f2i_sign_cvt) begin
          if (~(v_f2i_snan | v_f2i_qnan)) begin
            v_f2i_result = 64'h0000000000000000;
          end
        end
      end
    end

    oResult_f2i = v_f2i_result;
    oFlags_f2i  = v_f2i_flags;
  end

  always @(*) begin
    v_i2f_data = iData_i2f;
    v_i2f_op = iFcvt_op_i2f;
    v_i2f_fmt = iFmt_i2f;
    v_i2f_rm = iRm_i2f;

    v_i2f_snan = 0;
    v_i2f_qnan = 0;
    v_i2f_dbz = 0;
    v_i2f_infs = 0;
    v_i2f_zero = 0;

    v_i2f_exponent_bias = 127;
    if (v_i2f_fmt == 1) begin
      v_i2f_exponent_bias = 1023;
    end

    v_i2f_sign_uint = 0;
    if (v_i2f_op == 0) begin
      v_i2f_sign_uint = v_i2f_data[31];
    end else if (v_i2f_op == 2) begin
      v_i2f_sign_uint = v_i2f_data[63];
    end

    if (v_i2f_sign_uint) begin
      v_i2f_data = -v_i2f_data;
    end

    v_i2f_mantissa_uint = 64'hFFFFFFFFFFFFFFFF;
    v_i2f_exponent_uint = 0;
    if (!v_i2f_op[1]) begin
      v_i2f_mantissa_uint = {v_i2f_data[31:0], 32'h0};
      v_i2f_exponent_uint = 31;
    end else if (v_i2f_op[1]) begin
      v_i2f_mantissa_uint = v_i2f_data[63:0];
      v_i2f_exponent_uint = 63;
    end

    v_i2f_zero = ~|v_i2f_mantissa_uint;

    lzc_i_a = v_i2f_mantissa_uint;
    v_i2f_counter_uint = ~lzc_o_c;

    v_i2f_mantissa_uint = v_i2f_mantissa_uint << v_i2f_counter_uint;

    v_i2f_sign_rnd = v_i2f_sign_uint;
    v_i2f_exponent_rnd = {8'h0,v_i2f_exponent_uint} + {4'h0,v_i2f_exponent_bias} - {8'h0,v_i2f_counter_uint};

    v_i2f_mantissa_rnd = {30'h0, v_i2f_mantissa_uint[63:40]};
    v_i2f_grs = {v_i2f_mantissa_uint[39:38], |v_i2f_mantissa_uint[37:0]};
    if (v_i2f_fmt == 1) begin
      v_i2f_mantissa_rnd = {1'h0, v_i2f_mantissa_uint[63:11]};
      v_i2f_grs = {v_i2f_mantissa_uint[10:9], |v_i2f_mantissa_uint[8:0]};
    end

    sig_i2f  = v_i2f_sign_rnd;
    expo_i2f = v_i2f_exponent_rnd;
    mant_i2f = v_i2f_mantissa_rnd;
    rema_i2f = 2'h0;
    fmt_i2f  = v_i2f_fmt;
    rm_i2f   = v_i2f_rm;
    grs_i2f  = v_i2f_grs;
    snan_i2f = v_i2f_snan;
    qnan_i2f = v_i2f_qnan;
    dbz_i2f  = v_i2f_dbz;
    infs_i2f = v_i2f_infs;
    zero_i2f = v_i2f_zero;
    diff_i2f = 1'h0;
  end

endmodule
