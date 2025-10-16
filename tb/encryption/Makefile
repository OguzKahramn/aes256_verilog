include ../common.mk

# VERILOG source code
VERILOG_SOURCES += $(HDL_LIB)/aes_encryption_top.sv
VERILOG_SOURCES += $(HDL_LIB)/key_expansion.sv
VERILOG_SOURCES += $(HDL_LIB)/aes_encryption.sv
VERILOG_SOURCES += $(HDL_LIB)/encryption_aes_round.sv

# COCOTB_TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
COCOTB_TOPLEVEL = aes_encryption_top

# COCOTB_TEST_MODULES is the basename of the Python test file(s)
COCOTB_TEST_MODULES = test_encryption

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim