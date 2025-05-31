module hazard_unit #(
    parameter DataWidth  = 32,
    parameter TotalNumBank = 8,
    parameter AddrWidth = 5
) (
    input [(TotalNumBank-1):0]  readEn1_e, readEn2_e, readEn3_e,
    input [(AddrWidth-1):0]     readAddr1_e, readAddr2_e, readAddr3_e,
    input [(TotalNumBank-1):0]  writeEn_w,
    input [(AddrWidth-1):0]     writeAddr_w,
    input [(TotalNumBank-1):0]  writeEn_e,
    input [(AddrWidth-1):0]     writeAddr_e,
    input [(TotalNumBank-1):0]  writeEn_e_1,
    input [(AddrWidth-1):0]     writeAddr_e_1,
    input [(TotalNumBank-1):0]  writeEn_e_2,
    input [(AddrWidth-1):0]     writeAddr_e_2,
    input [(TotalNumBank-1):0]  readEn1_r, readEn2_r, readEn3_r,
    input [(AddrWidth-1):0]     readAddr1_r, readAddr2_r, readAddr3_r,

    output                      stall_f, stall_d, stall_r,
    output                      flush_e, flush_e_1, flush_e_2,
    output reg                  fwd1, fwd2, fwd3
);

    reg load_hazard_1, load_hazard_2, load_hazard_3;
    
    // Forwarding
    always @(*) begin
        if ((readAddr1_e != 5'd0) & (readEn1_e != 8'd1) & (readEn1_e != 8'd2) & (readEn1_e != 8'd4) & (readEn1_e != 8'd8)) begin
            if ((readAddr1_e == writeAddr_w) & (readEn1_e == writeEn_w) & (writeEn_w != 8'd0)) begin
                fwd1 = 1'b1;
            end 
            else begin
                fwd1 = 1'b0;
            end
        end
        else begin
            fwd1 = 1'b0;
        end
        
        if ((readAddr2_e != 5'd0) & (readEn2_e != 8'd1) & (readEn2_e != 8'd2) & (readEn2_e != 8'd4) & (readEn2_e != 8'd8)) begin
            if ((readAddr2_e == writeAddr_w) & (readEn2_e == writeEn_w) & (writeEn_w != 8'd0)) begin
                fwd2 = 1'b1;
            end 
            else begin
                fwd2 = 1'b0;
            end
        end
        else begin
            fwd2 = 1'b0;
        end

        if ((readAddr3_e != 5'd0) & (readEn3_e != 8'd1) & (readEn3_e != 8'd2) & (readEn3_e != 8'd4) & (readEn3_e != 8'd8)) begin
            if ((readAddr3_e == writeAddr_w) & (readEn3_e == writeEn_w) & (writeEn_w != 8'd0)) begin
                fwd3 = 1'b1;
            end 
            else begin
                fwd3 = 1'b0;
            end
        end
        else begin
            fwd3 = 1'b0;
        end
    end

    // Stalling
    always @(*) begin
        if (((readAddr1_r != 5'd0) & (readEn1_r != 8'd1) & (readEn1_r != 8'd2) & (readEn1_r != 8'd4) & (readEn1_r != 8'd8)) | ((readAddr2_r != 5'd0) & (readEn2_r != 8'd1) & (readEn2_r != 8'd2) & (readEn2_r != 8'd4) & (readEn2_r != 8'd8)) | ((readAddr3_r != 5'd0) & (readEn3_r != 8'd1) & (readEn3_r != 8'd2) & (readEn3_r != 8'd4) & (readEn3_r != 8'd8))) begin
            if ((((readAddr1_r == writeAddr_e) & (readEn1_r == writeEn_e)) | ((readAddr2_r == writeAddr_e) & (readEn2_r == writeEn_e)) | ((readAddr3_r == writeAddr_e) & (readEn3_r == writeEn_e))) & (writeEn_e != 8'd0)) begin
                load_hazard_1 = 1'b1;
            end 
            else begin
                load_hazard_1 = 1'b0;
            end   

            if ((((readAddr1_r == writeAddr_e_1) & (readEn1_r == writeEn_e_1)) | ((readAddr2_r == writeAddr_e_1) & (readEn2_r == writeEn_e_1)) | ((readAddr3_r == writeAddr_e_1) & (readEn3_r == writeEn_e_1))) & (writeEn_e_1 != 8'd0)) begin
                load_hazard_2 = 1'b1;
            end
            else begin
                load_hazard_2 = 1'b0;
            end

            if ((((readAddr1_r == writeAddr_e_2) & (readEn1_r == writeEn_e_2)) | ((readAddr2_r == writeAddr_e_2) & (readEn2_r == writeEn_e_2)) | ((readAddr3_r == writeAddr_e_2) & (readEn3_r == writeEn_e_2))) & (writeEn_e_2 != 8'd0)) begin
                load_hazard_3 = 1'b1;
            end
            else begin
                load_hazard_3 = 1'b0;
            end

        end
        else begin
            load_hazard_1 = 1'b0;
            load_hazard_2 = 1'b0;
            load_hazard_3 = 1'b0;
        end
    end

    assign stall_f = load_hazard_1 | load_hazard_2 | load_hazard_3;
    assign stall_d = load_hazard_1 | load_hazard_2 | load_hazard_3;
    assign stall_r = load_hazard_1 | load_hazard_2 | load_hazard_3;
    assign flush_e = load_hazard_1;
    assign flush_e_1 = load_hazard_2;
    assign flush_e_2 = load_hazard_3;

endmodule