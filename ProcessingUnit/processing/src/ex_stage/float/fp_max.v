module fp_max (
  input [63:0]      fp_max_i_data1,
  input [63:0]      fp_max_i_data2,
  input [64:0]      fp_max_i_ext1,
  input [64:0]      fp_max_i_ext2,
  input [1:0]       fp_max_i_fmt,
  input [2:0]       fp_max_i_rm,
  input [9:0]       fp_max_i_class1,
  input [9:0]       fp_max_i_class2,
  output reg [63:0] fp_max_o_result,
  output reg [4:0]  fp_max_o_flags
);

  reg [63:0] data1;
  reg [63:0] data2;
  reg [64:0] extend1;
  reg [64:0] extend2;
  reg [1:0] fmt;
  reg [2:0] rm;
  reg [9:0] class1;
  reg [9:0] class2;

  reg [63:0] nan;
  reg comp;

  reg [63:0] result;
  reg [4:0] flags;

  always @(*) begin
    data1 = fp_max_i_data1;
    data2 = fp_max_i_data2;
    extend1 = fp_max_i_ext1;
    extend2 = fp_max_i_ext2;
    fmt = fp_max_i_fmt;
    rm = fp_max_i_rm;
    class1 = fp_max_i_class1;
    class2 = fp_max_i_class2;

    nan = 64'h7ff8000000000000;
    comp = 0;

    result = 0;
    flags = 0;

    if (fmt == 0) begin
      nan = 64'h000000007fc00000;
    end

    if (extend1[63:0] > extend2[63:0]) begin
      comp = 1;
    end

    if (rm == 0) begin
      if ((class1[8] & class2[8]) == 1) begin
        result   = nan;
        flags[4] = 1;
      end else if (class1[8] == 1) begin
        result   = data2;
        flags[4] = 1;
      end else if (class2[8] == 1) begin
        result   = data1;
        flags[4] = 1;
      end else if ((class1[9] & class2[9]) == 1) begin
        result = nan;
      end else if (class1[9] == 1) begin
        result = data2;
      end else if (class2[9] == 1) begin
        result = data1;
      end else if ((extend1[64] ^ extend2[64]) == 1) begin
        if (extend1[64] == 1) begin
          result = data1;
        end else begin
          result = data2;
        end
      end else begin
        if (extend1[64] == 1) begin
          if (comp == 1) begin
            result = data1;
          end else begin
            result = data2;
          end
        end else begin
          if (comp == 0) begin
            result = data1;
          end else begin
            result = data2;
          end
        end
      end
    end 
    else if (rm == 1) begin
      if ((class1[8] & class2[8]) == 1) begin
        result   = nan;
        flags[4] = 1;
      end else if (class1[8] == 1) begin
        result   = data2;
        flags[4] = 1;
      end else if (class2[8] == 1) begin
        result   = data1;
        flags[4] = 1;
      end else if ((class1[9] & class2[9]) == 1) begin
        result = nan;
      end else if (class1[9] == 1) begin
        result = data2;
      end else if (class2[9] == 1) begin
        result = data1;
      end else if ((extend1[64] ^ extend2[64]) == 1) begin
        if (extend1[64] == 1) begin
          result = data2;
        end else begin
          result = data1;
        end
      end else begin
        if (extend1[64] == 1) begin
          if (comp == 1) begin
            result = data2;
          end else begin
            result = data1;
          end
        end else begin
          if (comp == 0) begin
            result = data2;
          end else begin
            result = data1;
          end
        end
      end
    end

    fp_max_o_result = result;
    fp_max_o_flags  = flags;
  end

endmodule
