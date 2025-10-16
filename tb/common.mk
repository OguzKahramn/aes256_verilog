export VERILATOR := /home/oguzk/v-cocotb/bin/verilator

# common.mk
SIM ?= verilator
TOPLEVEL_LANG ?= verilog
HDL_LIB = $(shell pwd)/../../hdl

# Common flags for the simulator
COMPILE_ARGS += -I$(HDL_LIB)
COMPILE_ARGS += -Wno-WIDTHTRUNC -Wno-WIDTHEXPAND

EXTRA_ARGS += --trace

