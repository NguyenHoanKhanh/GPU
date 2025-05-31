module buffer #(
    parameter DataWidth = 32
) (
    input                       clk, rstn, shader_rstn,
    input                       writeEn,
    input [(DataWidth*4)-1:0]   writeData,
    input                       readEn,
    input [9:0]                 readAddr,
    output [DataWidth-1:0]      readData
);

    (* ram_style = "block" *) reg [(DataWidth-1):0] data_buffer [0:(1024*4)]; 
    integer i; 
    reg [31:0] addr_counter;

    always @(posedge clk, negedge rstn, negedge shader_rstn) begin
        if (~rstn) begin
            for (i = 0; i < (1024*4); i = i + 1) begin
                data_buffer[i] <= {DataWidth{1'b0}};
            end
        end
        else if (~shader_rstn) begin
            addr_counter <= 32'b0;
        end
        else if (writeEn) begin
            data_buffer[addr_counter+3'd0] <=  writeData[31:0];
            data_buffer[addr_counter+3'd1] <=  writeData[63:32];
            data_buffer[addr_counter+3'd2] <=  writeData[95:64];
            data_buffer[addr_counter+3'd3] <=  writeData[127:96];
            addr_counter <= addr_counter + 3'd4;
        end
    end

    assign readData = (~rstn) ? {DataWidth{1'b0}} : ((readEn) ? data_buffer[readAddr] : {DataWidth{1'bz}});

endmodule