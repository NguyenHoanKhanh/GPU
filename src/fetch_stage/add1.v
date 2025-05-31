module add1 (pc_in, pc_out);
    input [9:0] pc_in;
    output [9:0] pc_out;

    assign pc_out = pc_in + 10'd1;
endmodule