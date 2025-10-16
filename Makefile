.PHONY: all sim clean help $(SIM_DIRS)

SIM_DIRS = tb/key_expansion \
					 tb/encryption \
					 tb/inverse_cipher

sim:
ifdef TB
	$(MAKE) -C tb/$(TB)
else
	@for dir in $(SIM_DIRS); do \
		$(MAKE) -C $$dir; \
	done
endif


$(SIM_DIRS):
	$(MAKE) -C $@

clean:
	@for dir in $(SIM_DIRS); do \
		$(MAKE) -C $$dir clean; \
	done
	@find . -name "results.xml" -delete
	@find . -name "*.log" -delete
	@find . -type d -name "sim_build" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -name "dump.vcd" -delete 2>/dev/null || true

help:
	@echo "Available targets:"
	@echo "  make sim                   - run all testbenches"
	@echo "  make sim TB=key_expansion  - run one testbench"
	@echo "  make sim TB=encryption     - run one testbench"
	@echo "  make sim TB=inverse_cipher - run one testbench"
	@echo "  make clean                 - clean everything"