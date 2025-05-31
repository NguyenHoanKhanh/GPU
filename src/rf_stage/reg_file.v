module reg_file #(
    parameter DataWidth  = 32,
    parameter NumRegs    = 32*4,    // 32 register 128 bits -> each is 4 dimensions
    parameter IndexWidth = 5,
    parameter IsConstant = 0
) (
    input                           clk,
    input                           rstn,
    input                           writeEn,
    input [IndexWidth-1:0]          writeAddr,
    input [(DataWidth*4)-1:0]       writeData,
    input [3:0]                     writeMask,
    input                           readEn1,
    input                           readEn2,
    input                           readEn3,
    input [IndexWidth-1:0]          readAddr1,
    input [IndexWidth-1:0]          readAddr2,
    input [IndexWidth-1:0]          readAddr3,
    input [7:0]                     readSwizzle1,
    input [7:0]                     readSwizzle2,
    input [7:0]                     readSwizzle3,
    output reg [(DataWidth*4)-1:0]  readData1,
    output reg [(DataWidth*4)-1:0]  readData2,
    output reg [(DataWidth*4)-1:0]  readData3
);

    reg [DataWidth-1:0] regs[0:(NumRegs-1)];
    integer i;

    reg [6:0] exactReadAddr1[0:3];
    reg [6:0] baseReadAddr1;
    reg [6:0] exactReadAddr2[0:3];
    reg [6:0] baseReadAddr2;
    reg [6:0] exactReadAddr3[0:3];
    reg [6:0] baseReadAddr3;

    always @(negedge clk, negedge rstn) begin
        if (IsConstant == 0) begin
            if (~rstn) begin
                for (i = 0; i < NumRegs; i = i + 1) begin
                    regs[i] <= 'd0;
                end
            end
            else if ((writeEn == 1'b1) & (writeAddr != 0) & (writeAddr < (NumRegs/4))) begin
                regs[(writeAddr*4) + 5'd0] <= writeData[(DataWidth*0) +: DataWidth] & {DataWidth{writeMask[0]}};
                regs[(writeAddr*4) + 5'd1] <= writeData[(DataWidth*1) +: DataWidth] & {DataWidth{writeMask[1]}};
                regs[(writeAddr*4) + 5'd2] <= writeData[(DataWidth*2) +: DataWidth] & {DataWidth{writeMask[2]}};
                regs[(writeAddr*4) + 5'd3] <= writeData[(DataWidth*3) +: DataWidth] & {DataWidth{writeMask[3]}};
            end
            else begin
                for (i = 0; i < NumRegs; i = i + 1) begin
                    regs[i] <= regs[i];
                end
            end
        end
        else begin
            if (~rstn) begin
                for (i = 0; i < NumRegs; i = i + 1) begin
                    regs[i] <= 'd0;
                end
            end
            else begin
                for (i = 0; i < NumRegs; i = i + 1) begin
                    regs[i] <= regs[i];
                end
            end
        end
    end

    always @(*) begin
        baseReadAddr1 = readAddr1 << 2;
        exactReadAddr1[0] = baseReadAddr1 + readSwizzle1[1:0];
        exactReadAddr1[1] = baseReadAddr1 + readSwizzle1[3:2];
        exactReadAddr1[2] = baseReadAddr1 + readSwizzle1[5:4];
        exactReadAddr1[3] = baseReadAddr1 + readSwizzle1[7:6];
        readData1 = (readEn1 == 1'b1) ? {regs[exactReadAddr1[3]], regs[exactReadAddr1[2]], regs[exactReadAddr1[1]], regs[exactReadAddr1[0]]} : {(DataWidth*4){1'bz}};

        baseReadAddr2 = readAddr2 << 2;
        exactReadAddr2[0] = baseReadAddr2 + readSwizzle2[1:0];
        exactReadAddr2[1] = baseReadAddr2 + readSwizzle2[3:2];
        exactReadAddr2[2] = baseReadAddr2 + readSwizzle2[5:4];
        exactReadAddr2[3] = baseReadAddr2 + readSwizzle2[7:6];
        readData2 = (readEn2 == 1'b1) ? {regs[exactReadAddr2[3]], regs[exactReadAddr2[2]], regs[exactReadAddr2[1]], regs[exactReadAddr2[0]]} : {(DataWidth*4){1'bz}};

        baseReadAddr3 = readAddr3 << 2;
        exactReadAddr3[0] = baseReadAddr3 + readSwizzle3[1:0];
        exactReadAddr3[1] = baseReadAddr3 + readSwizzle3[3:2];
        exactReadAddr3[2] = baseReadAddr3 + readSwizzle3[5:4];
        exactReadAddr3[3] = baseReadAddr3 + readSwizzle3[7:6];
        readData3 = (readEn3 == 1'b1) ? {regs[exactReadAddr3[3]], regs[exactReadAddr3[2]], regs[exactReadAddr3[1]], regs[exactReadAddr3[0]]} : {(DataWidth*4){1'bz}};
    end
    
endmodule