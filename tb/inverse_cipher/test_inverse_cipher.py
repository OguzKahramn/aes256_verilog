import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, with_timeout
from cocotbext.axi import AxiStreamBus, AxiStreamFrame, AxiStreamSink, AxiStreamSource
from Crypto.Cipher import AES
import random

KEY_SIZE = 32
MIN_FRAME_LEN = 6
MAX_FRAME_LEN = 100
MIN_FRAME_NUM = 100
MAX_FRAME_NUM = 240
TIMEOUT_NS = 200_000
NUM_TESTS = 10

def create_payload() -> bytes:
  blocks = [random.getrandbits(128) for _ in range(random.randint(MIN_FRAME_LEN, MAX_FRAME_LEN))]
  return b"".join(w.to_bytes(16, byteorder="big") for w in blocks)

async def reset_dut(dut):
  dut.resetn.value = 0
  dut.aes_key_valid_i.value = 0
  for _ in range(10):
    await RisingEdge(dut.clk)
  dut.resetn.value = 1
  await RisingEdge(dut.clk)

async def load_key(dut, key: bytes):
  dut.aes_key_i.value = int(key.hex(), 16)
  dut.aes_key_valid_i.value = 1
  await RisingEdge(dut.clk)
  await with_timeout(RisingEdge(dut.aes_in_tready), TIMEOUT_NS, "ns")
  await RisingEdge(dut.clk)
  cocotb.log.info(f"Key loaded: {key.hex().upper()}")

@cocotb.test()
async def test_fips_vector(dut):
  cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
  axis_source = AxiStreamSource(AxiStreamBus.from_prefix(dut, "aes_in"),
                                dut.clk, dut.resetn, reset_active_level=0)
  axis_sink   = AxiStreamSink(AxiStreamBus.from_prefix(dut, "aes_out"),
                              dut.clk, dut.resetn, reset_active_level=0)
  await reset_dut(dut)

  key = bytes.fromhex("603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4")
  encrypted_text = bytes.fromhex("f3eed1bdb5d2a03c064b5a7e3db181f8")
  expected = bytes.fromhex("6bc1bee22e409f96e93d7e117393172a")

  await load_key(dut, key)

  await axis_source.send(AxiStreamFrame(encrypted_text))
  rx_frame = await with_timeout(axis_sink.recv(), TIMEOUT_NS, "ns")
  rx_bytes = bytes(rx_frame.tdata)

  assert rx_bytes == expected, f"FIPS MISMATCH\n  Expected: {expected.hex().upper()}\n \
                Got: {rx_bytes.hex().upper()}"
  cocotb.log.info("FIPS vector PASS ")
  dut.aes_key_valid_i.value = 0

@cocotb.test()
@cocotb.parametrize(test_num=list(range(NUM_TESTS)))
async def test_inverse_cipher(dut, test_num):
  cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

  axis_source = AxiStreamSource(AxiStreamBus.from_prefix(dut, "aes_in"),
                                dut.clk, dut.resetn, reset_active_level=0)
  axis_sink   = AxiStreamSink(AxiStreamBus.from_prefix(dut, "aes_out"),
                              dut.clk, dut.resetn, reset_active_level=0)

  await reset_dut(dut)

  key = random.randbytes(KEY_SIZE)
  await load_key(dut, key)

  cipher = AES.new(key, AES.MODE_ECB)
    
  transactions = []
  for _ in range(random.randint(MIN_FRAME_NUM, MAX_FRAME_NUM)):
    payload  = create_payload()
    expected = b"".join(cipher.decrypt(payload[j:j+16]) for j in range(0, len(payload), 16))
    transactions.append((payload, expected))
    await axis_source.send(AxiStreamFrame(payload))

  for i, (payload, expected) in enumerate(transactions):
    rx_frame = await with_timeout(axis_sink.recv(), TIMEOUT_NS, "ns")
    rx_bytes  = bytes(rx_frame.tdata)
    assert rx_bytes == expected, (
      f"Frame {i} MISMATCH\n"
      f"  Expected: {expected.hex().upper()}\n"
      f"  Got:      {rx_bytes.hex().upper()}"
    )
    cocotb.log.info(f"Frame {i:03d} OK   ({len(payload)//16} blocks)")