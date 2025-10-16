include ../common.mk

# VERILOG source code
VERILOG_SOURCES += $(HDL_LIB)/aes_inverse_cipher_top.sv
VERILOG_SOURCES += $(HDL_LIB)/key_expansion.sv
VERILOG_SOURCES += $(HDL_LIB)/aes_inv_cipher.sv

# COCOTB_TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
COCOTB_TOPLEVEL = aes_inverse_cipher_top

# COCOTB_TEST_MODULES is the basename of the Python test file(s)
COCOTB_TEST_MODULES = test_inverse_cipher

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim