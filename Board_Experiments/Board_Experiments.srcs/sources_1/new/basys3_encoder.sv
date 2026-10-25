`timescale 1ns / 1ps

module basys3_encoder(
    input   wire                I_CLK_100MHZ,
    input   wire    [7:0]       IO_JC,
    output  wire    [15:0]      O_LED
    );

    encoder_readout readout (
        .i_clk_100MHz(I_CLK_100MHZ),
        .i_a(IO_JC[4]),
        .i_b(IO_JC[5]),
        .o_a(O_LED[0]),
        .o_b(O_LED[1])
    );  

endmodule
