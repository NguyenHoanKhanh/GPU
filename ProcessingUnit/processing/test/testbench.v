`include "../include/processing_element_defines.v"
`include "../src/top_module/processing_element.v"

module tb_PE;
    localparam NOP          = 13'b0000_0000_00000;
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
    localparam MADD         = 13'b0000_0010_00000;
    localparam MSUB         = 13'b0000_0010_00001;
    localparam NMADD        = 13'b0000_0010_00010;
    localparam NMSUB        = 13'b0000_0010_00011;
    localparam CLASS        = 13'b0000_0000_00001;
    localparam CVT_f2i      = 13'b0000_0100_00000;
    localparam CVTU_f2i     = 13'b0000_0100_00001;
    localparam CVT_i2f      = 13'b0000_0100_00010;
    localparam CVTU_i2f     = 13'b0000_0100_00011;
    localparam ADDI         = 13'b0000_1000_00000;
    localparam SUBI         = 13'b0000_1000_00001;
    localparam MULI         = 13'b0000_1000_00010;
    localparam MINI         = 13'b0000_1000_00110;
    localparam MAXI         = 13'b0000_1000_00111;
    localparam SEQI         = 13'b0000_1000_01000;
    localparam SLTI         = 13'b0000_1000_01001;
    localparam SLEI         = 13'b0000_1000_01010;
    
    reg clk;
    reg rst_n;
    reg ready;

    // View interface
    reg [127:0] rom[0:1023];
    reg [127:0] instr;
    reg [63:0] command_to_view;
    reg [9:0] counter;

    PE DUT(
        .clk(clk),
        .rstn(rst_n)
    );

    localparam CLK_PERIOD = 10;
    always #(CLK_PERIOD/2) clk = ~clk;

    initial begin
        $dumpfile("tb_PE.vcd");
        $dumpvars(0, tb_PE);
    end

    initial begin
        ready <= 1'b0;
        #1 rst_n <= 1'bx;
        clk <= 1'bx;
        #(CLK_PERIOD*3) rst_n <= 1;
        #(CLK_PERIOD*3) rst_n <= 0;
        ready <= 1'b1;
        clk <= 0;
        repeat (5) 
            @(posedge clk);
        #4;
        rst_n <= 1;
        $readmemh("../include/imem_data.mem", DUT.instr_rom_block.mem);
        $readmemh("../include/imem_data.mem", rom);
        $readmemh("../include/param_rf0_data.mem", DUT.rf_loop[0].param_reg_file.regs);
        // $readmemh("../include/param_rf1_data.mem", DUT.rf_loop[1].param_reg_file.regs);
        // $readmemh("../include/param_rf2_data.mem", DUT.rf_loop[2].param_reg_file.regs);
        // $readmemh("../include/param_rf3_data.mem", DUT.rf_loop[3].param_reg_file.regs);

        repeat (10000) 
            @(posedge clk);
        $finish(2);
    end

    initial begin
        counter = 10'd0;
        @(posedge ready);
        wait (rst_n != 0);
        forever @(posedge clk) begin
            if (rst_n != 1'b0) begin
                instr = rom[counter];
                counter = counter + 1'b1;
                case ({instr[8:0], instr[61:57]})
                    NOP: begin
                        command_to_view = "NOP";
                    end 
                    CLASS: begin
                        command_to_view = "CLASS";
                    end 
                    ADD: begin
                        command_to_view = "ADD";
                    end 
                    ADDI: begin
                        command_to_view = "ADDI";
                    end
                    SUB: begin
                        command_to_view = "SUB";
                    end 
                    SUBI: begin
                        command_to_view = "SUBI";
                    end 
                    MUL: begin
                        command_to_view = "MUL";
                    end 
                    MULI: begin
                        command_to_view = "MULI";
                    end 
                    SGNJ: begin
                        command_to_view = "SGNJ";
                    end 
                    SGNJN: begin
                        command_to_view = "SGNJN";
                    end 
                    SGNJX: begin
                        command_to_view = "SGNJX";
                    end 
                    MIN: begin
                        command_to_view = "MIN";
                    end 
                    MINI: begin
                        command_to_view = "MIN_I";
                    end 
                    MAX: begin
                        command_to_view = "MAX";
                    end 
                    MAXI: begin
                        command_to_view = "MAX_I";
                    end 
                    SEQ: begin
                        command_to_view = "SEQ";
                    end 
                    SLT: begin
                        command_to_view = "SLT";
                    end 
                    SLE: begin
                        command_to_view = "SLE";
                    end 
                    SEQI: begin
                        command_to_view = "SEQ_I";
                    end 
                    SLTI: begin
                        command_to_view = "SLT_I";
                    end 
                    SLEI: begin
                        command_to_view = "SLE_I";
                    end 
                    MADD: begin
                        command_to_view = "MADD";
                    end 
                    MSUB: begin
                        command_to_view = "MSUB";
                    end 
                    NMADD: begin
                        command_to_view = "NMADD";
                    end 
                    NMSUB: begin
                        command_to_view = "NMSUB";
                    end 
                    CVT_f2i: begin
                        command_to_view = "CVT_f2i";
                    end 
                    CVTU_f2i: begin
                        command_to_view = "CVTU_f2i";
                    end 
                    CVT_i2f: begin
                        command_to_view = "CVT_i2f";
                    end 
                    CVTU_i2f: begin
                        command_to_view = "CVTU_i2f";
                    end 
                    default: begin
                        command_to_view = "Unknown";
                    end
                endcase
            end
            else begin
                counter = 10'd0;
            end
        end
    end

endmodule