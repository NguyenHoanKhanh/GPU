module ex_pipeline_reg #(
    parameter DataWidth  = 32,
    parameter TotalNumBank = 8,
    parameter AddrWidth = 5
) (
    input                       clk, rstn, sclr,
    input                       des_sat_e,
    input [3:0]                 des_mask_e,
    input [(TotalNumBank-1):0]  writeEn_e,
    input [(AddrWidth-1):0]     writeAddr_e,
    input [(DataWidth-1):0]     res0, res1, res2, res3,
    input [4:0]                 flags0, flags1, flags2, flags3,
    `ifdef PE_SoC
        input                   ready0, ready1, ready2, ready3,
    `endif
    input                       pipe_e,
    output                      des_sat_o,
    output [3:0]                des_mask_o,
    output [(TotalNumBank-1):0] writeEn_o,
    output [(AddrWidth-1):0]    writeAddr_o,
    output [(DataWidth-1):0]    res0_o, res1_o, res2_o, res3_o,
    output [4:0]                flags0_o, flags1_o, flags2_o, flags3_o,
    `ifdef PE_SoC
        output                  ready0_o, ready1_o, ready2_o, ready3_o,
    `endif
    output                      pipe_o
);

    `ifndef PE_SoC
        reg [(25+TotalNumBank+AddrWidth+4*DataWidth):0] temp;

        always @(posedge clk, negedge rstn) begin
            if (~rstn) begin
                temp <= {(26+TotalNumBank+AddrWidth+4*DataWidth){1'b0}};
            end
            else if (sclr) begin
                temp <= {(26+TotalNumBank+AddrWidth+4*DataWidth){1'b0}};
            end
            else begin
                temp <= {des_sat_e, des_mask_e, writeEn_e, writeAddr_e, res0, res1, res2, res3, flags0, flags1, flags2, flags3, pipe_e};
            end
        end

        assign {des_sat_o, des_mask_o, writeEn_o, writeAddr_o, res0_o, res1_o, res2_o, res3_o, flags0_o, flags1_o, flags2_o, flags3_o, pipe_o} = temp;
    `else
        reg [(29+TotalNumBank+AddrWidth+4*DataWidth):0] temp;

        always @(posedge clk, negedge rstn) begin
            if (~rstn) begin
                temp <= {(29+TotalNumBank+AddrWidth+4*DataWidth){1'b0}};
            end
            else if (sclr) begin
                temp <= {(29+TotalNumBank+AddrWidth+4*DataWidth){1'b0}};
            end
            else begin
                temp <= {des_sat_e, des_mask_e, writeEn_e, writeAddr_e, res0, res1, res2, res3, flags0, flags1, flags2, flags3, ready0, ready1, ready2, ready3, pipe_e};
            end
        end

        assign {des_sat_o, des_mask_o, writeEn_o, writeAddr_o, res0_o, res1_o, res2_o, res3_o, flags0_o, flags1_o, flags2_o, flags3_o, ready0_o, ready1_o, ready2_o, ready3_o, pipe_o} = temp;
    `endif


endmodule