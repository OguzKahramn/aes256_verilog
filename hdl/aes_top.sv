
`include "aes_parameters.svh"

module aes_top(
  input wire clk_in1
);


wire clk_out1;
wire locked;
round_keys_t round_keys;
wire round_key_valid;
round_keys_t ic_round_keys;
wire ic_round_key_valid;
wire [255:0] aes_key;
wire aes_key_valid;

wire aes_in_tready;
wire aes_in_tvalid;
wire aes_in_tlast;
wire [127:0] aes_in_tdata;
wire [127:0] aes_out_tdata;
wire aes_out_tvalid;
wire aes_out_tlast;
wire aes_out_tready;

wire [127:0] inv_aes_out_tdata;
wire inv_aes_out_tvalid;
wire inv_aes_out_tlast;

wire core_ext_start;
wire core_ext_stop;


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

ila_0 ila (
	.clk(clk_out1), // input wire clk
	.probe0(round_keys[0]), // input wire [127:0]  probe0  
	.probe1(round_keys[1]), // input wire [127:0]  probe1 
	.probe2(round_keys[2]), // input wire [127:0]  probe2 
	.probe3(round_keys[3]), // input wire [127:0]  probe3 
	.probe4(round_keys[4]), // input wire [127:0]  probe4 
	.probe5(round_keys[5]), // input wire [127:0]  probe5 
	.probe6(round_keys[6]), // input wire [127:0]  probe6 
	.probe7(round_keys[7]), // input wire [127:0]  probe7 
	.probe8(round_keys[8]), // input wire [127:0]  probe8 
	.probe9(round_keys[9]), // input wire [127:0]  probe9 
	.probe10(round_keys[10]), // input wire [127:0]  probe10 
	.probe11(round_keys[11]), // input wire [127:0]  probe11 
	.probe12(round_keys[12]), // input wire [127:0]  probe12 
	.probe13(round_keys[13]), // input wire [127:0]  probe13 
	.probe14(round_keys[14]), // input wire [0:0]  probe14
  .probe15(round_key_valid)
);

axi_traffic_gen_0 axis_traffic_gen (
    .s_axi_aclk(clk_out1),
    .s_axi_aresetn(locked),
    .core_ext_start(core_ext_start),
    .core_ext_stop(core_ext_stop),
    
    // Tie unused AXI-Lite slave ports
    .s_axi_awid(0),
    .s_axi_awaddr(0),
    .s_axi_awlen(0),
    .s_axi_awsize(0),
    .s_axi_awburst(0),
    .s_axi_awlock(0),
    .s_axi_awcache(0),
    .s_axi_awprot(0),
    .s_axi_awqos(0),
    .s_axi_awuser(0),
    .s_axi_awvalid(0),
    .s_axi_wlast(0),
    .s_axi_wdata(0),
    .s_axi_wstrb(0),
    .s_axi_wvalid(0),
    .s_axi_bready(0),
    .s_axi_arid(0),
    .s_axi_araddr(0),
    .s_axi_arlen(0),
    .s_axi_arsize(0),
    .s_axi_arburst(0),
    .s_axi_arlock(0),
    .s_axi_arcache(0),
    .s_axi_arprot(0),
    .s_axi_arqos(0),
    .s_axi_aruser(0),
    .s_axi_arvalid(0),
    .s_axi_rready(0),

    // AXI-Stream master interface (your AES input)
    .m_axis_1_tready(aes_in_tready),
    .m_axis_1_tvalid(aes_in_tvalid),
    .m_axis_1_tlast(aes_in_tlast),
    .m_axis_1_tdata(aes_in_tdata),
    .m_axis_1_tstrb(),
    .m_axis_1_tkeep(),
    .m_axis_1_tuser(),
    .m_axis_1_tid(),
    .m_axis_1_tdest(),
    .err_out()
);

aes_encryption #(
  .ROUND_NUMBER(14),
  .TDATA_WIDTH(128)
) encryption(
  .clk(clk_out1),
  .resetn(locked),
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
) inverse_encryption(
  .clk(clk_out1),
  .resetn(locked),
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

aes_ila_1 aes_ila (
	.clk(clk_out1), // input wire clk
	.probe0(aes_out_tdata), // input wire [127:0]  probe0  
	.probe1(aes_out_tvalid), // input wire [0:0]  probe1 
	.probe2(aes_out_tlast), // input wire [0:0]  probe2 
	.probe3(aes_in_tdata), // input wire [127:0]  probe3 
	.probe4(aes_in_tvalid), // input wire [0:0]  probe4 
	.probe5(aes_in_tlast), // input wire [0:0]  probe5 
	.probe6(aes_in_tready), // input wire [0:0]  probe6
	.probe7(inv_aes_out_tdata), // input wire [127:0]  probe7 
	.probe8(inv_aes_out_tvalid), // input wire [0:0]  probe8 
	.probe9(inv_aes_out_tlast) // input wire [0:0]  probe9
);
vio_0 vio (
  .clk(clk_out1),                // input wire clk
  .probe_out0(aes_key),  // output wire [255 : 0] probe_out0
  .probe_out1(aes_key_valid),  // output wire [0 : 0] probe_out1
  .probe_out2(core_ext_start),
  .probe_out3(core_ext_stop)
);
endmodule