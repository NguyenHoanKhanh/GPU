module control_unit #(
    parameter TotalNumBank = 8,
    parameter AddrWidth = 5
) (
    input [127:0]                   instr,
    output reg [16:0]               fp_opcode,
    output reg                      fp_en,
    output reg [2:0]                fp_rm,  
    output reg [(TotalNumBank-1):0] writeEn,
    output reg [(AddrWidth-1):0]    writeAddr,
    output reg                      pipe,
    output reg                      ALUSrc
);
    
    // Arith_R0     = 8'b0000_0000;
    localparam NOP          = 13'b0000_0000_00000;
    // Arith_R3     = 8'b0000_0001;
    localparam ADD          = 13'b0000_0001_00000;
    localparam SUB          = 13'b0000_0001_00001;
    localparam MUL          = 13'b0000_0001_00010;
    localparam SGNJ         = 13'b0000_0001_00011;
    localparam SGNJN        = 13'b0000_0001_00100;
    localparam SGNJX        = 13'b0000_0001_00101;
    localparam MIN          = 13'b0000_0001_00110;
    localparam MAX          = 13'b0000_0001_00111;
    localparam SEQ          = 13'b0000_0001_01000;
    localparam SLT          = 13'b0000_0001_01001;
    localparam SLE          = 13'b0000_0001_01010;
    // Arith_R4     = 8'b0000_0010;
    localparam MADD         = 13'b0000_0010_00000;
    localparam MSUB         = 13'b0000_0010_00001;
    localparam NMADD        = 13'b0000_0010_00010;
    localparam NMSUB        = 13'b0000_0010_00011;
    // Arith_R2     = 8'b0000_0100;
    localparam CLASS        = 13'b0000_0000_00001;
    localparam CVT_f2i      = 13'b0000_0100_00000;
    localparam CVTU_f2i     = 13'b0000_0100_00001;
    localparam CVT_i2f      = 13'b0000_0100_00010;
    localparam CVTU_i2f     = 13'b0000_0100_00011;
    // Arith_I      = 8'b0000_1000;
    localparam ADDI         = 13'b0000_1000_00000;
    localparam SUBI         = 13'b0000_1000_00001;
    localparam MULI         = 13'b0000_1000_00010;
    localparam MINI         = 13'b0000_1000_00110;
    localparam MAXI         = 13'b0000_1000_00111;
    localparam SEQI         = 13'b0000_1000_01000;
    localparam SLTI         = 13'b0000_1000_01001;
    localparam SLEI         = 13'b0000_1000_01010;

    reg [7:0] opcode;
    reg [4:0] funct;
    reg [2:0] resbank;
    reg [7:0] resreg;
    reg [2:0] rm;

    always @(*) begin
        opcode = instr[7:0];
        funct = instr[61:57];
        resbank = instr[34:32];
        resreg = instr[87:80];
        rm = instr[56:54];

        case ({opcode, funct})
            NOP: begin
                fp_opcode = 17'd0;
                fp_en = 1'b0;
                fp_rm = 3'd0;
                writeEn = {TotalNumBank{1'b0}};
                writeAddr = {AddrWidth{1'b0}};
                ALUSrc = 1'b0;
                pipe = 1'b0;
            end 
            CLASS: begin
                fp_opcode = 17'd0;
                fp_opcode[6] = 1'b1;
                fp_en = 1'b1;
                fp_rm = 3'b000;
                writeEn = {TotalNumBank{1'b0}};
                writeEn[resbank] = 1'b1;
                writeAddr = resreg[(AddrWidth-1):0];
                ALUSrc = 1'b0;
                pipe = 1'b0;
            end 
            ADD, ADDI: begin
                fp_opcode = 17'd0;
                fp_opcode[12] = 1'b1;
                fp_en = 1'b1;
                fp_rm = rm;
                writeEn = {TotalNumBank{1'b0}};
                writeEn[resbank] = 1'b1;
                writeAddr = resreg[(AddrWidth-1):0];
                ALUSrc = ({opcode, funct} == ADD) ? 1'b0 : 1'b1;
                pipe = 1'b1;
            end 
            SUB, SUBI: begin
                fp_opcode = 17'd0;
                fp_opcode[11] = 1'b1;
                fp_en = 1'b1;
                fp_rm = rm;
                writeEn = {TotalNumBank{1'b0}};
                writeEn[resbank] = 1'b1;
                writeAddr = resreg[(AddrWidth-1):0];
                ALUSrc = ({opcode, funct} == SUB) ? 1'b0 : 1'b1;
                pipe = 1'b1;
            end 
            MUL, MULI: begin
                fp_opcode = 17'd0;
                fp_opcode[10] = 1'b1;
                fp_en = 1'b1;
                fp_rm = rm;
                writeEn = {TotalNumBank{1'b0}};
                writeEn[resbank] = 1'b1;
                writeAddr = resreg[(AddrWidth-1):0];
                ALUSrc = ({opcode, funct} == MUL) ? 1'b0 : 1'b1;
                pipe = 1'b1;
            end 
            SGNJ, SGNJN, SGNJX: begin
                fp_opcode = 17'd0;
                fp_opcode[9] = 1'b1;
                fp_en = 1'b1;
                fp_rm = ({opcode, funct} == SGNJ) ? 3'b000 : (({opcode, funct} == SGNJN) ? 3'b001 : 3'b010);
                writeEn = {TotalNumBank{1'b0}};
                writeEn[resbank] = 1'b1;
                writeAddr = resreg[(AddrWidth-1):0];
                ALUSrc = 1'b0;
                pipe = 1'b0;
            end 
            MIN, MINI, MAX, MAXI: begin
                fp_opcode = 17'd0;
                fp_opcode[7] = 1'b1;
                fp_en = 1'b1;
                fp_rm = (({opcode, funct} == MIN) | ({opcode, funct} == MINI)) ? 3'b000 : 3'b001;
                writeEn = {TotalNumBank{1'b0}};
                writeEn[resbank] = 1'b1;
                writeAddr = resreg[(AddrWidth-1):0];
                ALUSrc = (({opcode, funct} == MIN) | ({opcode, funct} == MAX)) ? 1'b0 : 1'b1;
                pipe = 1'b0;
            end 
            SEQ, SLT, SLE, SEQI, SLTI, SLEI: begin
                fp_opcode = 17'd0;
                fp_opcode[8] = 1'b1;
                fp_en = 1'b1;
                fp_rm = (({opcode, funct} == SLE) | ({opcode, funct} == SLEI)) ? 3'b000 : ((({opcode, funct} == SLT) | ({opcode, funct} == SLTI)) ? 3'b001 : 3'b010);
                writeEn = {TotalNumBank{1'b0}};
                writeEn[resbank] = 1'b1;
                writeAddr = resreg[(AddrWidth-1):0];
                ALUSrc = (({opcode, funct} == SEQ) | ({opcode, funct} == SLT) | ({opcode, funct} == SLE)) ? 1'b0 : 1'b1;
                pipe = 1'b0;
            end 
            MADD: begin
                fp_opcode = 17'd0;
                fp_opcode[16] = 1'b1;
                fp_en = 1'b1;
                fp_rm = rm;
                writeEn = {TotalNumBank{1'b0}};
                writeEn[resbank] = 1'b1;
                writeAddr = resreg[(AddrWidth-1):0];
                ALUSrc = 1'b0;
                pipe = 1'b1;
            end 
            MSUB: begin
                fp_opcode = 17'd0;
                fp_opcode[15] = 1'b1;
                fp_en = 1'b1;
                fp_rm = rm;
                writeEn = {TotalNumBank{1'b0}};
                writeEn[resbank] = 1'b1;
                writeAddr = resreg[(AddrWidth-1):0];
                ALUSrc = 1'b0;
                pipe = 1'b1;
            end 
            NMADD: begin
                fp_opcode = 17'd0;
                fp_opcode[14] = 1'b1;
                fp_en = 1'b1;
                fp_rm = rm;
                writeEn = {TotalNumBank{1'b0}};
                writeEn[resbank] = 1'b1;
                writeAddr = resreg[(AddrWidth-1):0];
                ALUSrc = 1'b0;
                pipe = 1'b1;
            end 
            NMSUB: begin
                fp_opcode = 17'd0;
                fp_opcode[13] = 1'b1;
                fp_en = 1'b1;
                fp_rm = rm;
                writeEn = {TotalNumBank{1'b0}};
                writeEn[resbank] = 1'b1;
                writeAddr = resreg[(AddrWidth-1):0];
                ALUSrc = 1'b0;
                pipe = 1'b1;
            end 
            CVT_f2i, CVTU_f2i: begin
                fp_opcode = 17'd0;
                fp_opcode[2] = 1'b1;
                fp_opcode[1:0] = ({opcode, funct} == CVT_f2i) ? 2'b00 : 2'b01;
                fp_en = 1'b1;
                fp_rm = rm;
                writeEn = {TotalNumBank{1'b0}};
                writeEn[resbank] = 1'b1;
                writeAddr = resreg[(AddrWidth-1):0];
                ALUSrc = 1'b0;
                pipe = 1'b0;
            end 
            CVT_i2f, CVTU_i2f: begin
                fp_opcode = 17'd0;
                fp_opcode[3] = 1'b1;
                fp_opcode[1:0] = ({opcode, funct} == CVT_i2f) ? 2'b00 : 2'b01;
                fp_en = 1'b1;
                fp_rm = rm;
                writeEn = {TotalNumBank{1'b0}};
                writeEn[resbank] = 1'b1;
                writeAddr = resreg[(AddrWidth-1):0];
                ALUSrc = 1'b0;
                pipe = 1'b0;
            end 
            default: begin
                fp_opcode = 17'd0;
                fp_en = 1'b0;
                fp_rm = 3'd0;
                writeEn = {TotalNumBank{1'b0}};
                writeAddr = {AddrWidth{1'b0}};
                ALUSrc = 1'b0;
                pipe = 1'b0;
            end
        endcase
    end

endmodule