/*
stable_input_detect.sv

Purpose:    Filters out noise and jitter from an input
            and sets a stable output
Date:       Oct 17 2026

Signals:
    Generics:
        CLKS_PER_MS -  Number of input clocks per ms
        STABLE_TIMEOUT_MS - How long in ms to determine input stable
        TIMEOUT_METHOD - PRE or POST, holds timeout before setting output or after

    Inputs:
        i_clk - system clock
        i_sig - signal to filter

    Outputs:
        o_sig - stable output
*/

module stable_input_detect #(
    parameter        CLKS_PER_MS       = 5, // 100000, //Default 100MHz
    parameter        STABLE_TIMEOUT_MS = 1, // 10,    // Min 0, Max 15
    parameter string TIMEOUT_METHOD    = "POST"   //PRE or POST
) (
    input  wire  i_rst,
    input  wire  i_clk,
    input  wire  i_sig,
    output logic o_sig
);

    logic       sig_dly;
    logic       sig_out;
    logic       tick_timer;
    logic[3:0]  timer;
    logic[17:0] counter;

    // Shared - 
    // Delay input signal for edge detection
    always_ff @(posedge i_clk) begin
        sig_dly <= i_sig;
    end

    // Timer-
    always_ff @(posedge i_clk or posedge i_rst) begin
        if(i_rst) begin
            timer   <= '0;
            counter <= '0;
        end else if (tick_timer) begin
            if (timer == STABLE_TIMEOUT_MS) begin
                timer   <= '0;
                counter <= '0;
            end else if (counter == CLKS_PER_MS) begin
                timer   <= timer + 1'b1;
                counter <= '0;
            end else begin
                timer   <= timer;
                counter <= counter + 1'b1;
            end
        end else begin
            timer   <= '0;
            counter <= '0;
        end
    end

    always_ff @(posedge i_clk or posedge i_rst) begin
        if(i_rst) begin
            tick_timer <= 1'b0;
            sig_out    <= 1'b0;
        end else begin
            if (TIMEOUT_METHOD == "PRE") begin
                // PRE - Wait for stable input before setting output

                if(timer == STABLE_TIMEOUT_MS) begin
                    tick_timer <= 1'b0;
                    sig_out    <= i_sig;
                end else if (tick_timer == 1'b1) begin
                    tick_timer <= 1'b1;
                    sig_out    <= sig_out;
                end else if (sig_dly != i_sig) begin
                    tick_timer <= 1'b1;
                    sig_out    <= sig_out;
                end else begin
                    tick_timer <= 1'b0;
                    sig_out    <= sig_out;
                end
            end else if (TIMEOUT_METHOD == "POST") begin
                // POST - Set output and then wait before checking for the next edge

                if(timer == STABLE_TIMEOUT_MS) begin
                    tick_timer <= 1'b0;
                    sig_out    <= sig_out;
                end else if (tick_timer == 1'b1) begin
                    tick_timer <= 1'b1;
                    sig_out    <= sig_out;
                end else if (sig_dly != i_sig) begin
                    tick_timer <= 1'b1;
                    sig_out    <= i_sig;
                end else begin
                    tick_timer <= 1'b0;
                    sig_out    <= sig_out;
                end
            end
        end
    end

    assign o_sig = sig_out;


endmodule