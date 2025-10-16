`default_nettype none
`include "aes_parameters.svh"

module aes_encryption_top #(
  parameter int KEY_WIDTH    = 256,
  parameter int TDATA_WIDTH  = 128,
  parameter int ROUND_NUMBER = 14
)(
  input  wire clk,
  input  wire resetn,

  // Key expansion interface
  input  wire [KEY_WIDTH-1:0] aes_key_i,
  input  wire                 aes_key_valid_i,

  // AES stream interface
  input  wire [TDATA_WIDTH-1:0] aes_in_tdata,
  input  wire                   aes_in_tvalid,
  input  wire                   aes_in_tlast,
  output wire                   aes_in_tready,

  output logic [TDATA_WIDTH-1:0] aes_out_tdata,
  output logic                   aes_out_tvalid,
  output logic                   aes_out_tlast,
  input  wire                    aes_out_tready
);

round_keys_t round_keys;
wire         round_keys_valid;

key_expansion key_generator(
  .clk(clk),
  .resetn(resetn),
  .aes_key_i(aes_key_i),
  .aes_key_valid_i(aes_key_valid_i),
  .round_keys_o(round_keys),
  .round_keys_valid_o(round_keys_valid)
);

aes_encryption #(
  .ROUND_NUMBER(ROUND_NUMBER),
  .TDATA_WIDTH(TDATA_WIDTH)
) encryption(
  .clk(clk),
  .resetn(resetn),
  .aes_in_tdata(aes_in_tdata),
  .aes_in_tvalid(aes_in_tvalid),
  .aes_in_tlast(aes_in_tlast),
  .aes_in_tready(aes_in_tready),

  .round_keys(round_keys),
  .round_keys_valid(round_keys_valid),

  .aes_out_tdata(aes_out_tdata),
  .aes_out_tvalid(aes_out_tvalid),
  .aes_out_tlast(aes_out_tlast),
  .aes_out_tready(aes_out_tready)
);

endmodule

`default_nettype wire