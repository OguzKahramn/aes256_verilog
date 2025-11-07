// SPDX-FileCopyrightText: 2025 Oguz Kahraman
//
// SPDX-License-Identifier: MIT

`include "aes_parameters.svh"
module tb_key_expansion();


logic clk;
logic resetn;
logic[255:0] aes_key;
logic aes_key_valid;

round_keys_t round_keys;
logic round_key_valid;

round_keys_t ic_round_keys;
logic ic_round_key_valid;

key_expansion UUT(
  .clk(clk),
  .resetn(resetn),

  .aes_key_i(aes_key),
  .aes_key_valid_i(aes_key_valid),

  .round_keys_o(round_keys),
  .round_keys_valid_o(round_key_valid)
);


key_expansion #(
  .KEY_WIDTH(256),
  .ENCRYPTION(0),
  .MAX_ROUND_NUM(14))
  UUT_IC(
  .clk(clk),
  .resetn(resetn),

  .aes_key_i(aes_key),
  .aes_key_valid_i(aes_key_valid),

  .round_keys_o(ic_round_keys),
  .round_keys_valid_o(ic_round_key_valid)
);


always #5 clk = ~ clk;

initial begin
  clk = 0;
  resetn = 0;
  aes_key_valid =0;
  #100;
  resetn= 1;
  #100
  aes_key = 'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f;
  aes_key_valid = 1'b1;
  #100
  aes_key_valid = 1'b0;
  #2005;
  aes_key = 'h603DEB1015CA71BE2B73AEF0857D77811F352C073B6108D72D9810A30914DFF4;
  aes_key_valid = 1'b1;
end

endmodule