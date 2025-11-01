
`include "aes_parameters.svh"
module tb_encryption_aes_round();


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

key_expansion UUT(
  .clk(clk),
  .resetn(resetn),

  .aes_key_i(aes_key),
  .aes_key_valid_i(aes_key_valid),

  .round_keys_o(round_keys),
  .round_keys_valid_o(round_key_valid)
);

  wire [127:0] stage_data   [0:14];
  wire         stage_valid  [0:14];
  wire         stage_last   [0:14];
  
  assign stage_data[0]  = aes_in_tdata ^ round_keys[0];
  assign stage_valid[0] = aes_in_tvalid;
  assign stage_last[0]  = aes_in_tlast;
  assign aes_out_tdata = stage_data[14];
  assign aes_out_tvalid = stage_valid[14];
  assign aes_out_tlast = stage_last[14];

genvar i;

generate
  for(i = 0; i < 14; i++) begin : AES_ROUNDS
    encryption_aes_round #(
      .MIX_COLUMNS_EN(i<13)
    ) UUT_round(
      .clk(clk),
      .resetn(resetn),
      .aes_in_tdata(stage_data[i]),
      .aes_in_tvalid(stage_valid[i]),
      .aes_in_tlast(stage_last[i]),
      .aes_in_tready(),
      .round_key(round_keys[i+1]),
      .aes_out_tdata(stage_data[i+1]),
      .aes_out_tvalid(stage_valid[i+1]),
      .aes_out_tlast(stage_last[i+1]),
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