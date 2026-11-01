`timescale 1ns / 1ps

module tb_encoder;

	logic       clk;
	logic       rst;
	logic       a, b;
	wire[7:0]   count;

	encoder #(.COUNT_WIDTH(8)) 
        uut (
        .i_clk(clk),
        .i_rst(rst),
        .i_a(a),
        .i_b(b),
        .o_count(count));
    
    initial begin
        rst = 1'b1;
        #10 rst = 1'b0;
    end

    initial begin
        clk = 1'b0;
        wait(rst == 1); 
        forever #1 clk = ~clk;
    end

endmodule