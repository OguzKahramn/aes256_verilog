
`include "aes_parameters.svh"

module aes_top(
  input wire clk_in1
);


wire clk_out1;
wire locked;
round_keys_t round_keys;
wire round_key_valid;
wire [255:0] aes_key;
wire aes_key_valid;

clk_wiz_0 clk_100(
  .clk_out1(clk_out1),
  .locked(locked),
  .clk_in1(clk_in1)
);

key_expansion key_generator(
  .clk(clk_out1),
  .resetn(locked),
  .aes_key_i(aes_key),
  .aes_key_valid_i(aes_key_valid),
  .round_keys_o(round_keys),
  .round_keys_valid_o(round_key_valid)
);

vio_0 vio (
  .clk(clk_out1),                // input wire clk
  .probe_in0(round_keys[0]),    // input wire [127 : 0] probe_in0
  .probe_in1(round_keys[1]),    // input wire [127 : 0] probe_in1
  .probe_in2(round_keys[2]),    // input wire [127 : 0] probe_in2
  .probe_in3(round_keys[3]),    // input wire [127 : 0] probe_in3
  .probe_in4(round_keys[4]),    // input wire [127 : 0] probe_in4
  .probe_in5(round_keys[5]),    // input wire [127 : 0] probe_in5
  .probe_in6(round_keys[6]),    // input wire [127 : 0] probe_in6
  .probe_in7(round_keys[7]),    // input wire [127 : 0] probe_in7
  .probe_in8(round_keys[8]),    // input wire [127 : 0] probe_in8
  .probe_in9(round_keys[9]),    // input wire [127 : 0] probe_in9
  .probe_in10(round_keys[10]),  // input wire [127 : 0] probe_in10
  .probe_in11(round_keys[11]),  // input wire [127 : 0] probe_in11
  .probe_in12(round_keys[12]),  // input wire [127 : 0] probe_in12
  .probe_in13(round_keys[13]),  // input wire [127 : 0] probe_in13
  .probe_in14(round_keys[14]),  // input wire [127 : 0] probe_in14
  .probe_in15(round_key_valid),  // input wire [0 : 0] probe_in15
  .probe_out0(aes_key),  // output wire [255 : 0] probe_out0
  .probe_out1(aes_key_valid)  // output wire [0 : 0] probe_out1
);
endmodule