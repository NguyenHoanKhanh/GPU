`include "../include/processing_element_defines.v"
`include "../../PE_wrapper/processing_element_wrapper.v"

module tb_PE_wrapper;

    // Clock and reset
    reg iClk;
    reg iReset_n;
    reg iShader_rst_n;
    reg iChipSelect_n;
    reg iWrite_n;
    reg iRead_n;
    reg [31:0] iAddress;
    reg [31:0] iData;
    wire [31:0] oData;

    // Instantiate the DUT (Device Under Test)
    PE_wrapper #(   
        .DataWidth(32),
        .TotalNumBank(2),
        .AddrWidth(5)
    ) uut (
        .iClk(iClk),
        .iReset_n(iReset_n),
        .iShader_rst_n(iShader_rst_n),
        .iChipSelect_n(iChipSelect_n),
        .iWrite_n(iWrite_n),
        .iRead_n(iRead_n),
        .iAddress(iAddress),
        .iData(iData),
        .oData(oData)
    );

    // Clock generation
    always #5 iClk = ~iClk;

    // Task to write to DUT
    task write_input;
        input [3:0] addr;
        input [31:0] data;
        begin
            @(negedge iClk);
            iChipSelect_n = 0;
            iWrite_n = 0;
            iAddress = addr;
            iData = data;
            @(negedge iClk);
            iWrite_n = 1;
            iChipSelect_n = 1;
        end
    endtask

    // Task to read from DUT
    task read_output;
        input [3:0] addr;
        begin
            @(negedge iClk);
            iChipSelect_n = 0;
            iRead_n = 0;
            iAddress = addr;
            @(negedge iClk);
            iRead_n = 1;
            iChipSelect_n = 1;
        end
    endtask

    initial begin
        iShader_rst_n = 1'b1;
        #260;
        iShader_rst_n = 1'b0;
        #7;
        iShader_rst_n = 1'b1;
    end

    initial begin
        // Initialize signals
        iClk = 0;
        iReset_n = 0;
        iChipSelect_n = 1;
        iWrite_n = 1;
        iRead_n = 1;
        iAddress = 0;
        iData = 0;

        // Reset sequence
        #20;
        iReset_n = 1;

        // --- Write first 128-bit instruction ---
        write_input(32'd0, 32'h00000000); // Address to write: 0
        write_input(32'd1, 32'hDEADBEEF); // Data1
        write_input(32'd2, 32'hCAFEBABE); // Data2
        write_input(32'd3, 32'h12345678); // Data3
        write_input(32'd4, 32'h87654321); // Data4
        write_input(32'd5, 32'h00000001); // Trigger write (done_input_cmd = 1)

        // --- Write second 128-bit instruction ---
        write_input(32'd0, 32'h00000001); // Address to write: 1
        write_input(32'd1, 32'h11111111);
        write_input(32'd2, 32'h22222222);
        write_input(32'd3, 32'h33333333);
        write_input(32'd4, 32'h44444444);
        write_input(32'd5, 32'h00000001); // done_input_cmd = 1

        // Wait a few cycles for processing
        #50;

        // --- Attempt to read buffer data ---
        read_output(32'd0);
        #10;
        $display("Read oData = %h", oData);

        read_output(32'd1);
        #10;
        $display("Read oData = %h", oData);

        $finish;
    end

    initial begin
        $dumpfile("tb_wrapper.vcd");
        $dumpvars(0);
    end
endmodule
