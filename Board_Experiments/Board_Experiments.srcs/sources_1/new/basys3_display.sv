`timescale 1ns / 1ps

module basys3_display(
    input  wire             i_clk_100MHz,
    input  wire             i_rst_100MHz,
    input  wire  [3:0][3:0] i_val,
    input  wire  [3:0]      i_dp,
    output logic [6:0]      o_seg,
    output logic            o_dp,
    output logic [3:0]      o_an
    );

    logic [3:0][6:0]    seg;
    logic [18:0] pd_counter;

    // anode shift 
    always_ff @(posedge i_clk_100MHz) begin
        if (i_rst_100MHz) begin
            pd_counter <= 19'b0;
            o_an         <= 4'b1111;
        end else begin
            pd_counter    <= pd_counter + 1'b1;
            case(pd_counter[18:17])
                2'b00: begin
                    o_an  <= 4'b1110;
                    o_seg <= seg[0];
                    o_dp  <= ~i_dp[0];
                end
                2'b01: begin
                    o_an  <= 4'b1101;
                    o_seg <= seg[1];
                    o_dp  <= ~i_dp[1];
                end
                2'b10: begin
                    o_an  <= 4'b1011;
                    o_seg <= seg[2];
                    o_dp  <= ~i_dp[2];
                end
                2'b11: begin
                    o_an  <= 4'b0111;
                    o_seg <= seg[3];
                    o_dp  <= ~i_dp[3];
                end
                default: begin
                    o_an <= 4'b1111;
                    o_seg <= seg[0];
                    o_dp  <= ~i_dp[0];
                end
            endcase
        end
    end

    // displays
    genvar i;
    generate
        for (i=0; i < 4; i++) begin
            seven_segment_display sub_display (
                .i_val(i_val[i]),
                .o_seg(seg[i])
            );   
        end
    endgenerate

endmodule
