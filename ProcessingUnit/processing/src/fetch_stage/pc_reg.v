module pc_reg (clk, rstn, next_pc, pc);
    input clk, rstn;
    input [9:0] next_pc;
    output [9:0] pc;

    reg [9:0] temp_pc;
    
    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            temp_pc <= 10'd0;
        end
        else begin
            temp_pc <= next_pc;
        end
    end

    assign pc = temp_pc;

endmodule