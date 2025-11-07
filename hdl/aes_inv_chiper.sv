// SPDX-FileCopyrightText: 2025 Oguz Kahraman
//
// SPDX-License-Identifier: MIT

`default_nettype none
`include "aes_parameters.svh"

module aes_inv_chiper #(
  parameter int ROUND_NUMBER = 14,
  parameter int TDATA_WIDTH = 128
)(
  input  wire  clk,
  input  wire  resetn,
  input  wire  [TDATA_WIDTH-1:0] aes_in_tdata,
  input  wire  aes_in_tvalid,
  input  wire  aes_in_tlast,
  output wire  aes_in_tready,

  input  wire round_keys_t round_keys,
  input  wire round_keys_valid,

  output logic [TDATA_WIDTH-1:0] aes_out_tdata,
  output logic aes_out_tvalid,
  output logic aes_out_tlast,
  input  wire  aes_out_tready
);


  wire [TDATA_WIDTH-1:0] stage_data[0:ROUND_NUMBER];
  wire stage_valid[0:ROUND_NUMBER];
  wire stage_last[0:ROUND_NUMBER];
  wire stage_ready[0:ROUND_NUMBER];

  assign stage_data[ROUND_NUMBER]  = aes_in_tdata;
  assign stage_valid[ROUND_NUMBER] = aes_in_tvalid;
  assign stage_last[ROUND_NUMBER]  = aes_in_tlast;
  assign aes_in_tready = round_keys_valid & stage_ready[ROUND_NUMBER];

  assign aes_out_tdata = stage_data[0] ^ round_keys[0];
  assign aes_out_tvalid = stage_valid[0];
  assign aes_out_tlast = stage_last[0];
  assign stage_ready[0] = aes_out_tready;

  genvar i;

  generate
    for(i = 0; i < ROUND_NUMBER; i++) begin : AES_ROUNDS
      inverse_chiper_aes_round #(
        .MIX_COLUMNS_EN(i>=1)
      ) inverse_encryption(
        .clk(clk),
        .resetn(resetn),
        .aes_in_tdata(stage_data[ROUND_NUMBER-i]),
        .aes_in_tvalid(stage_valid[ROUND_NUMBER-i]),
        .aes_in_tlast(stage_last[ROUND_NUMBER-i]),
        .aes_in_tready(stage_ready[ROUND_NUMBER-i]),
        .round_key(round_keys[ROUND_NUMBER-i]),
        .aes_out_tdata(stage_data[ROUND_NUMBER-i-1]),
        .aes_out_tvalid(stage_valid[ROUND_NUMBER-i-1]),
        .aes_out_tlast(stage_last[ROUND_NUMBER-i-1]),
        .aes_out_tready(stage_ready[ROUND_NUMBER-i-1])
      );
    end

  endgenerate

endmodule

`default_nettype wire
