`ifndef PE_SoC
module instr_rom (
    input [9:0] pc,
    output [127:0] instr
);

    (* ram_style = "block" *) reg [127:0] mem [0:1024];

    assign instr = mem[pc];

endmodule
`else
module instr_rom #(
    parameter DataWidth = 32
) 
(
    input                       clk, rstn,
    input [9:0]                 writeAddr,
    input [(DataWidth*4)-1:0]   writeData,
    input                       writeEn,
    input [9:0]                 pc,
    output [127:0]              instr
);

    (* ram_style = "block" *) reg [(DataWidth*4-1):0] mem [0:1024];
    integer i;

    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            for (i = 0; i < 1024; i = i + 1) begin
                mem[i] <= 128'd0;
            end
        end    
        else if (writeEn) begin
            mem[writeAddr] <= writeData;
        end
    end

    assign instr = mem[pc];

endmodule
`endif