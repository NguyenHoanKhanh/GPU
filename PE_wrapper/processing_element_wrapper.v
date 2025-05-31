`ifdef PE_SoC

module PE_wrapper #(
    parameter DataWidth  = 32,
    parameter TotalNumBank = 2,
    parameter AddrWidth = 5
) (
    input             iClk,
    input             iReset_n,
    input             iShader_rst_n,
    input             iChipSelect_n,
    input             iWrite_n,
    input             iRead_n,
    input [31:0]      iAddress,
    input [31:0]      iData,
    output [31:0]     oData
);

    wire [127:0] instr; 
    wire [(DataWidth*4-1):0] data_out;
    wire [3:0] ready_out;
    wire [9:0] instr_addr_out;
    
    reg [9:0]  tmp_buffer_Addr;
    wire [(DataWidth-1):0] tmp_buffer_Data;

    reg [9:0] tmp_Inmem_Address;
    reg [(DataWidth-1):0] Data1, Data2, Data3, Data4;
    reg done_input_cmd;
    wire [(DataWidth*4-1):0] data_to_inmem;

    // Declare IP
    PE #(   .DataWidth(DataWidth),
            .TotalNumBank(TotalNumBank),
            .AddrWidth(AddrWidth)
        ) shader_IP (
        .clk(iClk), 
        .rstn(iShader_rst_n),
        .instr_in(instr),
        .data_out(data_out),
        .ready_out(ready_out),
        .instr_addr_out(instr_addr_out)
    ); 

    buffer #(.DataWidth(DataWidth)) output_data_buffer (
        .clk(iClk), 
        .rstn(iReset_n),
        .shader_rstn(iShader_rst_n),
        .writeEn((&ready_out)),
        .writeData(data_out),
        .readEn(~iRead_n),
        .readAddr(tmp_buffer_Addr),
        .readData(tmp_buffer_Data)
    );

    instr_rom #(.DataWidth(DataWidth)) instr_rom_block (
        .clk(iClk), 
        .rstn(iReset_n),
        .writeAddr(tmp_Inmem_Address),
        .writeData(data_to_inmem),
        .writeEn(done_input_cmd),
        .pc(instr_addr_out),
        .instr(instr)
    );
    
    // Write interface
    always @(posedge iClk, negedge iReset_n) begin
        if (~iReset_n) begin
            tmp_Inmem_Address <= 0;
            Data1 <= 0;
            Data2 <= 0;
            Data3 <= 0;
            Data4 <= 0;
            done_input_cmd <= 0;
        end
        else begin
            if (~iChipSelect_n & ~iWrite_n) begin
                case (iAddress)
                32'd0: tmp_Inmem_Address <= iData[9:0];
                32'd1: Data1             <= iData;
                32'd2: Data2             <= iData;
                32'd3: Data3             <= iData;
                32'd4: Data4             <= iData;
                32'd5: done_input_cmd    <= iData[0];
                default: begin
                    tmp_Inmem_Address <= 0;
                    Data1 <= 0;
                    Data2 <= 0;
                    Data3 <= 0;
                    Data4 <= 0;
                    done_input_cmd <= 0;
                end
                endcase
            end
            else begin
                done_input_cmd <= 1'b0;
            end
        end
    end

    assign data_to_inmem = {Data4, Data3, Data2, Data1};

    // Read interface
    always @(posedge iClk, negedge iReset_n) begin  
        if (~iReset_n) begin
            tmp_buffer_Addr = 0;
        end
        else begin
            if (~iChipSelect_n & ~iRead_n) begin
               tmp_buffer_Addr = iAddress[9:0];
            end
        end
    end

    assign oData = (~iReset_n) ? 32'd0 : ((~iRead_n) ? tmp_buffer_Data : 32'bz);

endmodule
`endif