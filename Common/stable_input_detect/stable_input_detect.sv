/*
stable_input_detect.sv

Purpose:    Filters out noise and jitter from an input
            and sets a stable output
Date:       Oct 17 2026

Signals:
    Generics:
        CLKS_PER_MS       -  Number of input clocks per ms
        STABLE_TIMEOUT_MS - How long in ms to determine input stable
        TIMEOUT_METHOD.   - PRE or POST, holds timeout before setting output or after

    Inputs:
        i_clk - system clock
        i_sig - signal to filter

    Outputs:
        o_sig - stable output
*/

module stable_input_detect #(
    parameter        CLKS_PER_MS       = 100000, //Default 100MHz, reduce value for sim
    parameter        STABLE_TIMEOUT_MS = 2,      // Min 0, Max 15
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
    logic[3:0]  timer;      // timer - number of ms passed since event
    logic[17:0] counter;    // counter - number of clocks since last ms

    // Delay input signal for edge detection
    always_ff @(posedge i_clk) begin
        sig_dly <= i_sig;
    end

    // Timer-
    always_ff @(posedge i_clk or posedge i_rst) begin
        if(i_rst) begin
            tick_timer      <= 1'b0;
            timer           <= '0;
            counter         <= '0;
        end else if (tick_timer == 1'b1) begin          
            // Timer is enabled
            if (sig_dly != i_sig) begin
                // Edge detected during timeout, restart counters
                tick_timer  <= 1'b1;
                timer       <= '0;
                counter     <= 18'b1;
            end else if ((timer == STABLE_TIMEOUT_MS-1) && (counter == CLKS_PER_MS-1)) begin
                // End of timeout, reset
                tick_timer  <= 1'b0;
                timer       <= '0;
                counter     <= '0;
            end else if (counter == CLKS_PER_MS-1) begin
                // 1ms passed, increment timer
                tick_timer  <= 1'b1;
                timer       <= timer + 1'b1;
                counter     <= '0;
            end else begin
                // wait for ms, increment counter
                tick_timer  <= 1'b1;
                timer       <= timer;
                counter     <= counter + 1'b1;
            end
        end else if (sig_dly != i_sig) begin
            // First edge detected
            tick_timer      <= 1'b1;
            counter         <= counter + 1'b1;
            timer           <= timer;
        end else begin
            // No edge detected, timer not enabled
            tick_timer      <= 1'b0;
            timer           <= '0;
            counter         <= '0;
        end
    end

    always_ff @(posedge i_clk or posedge i_rst) begin
        if(i_rst) begin
            sig_out    <= 1'b0;
        end else begin
            if (TIMEOUT_METHOD == "PRE") begin
                // PRE - Wait for stable input before setting output
                if ((timer == STABLE_TIMEOUT_MS-1) && (counter == CLKS_PER_MS-1)) begin
                    // Assert output after last count
                    sig_out    <= i_sig;
                end else if (sig_dly != i_sig) begin
                    sig_out    <= sig_out;
                end else begin
                    sig_out    <= sig_out;
                end
            end else if (TIMEOUT_METHOD == "POST") begin
                // POST - Set output and then wait before checking for the next edgeh
                if(tick_timer == 1'b1) begin
                    // Hold output while timer is enabled
                    sig_out    <= sig_out;
                end else if (sig_dly != i_sig) begin
                    // input edge outside of timer
                    sig_out    <= i_sig;      
                end else begin
                    sig_out    <= sig_out;
                end
            end else begin
                // INVALID SELECTION, DO NOT ASSERT OUTPUT
                sig_out     <= 1'b0;
            end
        end
    end

    assign o_sig = sig_out;

endmodule