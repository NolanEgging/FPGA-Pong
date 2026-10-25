`timescale 1ns / 1ps

module encoder_readout(
    input   wire    i_clk_100MHz,
    input   wire    i_a,
    input   wire    i_b,
    output  logic   o_a,
    output  logic   o_b
    );

    always_ff @(posedge i_clk_100MHz) begin 
        o_a <= i_a;
        o_b <= i_b;
    end

endmodule