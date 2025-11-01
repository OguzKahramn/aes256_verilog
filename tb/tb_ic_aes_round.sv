
`include "aes_parameters.svh"
module tb_ic_aes_round();


logic clk;
logic resetn;
logic[255:0] aes_key;
logic aes_key_valid;

round_keys_t round_keys;
logic round_key_valid;

logic [127:0] aes_in_tdata;
logic aes_in_tvalid;
logic aes_in_tlast;

logic [127:0] aes_out_tdata;
logic aes_out_tvalid;
logic aes_out_tlast;

wire [127:0] stage_data   [0:14];
wire         stage_valid  [0:14];
wire         stage_last   [0:14];

key_expansion #(
  .KEY_WIDTH(256),
  .ENCRYPTION(1),
  .MAX_ROUND_NUM(14))
  UUT(
  .clk(clk),
  .resetn(resetn),

  .aes_key_i(aes_key),
  .aes_key_valid_i(aes_key_valid),

  .round_keys_o(round_keys),
  .round_keys_valid_o(round_key_valid)
);

assign stage_data[14]  = aes_in_tdata;
assign stage_valid[14] = aes_in_tvalid;
assign stage_last[14]  = aes_in_tlast;
assign aes_out_tdata = stage_data[0] ^ round_keys[0];
assign aes_out_tvalid = stage_valid[0];
assign aes_out_tlast = stage_last[0];

genvar i;

generate
  for(i = 0; i < 14; i++) begin : IC_AES_ROUNDS
    inverse_chiper_aes_round #(
      .MIX_COLUMNS_EN(i>=1)
    ) UUT_round(
      .clk(clk),
      .resetn(resetn),
      .aes_in_tdata(stage_data[14-i]),
      .aes_in_tvalid(stage_valid[14-i]),
      .aes_in_tlast(stage_last[14-i]),
      .aes_in_tready(),
      .round_key(round_keys[14-i]),
      .aes_out_tdata(stage_data[14-i-1]),
      .aes_out_tvalid(stage_valid[14-i-1]),
      .aes_out_tlast(stage_last[14-i-1]),
      .aes_out_tready('d1)
    );
  end

endgenerate

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
  #2005;
  aes_in_tdata = 'hF3EED1BDB5D2A03C064B5A7E3DB181F8;
  aes_in_tvalid = 1;
  #10;
  aes_in_tdata = 'h591CCB10D410ED26DC5BA74A31362870;
  #10;
  aes_in_tdata = 'hB6ED21B99CA6F4F9F153E7B1BEAFED1D;
  #10;
  aes_in_tdata = 'h23304B7A39F9F3FF067D8D8F9E24ECC7;
  aes_in_tlast = 'h1;
  #10;
  aes_in_tlast = 'h0;
  aes_in_tvalid = 'h0;

end

endmodule