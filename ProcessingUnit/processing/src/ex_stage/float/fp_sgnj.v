module fp_sgnj (
  input [63:0]      fp_sgnj_i_data1,
  input [63:0]      fp_sgnj_i_data2,
  input [1:0]       fp_sgnj_i_fmt,
  input [2:0]       fp_sgnj_i_rm,
  output reg [63:0] fp_sgnj_o_result
);

  reg [63:0] data1;
  reg [63:0] data2;
  reg [ 1:0] fmt;
  reg [ 2:0] rm;
  reg [63:0] result;

  always @(*) begin
    data1 = fp_sgnj_i_data1;
    data2 = fp_sgnj_i_data2;
    fmt = fp_sgnj_i_fmt;
    rm = fp_sgnj_i_rm;

    result = 0;

    if (fmt == 0) begin
      result[30:0] = data1[30:0];
      if (rm == 0) begin
        result[31] = data2[31];
      end 
      else if (rm == 1) begin
        result[31] = ~data2[31];
      end 
      else if (rm == 2) begin
        result[31] = data1[31] ^ data2[31];
      end
    end 
    else if (fmt == 1) begin
      result[62:0] = data1[62:0];
      if (rm == 0) begin
        result[63] = data2[63];
      end 
      else if (rm == 1) begin
        result[63] = ~data2[63];
      end 
      else if (rm == 2) begin
        result[63] = data1[63] ^ data2[63];
      end
    end

    fp_sgnj_o_result = result;
  end

endmodule
