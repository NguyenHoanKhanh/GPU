
module fp_cmp (
  input [64:0]        iData1,
  input [64:0]        iData2,
  input [2:0]         iRm,
  input [9:0]         iClass1,
  input [9:0]         iClass2,
  output reg [63:0]   oResult,
  output reg [4:0]    oFlags
);

  reg [64:0] data1;
  reg [64:0] data2;
  reg [2:0] rm;
  reg [9:0] class1;
  reg [9:0] class2;

  reg comp_lt;
  reg comp_le;
  reg [63:0] result;
  reg [4:0] flags;

  always @(*) begin
    data1 = iData1;
    data2 = iData2;
    rm = iRm;
    class1 = iClass1;
    class2 = iClass2;

    comp_lt = 0;
    comp_le = 0;
    result = 0;
    flags = 0;

    if ((rm == 3'd0) || (rm == 3'd1) || (rm == 3'd2)) begin
      comp_lt = (data1[63:0] < data2[63:0]) ? 1'b1 : 1'b0;
      comp_le = (data1[63:0] <= data2[63:0]) ? 1'b1 : 1'b0;
    end

    if (rm == 3'd2) begin  //feq
      if ((class1[8] | class2[8]) == 1'b1) begin
        flags[4] = 1;
      end else if ((class1[9] | class2[9]) == 1'b1) begin
        flags[0] = 0;
      end else if (((class1[3] | class1[4]) & (class2[3] | class2[4])) == 1'b1) begin
        result[0] = 1;
      end else if (data1 == data2) begin
        result[0] = 1;
      end
    end else if (rm == 3'd1) begin  //flt
      if ((class1[8] | class2[8] | class1[9] | class2[9]) == 1'b1) begin
        flags[4] = 1;
      end else if (((class1[3] | class1[4]) & (class2[3] | class2[4])) == 1'b1) begin
        result[0] = 0;
      end else if ((data1[64] ^ data2[64]) == 1'b1) begin
        result[0] = data1[64];
      end else begin
        if (data1[64] == 1'b1) begin
          result[0] = ~comp_le;
        end else begin
          result[0] = comp_lt;
        end
      end
    end else if (rm == 3'd0) begin  //fle
      if ((class1[8] | class2[8] | class1[9] | class2[9]) == 1'b1) begin
        flags[4] = 1;
      end else if (((class1[3] | class1[4]) & (class2[3] | class2[4])) == 1'b1) begin
        result[0] = 1;
      end else if ((data1[64] ^ data2[64]) == 1'b1) begin
        result[0] = data1[64];
      end else begin
        if (data1[64] == 1'b0) begin
          result[0] = comp_le;
        end else begin
          result[0] = ~comp_lt;
        end
      end
    end

    oResult = result;
    oFlags = flags;
  end

endmodule
