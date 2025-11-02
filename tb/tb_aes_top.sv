
`include "aes_parameters.svh"
module tb_aes_top();


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

logic [127:0] inv_aes_out_tdata;
logic inv_aes_out_tvalid;
logic inv_aes_out_tlast;

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
) uut_encryption(
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

aes_inv_chiper #(
  .ROUND_NUMBER(14),
  .TDATA_WIDTH(128)
) UUT_inv_chiper(
  .clk(clk),
  .resetn(resetn),
  .aes_in_tdata(aes_out_tdata),
  .aes_in_tvalid(aes_out_tvalid),
  .aes_in_tlast(aes_out_tlast),
  .aes_in_tready(aes_out_tready),

  .round_keys(round_keys),
  .round_keys_valid(round_key_valid),

  .aes_out_tdata(inv_aes_out_tdata),
  .aes_out_tvalid(inv_aes_out_tvalid),
  .aes_out_tlast(inv_aes_out_tlast),
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
  wait(round_key_valid);
  #10;
  aes_in_tdata = 'habcdabcdabcdabcdabcdabcdabcdabcd;
  aes_in_tvalid = 1;
  #10;
  aes_in_tdata = 'hd5e6d5e6d5e6d5e6d5e6d5e6d5e6d5e6;
  #10;
  aes_in_tdata = 'heaf3eaf3eaf3eaf3eaf3eaf3eaf3eaf3;
  #10;
  aes_in_tdata = 'hf579f579f579f579f579f579f579f579;
  #10;
  aes_in_tdata = 'h7abc7abc7abc7abc7abc7abc7abc7abc;
  #10;
  aes_in_tdata = 'hbd5ebd5ebd5ebd5ebd5ebd5ebd5ebd5e;
  aes_in_tlast = 'd1;
  #10;
  aes_in_tlast = 'h0;
  aes_in_tvalid = 'h0;
end

endmodule