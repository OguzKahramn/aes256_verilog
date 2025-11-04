
`include "aes_parameters.svh"
module tb_aes_inv_chiper();


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
logic aes_out_tready;

key_expansion UUT(
  .clk(clk),
  .resetn(resetn),

  .aes_key_i(aes_key),
  .aes_key_valid_i(aes_key_valid),

  .round_keys_o(round_keys),
  .round_keys_valid_o(round_key_valid)
);

aes_inv_chiper #(
  .ROUND_NUMBER(14),
  .TDATA_WIDTH(128)
) UUT_inv_chiper(
  .clk(clk),
  .resetn(resetn),
  .aes_in_tdata(aes_in_tdata),
  .aes_in_tvalid(aes_in_tvalid),
  .aes_in_tlast(aes_in_tlast),
  .aes_in_tready(aes_in_tready),

  .round_keys(round_keys),
  .round_keys_valid(round_key_valid),

  .aes_out_tdata(aes_out_tdata),
  .aes_out_tvalid(aes_out_tvalid),
  .aes_out_tlast(aes_out_tlast),
  .aes_out_tready(aes_out_tready)
);

always #5 clk = ~ clk;

initial begin
  clk = 0;
  resetn = 0;
  aes_key_valid =0;
  aes_in_tdata = 0;
  aes_in_tvalid = 0;
  aes_in_tlast  = 0;
  aes_out_tready = 1;
  #100;
  resetn= 1;
  #100;
  aes_key = 'h603DEB1015CA71BE2B73AEF0857D77811F352C073B6108D72D9810A30914DFF4;
  aes_key_valid = 1'b1;
  #2005;
  aes_in_tdata = 'hF3EED1BDB5D2A03C064B5A7E3DB181F8;
  aes_in_tvalid = 1;
  aes_out_tready = 0;
  #10;
  aes_in_tdata = 'h591CCB10D410ED26DC5BA74A31362870;
    aes_in_tvalid = 1;
  aes_out_tready = 1;
  #10;
  aes_in_tdata = 'hB6ED21B99CA6F4F9F153E7B1BEAFED1D;
  aes_in_tvalid = 0;
  #10;
  aes_in_tdata = 'h23304B7A39F9F3FF067D8D8F9E24ECC7;
  aes_in_tvalid = 1;
  aes_in_tlast = 'h1;
  #10;
  aes_in_tlast = 'h0;
  aes_in_tvalid = 'h0;

end

endmodule