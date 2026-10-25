`timescale 1ns / 1ps

module encode 
#(
    parameter COUNT_WIDTH = 8
)(
    input  wire                     i_clk,
    input  wire                     i_rst,
    input  wire                     i_a,
    input  wire                     i_b,
    output logic[COUNT_WIDTH-1:0]   o_count,
);

    typedef enum {IDLE_11, CW_01, CW_00, CW_10, CC_10, CC_00, CC_01} state_t;
    state_t state;

    always_ff @(posedge i_clk, posedge i_rst) begin

        if (i_rst) begin
            state   <= IDLE_11;
            o_count <= ((2**COUNT_WIDTH) / 2) - 1;

        end else begin

            // default
            state   <= state;
            o_count <= o_count;

            case(state) 

                // IDLE (stable position)
                IDLE_11 : begin
                    if (~i_a & i_b):    state <= CW_01;
                    if (i_a & ~i_b):    state <= CC_10;
                end

                // clockwise
                CW_01   : begin
                    if (i_a & i_b):     state <= IDLE_11;
                    if (~i_a & ~i_b):   state <= CW_00;
                end
                CW_00   : begin
                    if (i_a & i_b):     state <= IDLE_11;
                    if (~i_a & i_b):    state <= CW_01; 
                    if (i_a & ~i_b):    state <= CW_10; 
                end
                CW_10   : begin
                    if (i_a & i_b): begin
                        o_count <= o_count + 1;
                        state   <= IDLE_11;
                    end
                    if (~i_a & ~i_b):   state <= CW_00;
                end

                // counter clockwise
                CC_10   : begin
                    if (i_a & i_b):     state <= IDLE_11;
                    if (~i_a & ~i_b):   state <= CC_00;
                end
                CC_00   : begin
                    if (i_a & i_b):     state <= IDLE_11;
                    if (i_a & ~i_b):    state <= CC_10; 
                    if (~i_a & i_b):    state <= CC_01; 
                end
                CC_01   : begin
                    if (i_a & i_b): begin
                        o_count <= o_count - 1;
                        state   <= IDLE_11;
                    end
                    if (~i_a & ~i_b):   state <= CC_00;
                end

                // default
                default : begin
                    state <= IDLE_11;
                end

            endcase

        end // end posedge i_clk

    end // end always_ff


endmodule