import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
import random
import logging
from round_key_verification import key_expansion

KEY_SIZE = 32
NUM_TESTS = 10

_log_file = "sim_result.log"
open(_log_file, "w").close()

_fh = logging.FileHandler(_log_file, mode="a")
_fh.setLevel(logging.DEBUG)
_fh.setFormatter(logging.Formatter("%(asctime)s %(levelname)-8s %(name)s %(message)s"))

logging.getLogger().addHandler(_fh)

async def reset_dut(dut):
  dut.resetn.value = 0
  for _ in range(10):
    await RisingEdge(dut.clk)
  dut.resetn.value = 1
  await RisingEdge(dut.clk)

async def run_single_test(dut, test_num):
  master_key = random.randbytes(int(KEY_SIZE))

  dut.aes_key_i.value = int(master_key.hex(), 16)
  dut.aes_key_valid_i.value = 1

  await RisingEdge(dut.round_keys_valid_o)

  round_key_fpga = dut.round_keys_o.value.integer
  round_keys_python = key_expansion(master_key)
  cocotb.log.info(f"Master Key: {master_key.hex().upper()}")

  dut.aes_key_valid_i.value = 0
  await RisingEdge(dut.clk)

  for i in range(15):
    shift = i * 128
    rk_int = (round_key_fpga >> shift) & ((1 << 128) - 1)
    rk_fpga = f"{rk_int:032X}"
    rk_python = round_keys_python[i]

    cocotb.log.info(f"Round Key {i+1:02d} Python: {rk_python}")
    cocotb.log.info(f"Round Key {i+1:02d} FPGA:   {rk_fpga}")

    assert rk_fpga == rk_python, (
      f"[Test {test_num}] Round {i} MISMATCH\n"
      f"   Expected:  {rk_python}\n"
      f"   Got     :  {rk_fpga}\n"
    )

  cocotb.log.info(f"[Test {test_num:02d}] All round keys are OK")

@cocotb.test()
@cocotb.parametrize(test_num=list(range(NUM_TESTS)))
async def test_key_expansion(dut, test_num):
  cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
  await reset_dut(dut)
  await run_single_test(dut,test_num)



