
SIM = verilator

VERILOG_SOURCES = $(shell pwd)/../stable_input_detect.sv

COCOTB_TEST_MODULES = test_stable_input
COCOTB_TOPLEVEL = stable_input_detect

include $(shell cocotb-config --makefiles)/Makefile.sim
