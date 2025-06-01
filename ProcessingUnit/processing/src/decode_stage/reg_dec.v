module reg_dec #(
    parameter TotalNumBank = 8,
    parameter AddrWidth = 5
) (
    input [127:0]                       instr,
    output reg [(TotalNumBank-1):0]     readEn1,
    output reg [(TotalNumBank-1):0]     readEn2,
    output reg [(TotalNumBank-1):0]     readEn3,
    output reg [(AddrWidth-1):0]        readAddr1,
    output reg [(AddrWidth-1):0]        readAddr2,
    output reg [(AddrWidth-1):0]        readAddr3
);
    
    reg [7:0] opcode;
    reg [2:0] op1bank, op2bank, op3bank;
    reg [7:0] op1reg, op2reg, op3reg;

    always @(*) begin
        opcode = instr[7:0];
        op1bank = instr[19:17];
        op2bank = instr[24:22];
        op3bank = instr[29:27];
        op1reg = instr[71:64];
        op2reg = instr[95:88];
        op3reg = instr[111:104];

        if ((opcode == 8'd1) | (opcode == 8'd2) | (opcode == 8'd4) | (opcode == 8'd8)) begin
            readEn1 = {TotalNumBank{1'b0}};
            readEn1[op1bank] = 1'b1;
            readAddr1 = op1reg[(AddrWidth-1):0];
        end
        else begin
            readEn1 = {TotalNumBank{1'b0}};
            readAddr1 = {AddrWidth{1'b0}};
        end

        if ((opcode == 8'd1) | (opcode == 8'd2)) begin
            readEn2 = {TotalNumBank{1'b0}};
            readEn2[op2bank] = 1'b1;
            readAddr2 = op2reg[(AddrWidth-1):0];
        end
        else begin
            readEn2 = {TotalNumBank{1'b0}};
            readAddr2 = {AddrWidth{1'b0}};
        end

        if (opcode == 8'd2) begin
            readEn3 = {TotalNumBank{1'b0}};
            readEn3[op3bank] = 1'b1;
            readAddr3 = op3reg[(AddrWidth-1):0];
        end
        else begin
            readEn3 = {TotalNumBank{1'b0}};
            readAddr3 = {AddrWidth{1'b0}};
        end
    end
endmodule