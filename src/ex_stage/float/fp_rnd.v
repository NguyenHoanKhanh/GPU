module fp_rnd (
  input             fp_rnd_i_sig,
  input [13:0]      fp_rnd_i_expo,
  input [53:0]      fp_rnd_i_mant,
  input [1:0]       fp_rnd_i_rema,
  input [1:0]       fp_rnd_i_fmt,
  input [2:0]       fp_rnd_i_rm,
  input [2:0]       fp_rnd_i_grs,
  input             fp_rnd_i_snan,
  input             fp_rnd_i_qnan,
  input             fp_rnd_i_dbz,
  input             fp_rnd_i_infs,
  input             fp_rnd_i_zero,
  input             fp_rnd_i_diff,

  output reg [63:0] fp_rnd_o_result,
  output reg [4:0]  fp_rnd_o_flags
);

  reg sig;
  reg [13:0] expo;
  reg [53:0] mant;
  reg [1:0] rema;
  reg [1:0] fmt;
  reg [2:0] rm;
  reg [2:0] grs;
  reg snan;
  reg qnan;
  reg dbz;
  reg infs;
  reg zero;
  reg diff;

  reg odd;
  reg rndup;
  reg rnddn;
  reg shift;
  reg [63:0] result;
  reg [4:0] flags;

  always @(*) begin
    sig = fp_rnd_i_sig;
    expo = fp_rnd_i_expo;
    mant = fp_rnd_i_mant;
    rema = fp_rnd_i_rema;
    fmt = fp_rnd_i_fmt;
    rm = fp_rnd_i_rm;
    grs = fp_rnd_i_grs;
    snan = fp_rnd_i_snan;
    qnan = fp_rnd_i_qnan;
    dbz = fp_rnd_i_dbz;
    infs = fp_rnd_i_infs;
    zero = fp_rnd_i_zero;
    diff = fp_rnd_i_diff;

    result = 0;
    flags = 0;

    odd = mant[0] | (|grs[1:0]) | (rema == 1);
    flags[0] = (rema != 0) | (|grs);

    rndup = 0;
    rnddn = 0;
    if (rm == 0) begin  //rne
      if (grs[2] & odd) begin
        rndup = 1;
      end
    end 
    else if (rm == 1) begin  //rtz
      rnddn = 1;
    end 
    else if (rm == 2) begin  //rdn
      if (sig & flags[0]) begin
        rndup = 1;
      end 
      else if (~sig & zero & diff) begin
        sig = ~sig;
      end 
      else if (~sig) begin
        rnddn = 1;
      end
    end 
    else if (rm == 3) begin  //rup
      if (~sig & flags[0]) begin
        rndup = 1;
      end 
      else if (sig) begin
        rnddn = 1;
      end
    end 
    else if (rm == 4) begin  //rmm
      if (grs[2] & flags[0]) begin
        rndup = 1;
      end
    end

    //if (expo == 0) begin
    //	flags[1] = flags[0];
    //end

    mant = mant + {53'h0, rndup};

    if (rndup == 1) begin
      if (fmt == 0) begin
        if (expo == 0) begin
          if (mant[23]) begin
            expo = 1;
          end
        end
      end 
      else if (fmt == 1) begin
        if (expo == 0) begin
          if (mant[52]) begin
            expo = 1;
          end
        end
      end
    end

    if (rnddn == 1) begin
      if (fmt == 0) begin
        if (expo >= 255) begin
          expo  = 254;
          mant  = {31'b0, {23{1'b1}}};
          flags = 5'b00101;
        end
      end 
      else if (fmt == 1) begin
        if (expo >= 2047) begin
          expo  = 2046;
          mant  = {2'b0, {52{1'b1}}};
          flags = 5'b00101;
        end
      end
    end

    shift = 0;
    if (fmt == 0) begin
      if (mant[24]) begin
        shift = 1;
      end
    end 
    else if (fmt == 1) begin
      if (mant[53]) begin
        shift = 1;
      end
    end

    expo = expo + {13'h0, shift};
    mant = mant >> shift;

    if (expo == 0) begin
      flags[1] = flags[0];
    end

    if (rndup == 1) begin
      if (expo == 1) begin
        if (fmt == 0 && |mant[22:0] == 0) begin
          flags[1] = rm == 2 || rm == 3 ? ((grs == 1) | (grs == 2) | (grs == 3) | (grs == 4)) : ((grs == 4) | (grs == 5));
        end 
        else if (fmt == 1 && |mant[51:0] == 0) begin
          flags[1] = rm == 2 || rm == 3 ? ((grs == 1) | (grs == 2) | (grs == 3) | (grs == 4)) : ((grs == 4) | (grs == 5));
        end
      end
    end

    if (snan) begin
      flags = 5'b10000;
    end 
    else if (qnan) begin
      flags = 5'b00000;
    end 
    else if (dbz) begin
      flags = 5'b01000;
    end 
    else if (infs) begin
      flags = 5'b00000;
    end 
    else if (zero) begin
      flags = 5'b00000;
    end

    if (fmt == 0) begin
      if (snan | qnan) begin
        result = {32'h00000000, 1'h0, 8'hFF, 23'h400000};
      end 
      else if (dbz | infs) begin
        result = {32'h00000000, sig, 8'hFF, 23'h000000};
      end 
      else if (zero) begin
        result = {32'h00000000, sig, 8'h00, 23'h000000};
      end 
      else if (expo == 0) begin
        result = {32'h00000000, sig, 8'h00, mant[22:0]};
      end 
      else if ($signed(expo) > 254) begin
        flags  = 5'b00101;
        result = {32'h00000000, sig, 8'hFF, 23'h000000};
      end 
      else begin
        result = {32'h00000000, sig, expo[7:0], mant[22:0]};
      end
    end 
    else if (fmt == 1) begin
      if (snan | qnan) begin
        result = {1'h0, 11'h7FF, 52'h8000000000000};
      end 
      else if (dbz | infs) begin
        result = {sig, 11'h7FF, 52'h0000000000000};
      end 
      else if (zero) begin
        result = {sig, 11'h000, 52'h0000000000000};
      end 
      else if (expo == 0) begin
        result = {sig, 11'h000, mant[51:0]};
      end 
      else if ($signed(expo) > 2046) begin
        flags  = 5'b00101;
        result = {sig, 11'h7FF, 52'h0000000000000};
      end 
      else begin
        result = {sig, expo[10:0], mant[51:0]};
      end
    end

    fp_rnd_o_result = result;
    fp_rnd_o_flags  = flags;
  end

endmodule
