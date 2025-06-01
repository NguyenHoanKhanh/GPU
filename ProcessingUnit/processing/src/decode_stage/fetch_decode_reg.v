module fetch_decode_reg (clk, rstn, en, instr_f, instr_d);
    input clk, rstn, en;
    input [127:0] instr_f;
    output [127:0] instr_d;

    reg [127:0] temp_instr;

    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            temp_instr <= 128'd0;
        end
        else if (en) begin
            temp_instr <= instr_f;
        end
        else begin
            temp_instr <= temp_instr;
        end
    end

    assign instr_d = temp_instr;

endmodule