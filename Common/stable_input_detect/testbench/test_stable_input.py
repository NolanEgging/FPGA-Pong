from __future__ import annotations

import os
import random
from pathlib import Path

import cocotb
import logging
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.triggers import ClockCycles
from cocotb_tools.runner import get_runner

async def create_unstable_input(dut, val):
    #Sets unstable input based on value input
    
    input_val = val

    await RisingEdge(dut.i_clk)

    for _ in range(7):
        dut.i_sig.value = input_val
        await RisingEdge(dut.i_clk)
        output_val = dut.o_sig.value
        if input_val == 1:
            input_val = 0
        else:
            input_val = 1

async def monitor_signals(dut):
    #Monitors test signals and logs them for user
    while True:
        await RisingEdge(dut.i_clk)
        output_val = dut.o_sig.value
        curr_input = dut.i_sig.value
        dut.i_sig._log.info("Input: " + str(curr_input) + "  Output: " + str(output_val))
        dut.tick_timer._log.info(f"Timer Enable: {dut.tick_timer.value}")
        dut.timer._log.info(f"Clocks: {dut.counter.value.to_unsigned()}, Timer: {dut.timer.value.to_unsigned()}\n")



@cocotb.test()
async def stable_input_test(dut):
    """Test"""

    logger = logging.getLogger("test_stable_input")

    # Set initial input value to prevent it from floating
    curr_input = 0
    dut.i_sig.value = curr_input

    # Start in reset
    dut.i_rst.value = 1

    # Create a 10us period clock driver on port `clk`
    clock = Clock(dut.i_clk, 10, unit="us")
    # Start the clock. Start it low to avoid issues on the first RisingEdge
    clock.start(start_high=False)

    # Synchronize with the clock. This will register the initial `d` value
    await RisingEdge(dut.i_clk)

    expected_val = 0  # Matches initial input value
    await RisingEdge(dut.i_clk)

    dut.i_rst.value = 0
    
    await RisingEdge(dut.i_clk)

    sig_mon = cocotb.start_soon(monitor_signals(dut))
    
    input_to_set = 1
    await create_unstable_input(dut, input_to_set)

    while(dut.tick_timer.value == 1):
        await RisingEdge(dut.i_clk)

    output_val = dut.o_sig.value
    assert output_val == input_to_set

    input_to_set = 0
    await create_unstable_input(dut, input_to_set)

    while(dut.tick_timer.value == 1):
        await RisingEdge(dut.i_clk)

    output_val = dut.o_sig.value
    assert output_val == input_to_set

    await ClockCycles(dut.i_clk, 2)

    sig_mon.cancel()


def test_stable_input_runner():
    sim = os.getenv("SIM", "verilator")

    proj_path = Path(__file__).resolve().parent

    sources = [proj_path / "test_stable_input.sv"]

    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="stable_input_detect",
        always=True,
    )

    runner.test(hdl_toplevel="stable_input_detect", test_module="stable_input_test")


if __name__ == "__main__":
    test_stable_input_runner()
