module mux3_1 #(parameter DWIDTH = 1) (
    input [(DWIDTH-1):0]       inpA,
    input [(DWIDTH-1):0]       inpB,
    input [(DWIDTH-1):0]       inpC,
    input [1:0]                sel,
    output reg [(DWIDTH-1):0]  outp
);
    always @(*) begin
        case (sel)
            2'b00: outp = inpA;
            2'b01: outp = inpB; 
            2'b10: outp = inpC; 
            default: outp = {DWIDTH{1'bx}};
        endcase
    end
endmodule