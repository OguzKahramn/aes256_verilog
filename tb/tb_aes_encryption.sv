
`include "aes_parameters.svh"
module tb_aes_encryption();


logic clk;
logic resetn;
logic[255:0] aes_key;
logic aes_key_valid;

round_keys_t round_keys;
logic round_key_valid;

logic [127:0] aes_in_tdata;
logic aes_in_tvalid;
logic aes_in_tlast;
logic aes_in_tready;

logic [127:0] aes_out_tdata;
logic aes_out_tvalid;
logic aes_out_tlast;

key_expansion UUT(
  .clk(clk),
  .resetn(resetn),

  .aes_key_i(aes_key),
  .aes_key_valid_i(aes_key_valid),

  .round_keys_o(round_keys),
  .round_keys_valid_o(round_key_valid)
);

aes_encryption #(
  .ROUND_NUMBER(14),
  .TDATA_WIDTH(128)
) UUT_enc(
  .clk(clk),
  .resetn(resetn),
  .aes_in_tdata(aes_in_tdata),
  .aes_in_tvalid(aes_in_tvalid),
  .aes_in_tlast(aes_in_tvalid),
  .aes_in_tready(aes_in_tready),

  .round_keys(round_keys),
  .round_keys_valid(round_key_valid),

  .aes_out_tdata(aes_out_tdata),
  .aes_out_tvalid(aes_out_tvalid),
  .aes_out_tlast(aes_out_tlast),
  .aes_out_tready('d1)
);

always #5 clk = ~ clk;

initial begin
  clk = 0;
  resetn = 0;
  aes_key_valid =0;
  aes_in_tdata = 0;
  aes_in_tvalid = 0;
  aes_in_tlast  = 0;
  #100;
  resetn= 1;
  #100;
  aes_key = 'h603DEB1015CA71BE2B73AEF0857D77811F352C073B6108D72D9810A30914DFF4;
  aes_key_valid = 1'b1;
  #1005;
  aes_in_tdata = 'h6BC1BEE22E409F96E93D7E117393172A;
  aes_in_tvalid = 1;
  #10;
  aes_in_tdata = 'hAE2D8A571E03AC9C9EB76FAC45AF8E51;
  #10;
  aes_in_tdata = 'h30C81C46A35CE411E5FBC1191A0A52EF;
  #10;
  aes_in_tdata = 'hF69F2445DF4F9B17AD2B417BE66C3710;
  aes_in_tlast = 'h1;
  #10;
  aes_in_tlast = 'h0;
  aes_in_tvalid = 'h0;

end

endmodule