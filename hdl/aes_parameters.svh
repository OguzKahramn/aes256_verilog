
`ifndef _aes_parameters_svh_

`define _aes_parameters_svh_

parameter int AES_COLUMN = 4;
parameter int AES_ROW = 4;

typedef logic [7:0] aes_matrix_t [AES_ROW-1:0][AES_COLUMN-1:0];

localparam aes_matrix_t MIX_COLUMN_MATRIX = '{
  '{8'd2, 8'd3, 8'd1, 8'd1},
  '{8'd1, 8'd2, 8'd3, 8'd1},
  '{8'd1, 8'd1, 8'd2, 8'd3},
  '{8'd3, 8'd1, 8'd1, 8'd2}
};

localparam aes_matrix_t IC_MIX_COLUMN_MATRIX = '{
  '{8'he, 8'hb, 8'hd, 8'h9},
  '{8'h9, 8'he, 8'hb, 8'hd},
  '{8'hd, 8'h9, 8'he, 8'hb},
  '{8'hb, 8'hd, 8'h9, 8'he}
};

typedef logic [14:0][127:0] round_keys_t;
 
logic [31:0] round_constats[10:0] = {'h36000000, 'h1b000000, 'h80000000, 'h40000000, 'h20000000,
                                    'h10000000, 'h08000000, 'h04000000, 'h02000000, 'h01000000,
                                  'h00000000};

function automatic logic [31:0] rotWord(input logic[31:0] word_in);
  rotWord = {word_in[23:0], word_in[31:24]};
endfunction

function automatic logic [31:0] invMixColumns(input logic[31:0] word_in);
  logic [7:0] a0 = word_in[31:24];
  logic [7:0] a1 = word_in[23:16];
  logic [7:0] a2 = word_in[15:8];
  logic [7:0] a3 = word_in[7:0];
  return {
    gf_mult(a0,IC_MIX_COLUMN_MATRIX[3][3]) ^ gf_mult(a1,IC_MIX_COLUMN_MATRIX[3][2]) ^
    gf_mult(a2,IC_MIX_COLUMN_MATRIX[3][1]) ^ gf_mult(a3,IC_MIX_COLUMN_MATRIX[3][0]),

    gf_mult(a0,IC_MIX_COLUMN_MATRIX[2][3]) ^ gf_mult(a1,IC_MIX_COLUMN_MATRIX[2][2]) ^
    gf_mult(a2,IC_MIX_COLUMN_MATRIX[2][1]) ^ gf_mult(a3,IC_MIX_COLUMN_MATRIX[2][0]),

    gf_mult(a0,IC_MIX_COLUMN_MATRIX[1][3]) ^ gf_mult(a1,IC_MIX_COLUMN_MATRIX[1][2]) ^
    gf_mult(a2,IC_MIX_COLUMN_MATRIX[1][1]) ^ gf_mult(a3,IC_MIX_COLUMN_MATRIX[1][0]),

    gf_mult(a0,IC_MIX_COLUMN_MATRIX[0][3]) ^ gf_mult(a1,IC_MIX_COLUMN_MATRIX[0][2]) ^
    gf_mult(a2,IC_MIX_COLUMN_MATRIX[0][1]) ^ gf_mult(a3,IC_MIX_COLUMN_MATRIX[0][0])
  };
endfunction

function automatic logic [7:0] gf_mult(input logic[7:0] a, input logic[7:0] b);
  logic [7:0] temp_a;
  logic [7:0] p;
  p = 8'h00;
  temp_a = a;

  for(int i=0; i <8; i++)begin
    if(b[i])
      p ^= temp_a;
    
    temp_a = temp_a[7] ? (temp_a << 1 ^ 8'h1b) : (temp_a << 1);
  end
  
  return p;
endfunction

function automatic logic [31:0] subWord(input logic[31:0] word_in);
  subWord = {s_box_f(word_in[31:24]), s_box_f(word_in[23:16]),
              s_box_f(word_in[15:8]), s_box_f(word_in[7:0])};
endfunction

function automatic logic [7:0] s_box_f(input logic[7:0] byte_in);
   case(byte_in)
    'h00: s_box_f = 'h63;
    'h01: s_box_f = 'h7c;
    'h02: s_box_f = 'h77;
    'h03: s_box_f = 'h7b;
    'h04: s_box_f = 'hf2;
    'h05: s_box_f = 'h6b;
    'h06: s_box_f = 'h6f;
    'h07: s_box_f = 'hc5;
    'h08: s_box_f = 'h30;
    'h09: s_box_f = 'h01;
    'h0a: s_box_f = 'h67;
    'h0b: s_box_f = 'h2b;
    'h0c: s_box_f = 'hfe;
    'h0d: s_box_f = 'hd7;
    'h0e: s_box_f = 'hab;
    'h0f: s_box_f = 'h76;

    'h10: s_box_f = 'hca;
    'h11: s_box_f = 'h82;
    'h12: s_box_f = 'hc9;
    'h13: s_box_f = 'h7d;
    'h14: s_box_f = 'hfa;
    'h15: s_box_f = 'h59;
    'h16: s_box_f = 'h47;
    'h17: s_box_f = 'hf0;
    'h18: s_box_f = 'had;
    'h19: s_box_f = 'hd4;
    'h1a: s_box_f = 'ha2;
    'h1b: s_box_f = 'haf;
    'h1c: s_box_f = 'h9c;
    'h1d: s_box_f = 'ha4;
    'h1e: s_box_f = 'h72;
    'h1f: s_box_f = 'hc0;

    'h20: s_box_f = 'hb7;
    'h21: s_box_f = 'hfd;
    'h22: s_box_f = 'h93;
    'h23: s_box_f = 'h26;
    'h24: s_box_f = 'h36;
    'h25: s_box_f = 'h3f;
    'h26: s_box_f = 'hf7;
    'h27: s_box_f = 'hcc;
    'h28: s_box_f = 'h34;
    'h29: s_box_f = 'ha5;
    'h2a: s_box_f = 'he5;
    'h2b: s_box_f = 'hf1;
    'h2c: s_box_f = 'h71;
    'h2d: s_box_f = 'hd8;
    'h2e: s_box_f = 'h31;
    'h2f: s_box_f = 'h15;

    'h30: s_box_f = 'h04;
    'h31: s_box_f = 'hc7;
    'h32: s_box_f = 'h23;
    'h33: s_box_f = 'hc3;
    'h34: s_box_f = 'h18;
    'h35: s_box_f = 'h96;
    'h36: s_box_f = 'h05;
    'h37: s_box_f = 'h9a;
    'h38: s_box_f = 'h07;
    'h39: s_box_f = 'h12;
    'h3a: s_box_f = 'h80;
    'h3b: s_box_f = 'he2;
    'h3c: s_box_f = 'heb;
    'h3d: s_box_f = 'h27;
    'h3e: s_box_f = 'hb2;
    'h3f: s_box_f = 'h75;

    'h40: s_box_f = 'h09;
    'h41: s_box_f = 'h83;
    'h42: s_box_f = 'h2c;
    'h43: s_box_f = 'h1a;
    'h44: s_box_f = 'h1b;
    'h45: s_box_f = 'h6e;
    'h46: s_box_f = 'h5a;
    'h47: s_box_f = 'ha0;
    'h48: s_box_f = 'h52;
    'h49: s_box_f = 'h3b;
    'h4a: s_box_f = 'hd6;
    'h4b: s_box_f = 'hb3;
    'h4c: s_box_f = 'h29;
    'h4d: s_box_f = 'he3;
    'h4e: s_box_f = 'h2f;
    'h4f: s_box_f = 'h84;

    'h50: s_box_f = 'h53;
    'h51: s_box_f = 'hd1;
    'h52: s_box_f = 'h00;
    'h53: s_box_f = 'hed;
    'h54: s_box_f = 'h20;
    'h55: s_box_f = 'hfc;
    'h56: s_box_f = 'hb1;
    'h57: s_box_f = 'h5b;
    'h58: s_box_f = 'h6a;
    'h59: s_box_f = 'hcb;
    'h5a: s_box_f = 'hbe;
    'h5b: s_box_f = 'h39;
    'h5c: s_box_f = 'h4a;
    'h5d: s_box_f = 'h4c;
    'h5e: s_box_f = 'h58;
    'h5f: s_box_f = 'hcf;

    'h60: s_box_f = 'hd0;
    'h61: s_box_f = 'hef;
    'h62: s_box_f = 'haa;
    'h63: s_box_f = 'hfb;
    'h64: s_box_f = 'h43;
    'h65: s_box_f = 'h4d;
    'h66: s_box_f = 'h33;
    'h67: s_box_f = 'h85;
    'h68: s_box_f = 'h45;
    'h69: s_box_f = 'hf9;
    'h6a: s_box_f = 'h02;
    'h6b: s_box_f = 'h7f;
    'h6c: s_box_f = 'h50;
    'h6d: s_box_f = 'h3c;
    'h6e: s_box_f = 'h9f;
    'h6f: s_box_f = 'ha8;

    'h70: s_box_f = 'h51;
    'h71: s_box_f = 'ha3;
    'h72: s_box_f = 'h40;
    'h73: s_box_f = 'h8f;
    'h74: s_box_f = 'h92;
    'h75: s_box_f = 'h9d;
    'h76: s_box_f = 'h38;
    'h77: s_box_f = 'hf5;
    'h78: s_box_f = 'hbc;
    'h79: s_box_f = 'hb6;
    'h7a: s_box_f = 'hda;
    'h7b: s_box_f = 'h21;
    'h7c: s_box_f = 'h10;
    'h7d: s_box_f = 'hff;
    'h7e: s_box_f = 'hf3;
    'h7f: s_box_f = 'hd2;

    'h80: s_box_f = 'hcd;
    'h81: s_box_f = 'h0c;
    'h82: s_box_f = 'h13;
    'h83: s_box_f = 'hec;
    'h84: s_box_f = 'h5f;
    'h85: s_box_f = 'h97;
    'h86: s_box_f = 'h44;
    'h87: s_box_f = 'h17;
    'h88: s_box_f = 'hc4;
    'h89: s_box_f = 'ha7;
    'h8a: s_box_f = 'h7e;
    'h8b: s_box_f = 'h3d;
    'h8c: s_box_f = 'h64;
    'h8d: s_box_f = 'h5d;
    'h8e: s_box_f = 'h19;
    'h8f: s_box_f = 'h73;

    'h90: s_box_f = 'h60;
    'h91: s_box_f = 'h81;
    'h92: s_box_f = 'h4f;
    'h93: s_box_f = 'hdc;
    'h94: s_box_f = 'h22;
    'h95: s_box_f = 'h2a;
    'h96: s_box_f = 'h90;
    'h97: s_box_f = 'h88;
    'h98: s_box_f = 'h46;
    'h99: s_box_f = 'hee;
    'h9a: s_box_f = 'hb8;
    'h9b: s_box_f = 'h14;
    'h9c: s_box_f = 'hde;
    'h9d: s_box_f = 'h5e;
    'h9e: s_box_f = 'h0b;
    'h9f: s_box_f = 'hdb;

    'ha0: s_box_f = 'he0;
    'ha1: s_box_f = 'h32;
    'ha2: s_box_f = 'h3a;
    'ha3: s_box_f = 'h0a;
    'ha4: s_box_f = 'h49;
    'ha5: s_box_f = 'h06;
    'ha6: s_box_f = 'h24;
    'ha7: s_box_f = 'h5c;
    'ha8: s_box_f = 'hc2;
    'ha9: s_box_f = 'hd3;
    'haa: s_box_f = 'hac;
    'hab: s_box_f = 'h62;
    'hac: s_box_f = 'h91;
    'had: s_box_f = 'h95;
    'hae: s_box_f = 'he4;
    'haf: s_box_f = 'h79;

    'hb0: s_box_f = 'he7;
    'hb1: s_box_f = 'hc8;
    'hb2: s_box_f = 'h37;
    'hb3: s_box_f = 'h6d;
    'hb4: s_box_f = 'h8d;
    'hb5: s_box_f = 'hd5;
    'hb6: s_box_f = 'h4e;
    'hb7: s_box_f = 'ha9;
    'hb8: s_box_f = 'h6c;
    'hb9: s_box_f = 'h56;
    'hba: s_box_f = 'hf4;
    'hbb: s_box_f = 'hea;
    'hbc: s_box_f = 'h65;
    'hbd: s_box_f = 'h7a;
    'hbe: s_box_f = 'hae;
    'hbf: s_box_f = 'h08;

    'hc0: s_box_f = 'hba;
    'hc1: s_box_f = 'h78;
    'hc2: s_box_f = 'h25;
    'hc3: s_box_f = 'h2e;
    'hc4: s_box_f = 'h1c;
    'hc5: s_box_f = 'ha6;
    'hc6: s_box_f = 'hb4;
    'hc7: s_box_f = 'hc6;
    'hc8: s_box_f = 'he8;
    'hc9: s_box_f = 'hdd;
    'hca: s_box_f = 'h74;
    'hcb: s_box_f = 'h1f;
    'hcc: s_box_f = 'h4b;
    'hcd: s_box_f = 'hbd;
    'hce: s_box_f = 'h8b;
    'hcf: s_box_f = 'h8a;

    'hd0: s_box_f = 'h70;
    'hd1: s_box_f = 'h3e;
    'hd2: s_box_f = 'hb5;
    'hd3: s_box_f = 'h66;
    'hd4: s_box_f = 'h48;
    'hd5: s_box_f = 'h03;
    'hd6: s_box_f = 'hf6;
    'hd7: s_box_f = 'h0e;
    'hd8: s_box_f = 'h61;
    'hd9: s_box_f = 'h35;
    'hda: s_box_f = 'h57;
    'hdb: s_box_f = 'hb9;
    'hdc: s_box_f = 'h86;
    'hdd: s_box_f = 'hc1;
    'hde: s_box_f = 'h1d;
    'hdf: s_box_f = 'h9e;

    'he0: s_box_f = 'he1;
    'he1: s_box_f = 'hf8;
    'he2: s_box_f = 'h98;
    'he3: s_box_f = 'h11;
    'he4: s_box_f = 'h69;
    'he5: s_box_f = 'hd9;
    'he6: s_box_f = 'h8e;
    'he7: s_box_f = 'h94;
    'he8: s_box_f = 'h9b;
    'he9: s_box_f = 'h1e;
    'hea: s_box_f = 'h87;
    'heb: s_box_f = 'he9;
    'hec: s_box_f = 'hce;
    'hed: s_box_f = 'h55;
    'hee: s_box_f = 'h28;
    'hef: s_box_f = 'hdf;

    'hf0: s_box_f = 'h8c;
    'hf1: s_box_f = 'ha1;
    'hf2: s_box_f = 'h89;
    'hf3: s_box_f = 'h0d;
    'hf4: s_box_f = 'hbf;
    'hf5: s_box_f = 'he6;
    'hf6: s_box_f = 'h42;
    'hf7: s_box_f = 'h68;
    'hf8: s_box_f = 'h41;
    'hf9: s_box_f = 'h99;
    'hfa: s_box_f = 'h2d;
    'hfb: s_box_f = 'h0f;
    'hfc: s_box_f = 'hb0;
    'hfd: s_box_f = 'h54;
    'hfe: s_box_f = 'hbb;
    'hff: s_box_f = 'h16;
    default: s_box_f = 'h00;
  endcase
endfunction


function automatic logic [7:0] inv_s_box_f(input logic[7:0] byte_in);
   case(byte_in)
    'h00: inv_s_box_f = 'h52;
    'h01: inv_s_box_f = 'h09;
    'h02: inv_s_box_f = 'h6a;
    'h03: inv_s_box_f = 'hd5;
    'h04: inv_s_box_f = 'h30;
    'h05: inv_s_box_f = 'h36;
    'h06: inv_s_box_f = 'ha5;
    'h07: inv_s_box_f = 'h38;
    'h08: inv_s_box_f = 'hbf;
    'h09: inv_s_box_f = 'h40;
    'h0a: inv_s_box_f = 'ha3;
    'h0b: inv_s_box_f = 'h9e;
    'h0c: inv_s_box_f = 'h81;
    'h0d: inv_s_box_f = 'hf3;
    'h0e: inv_s_box_f = 'hd7;
    'h0f: inv_s_box_f = 'hfb;

    'h10: inv_s_box_f = 'h7c;
    'h11: inv_s_box_f = 'he3;
    'h12: inv_s_box_f = 'h39;
    'h13: inv_s_box_f = 'h82;
    'h14: inv_s_box_f = 'h9b;
    'h15: inv_s_box_f = 'h2f;
    'h16: inv_s_box_f = 'hff;
    'h17: inv_s_box_f = 'h87;
    'h18: inv_s_box_f = 'h34;
    'h19: inv_s_box_f = 'h8e;
    'h1a: inv_s_box_f = 'h43;
    'h1b: inv_s_box_f = 'h44;
    'h1c: inv_s_box_f = 'hc4;
    'h1d: inv_s_box_f = 'hde;
    'h1e: inv_s_box_f = 'he9;
    'h1f: inv_s_box_f = 'hcb;

    'h20: inv_s_box_f = 'h54;
    'h21: inv_s_box_f = 'h7b;
    'h22: inv_s_box_f = 'h94;
    'h23: inv_s_box_f = 'h32;
    'h24: inv_s_box_f = 'ha6;
    'h25: inv_s_box_f = 'hc2;
    'h26: inv_s_box_f = 'h23;
    'h27: inv_s_box_f = 'h3d;
    'h28: inv_s_box_f = 'hee;
    'h29: inv_s_box_f = 'h4c;
    'h2a: inv_s_box_f = 'h95;
    'h2b: inv_s_box_f = 'h0b;
    'h2c: inv_s_box_f = 'h42;
    'h2d: inv_s_box_f = 'hfa;
    'h2e: inv_s_box_f = 'hc3;
    'h2f: inv_s_box_f = 'h4e;

    'h30: inv_s_box_f = 'h08;
    'h31: inv_s_box_f = 'h2e;
    'h32: inv_s_box_f = 'ha1;
    'h33: inv_s_box_f = 'h66;
    'h34: inv_s_box_f = 'h28;
    'h35: inv_s_box_f = 'hd9;
    'h36: inv_s_box_f = 'h24;
    'h37: inv_s_box_f = 'hb2;
    'h38: inv_s_box_f = 'h76;
    'h39: inv_s_box_f = 'h5b;
    'h3a: inv_s_box_f = 'ha2;
    'h3b: inv_s_box_f = 'h49;
    'h3c: inv_s_box_f = 'h6d;
    'h3d: inv_s_box_f = 'h8b;
    'h3e: inv_s_box_f = 'hd1;
    'h3f: inv_s_box_f = 'h25;

    'h40: inv_s_box_f = 'h72;
    'h41: inv_s_box_f = 'hf8;
    'h42: inv_s_box_f = 'hf6;
    'h43: inv_s_box_f = 'h64;
    'h44: inv_s_box_f = 'h86;
    'h45: inv_s_box_f = 'h68;
    'h46: inv_s_box_f = 'h98;
    'h47: inv_s_box_f = 'h16;
    'h48: inv_s_box_f = 'hd4;
    'h49: inv_s_box_f = 'ha4;
    'h4a: inv_s_box_f = 'h5c;
    'h4b: inv_s_box_f = 'hcc;
    'h4c: inv_s_box_f = 'h5d;
    'h4d: inv_s_box_f = 'h65;
    'h4e: inv_s_box_f = 'hb6;
    'h4f: inv_s_box_f = 'h92;

    'h50: inv_s_box_f = 'h6c;
    'h51: inv_s_box_f = 'h70;
    'h52: inv_s_box_f = 'h48;
    'h53: inv_s_box_f = 'h50;
    'h54: inv_s_box_f = 'hfd;
    'h55: inv_s_box_f = 'hed;
    'h56: inv_s_box_f = 'hb9;
    'h57: inv_s_box_f = 'hda;
    'h58: inv_s_box_f = 'h5e;
    'h59: inv_s_box_f = 'h15;
    'h5a: inv_s_box_f = 'h46;
    'h5b: inv_s_box_f = 'h57;
    'h5c: inv_s_box_f = 'ha7;
    'h5d: inv_s_box_f = 'h8d;
    'h5e: inv_s_box_f = 'h9d;
    'h5f: inv_s_box_f = 'h84;

    'h60: inv_s_box_f = 'h90;
    'h61: inv_s_box_f = 'hd8;
    'h62: inv_s_box_f = 'hab;
    'h63: inv_s_box_f = 'h00;
    'h64: inv_s_box_f = 'h8c;
    'h65: inv_s_box_f = 'hbc;
    'h66: inv_s_box_f = 'hd3;
    'h67: inv_s_box_f = 'h0a;
    'h68: inv_s_box_f = 'hf7;
    'h69: inv_s_box_f = 'he4;
    'h6a: inv_s_box_f = 'h58;
    'h6b: inv_s_box_f = 'h05;
    'h6c: inv_s_box_f = 'hb8;
    'h6d: inv_s_box_f = 'hb3;
    'h6e: inv_s_box_f = 'h45;
    'h6f: inv_s_box_f = 'h06;

    'h70: inv_s_box_f = 'hd0;
    'h71: inv_s_box_f = 'h2c;
    'h72: inv_s_box_f = 'h1e;
    'h73: inv_s_box_f = 'h8f;
    'h74: inv_s_box_f = 'hca;
    'h75: inv_s_box_f = 'h3f;
    'h76: inv_s_box_f = 'h0f;
    'h77: inv_s_box_f = 'h02;
    'h78: inv_s_box_f = 'hc1;
    'h79: inv_s_box_f = 'haf;
    'h7a: inv_s_box_f = 'hbd;
    'h7b: inv_s_box_f = 'h03;
    'h7c: inv_s_box_f = 'h01;
    'h7d: inv_s_box_f = 'h13;
    'h7e: inv_s_box_f = 'h8a;
    'h7f: inv_s_box_f = 'h6b;

    'h80: inv_s_box_f = 'h3a;
    'h81: inv_s_box_f = 'h91;
    'h82: inv_s_box_f = 'h11;
    'h83: inv_s_box_f = 'h41;
    'h84: inv_s_box_f = 'h4f;
    'h85: inv_s_box_f = 'h67;
    'h86: inv_s_box_f = 'hdc;
    'h87: inv_s_box_f = 'hea;
    'h88: inv_s_box_f = 'h97;
    'h89: inv_s_box_f = 'hf2;
    'h8a: inv_s_box_f = 'hcf;
    'h8b: inv_s_box_f = 'hce;
    'h8c: inv_s_box_f = 'hf0;
    'h8d: inv_s_box_f = 'hb4;
    'h8e: inv_s_box_f = 'he6;
    'h8f: inv_s_box_f = 'h73;

    'h90: inv_s_box_f = 'h96;
    'h91: inv_s_box_f = 'hac;
    'h92: inv_s_box_f = 'h74;
    'h93: inv_s_box_f = 'h22;
    'h94: inv_s_box_f = 'he7;
    'h95: inv_s_box_f = 'had;
    'h96: inv_s_box_f = 'h35;
    'h97: inv_s_box_f = 'h85;
    'h98: inv_s_box_f = 'he2;
    'h99: inv_s_box_f = 'hf9;
    'h9a: inv_s_box_f = 'h37;
    'h9b: inv_s_box_f = 'he8;
    'h9c: inv_s_box_f = 'h1c;
    'h9d: inv_s_box_f = 'h75;
    'h9e: inv_s_box_f = 'hdf;
    'h9f: inv_s_box_f = 'h6e;

    'ha0: inv_s_box_f = 'h47;
    'ha1: inv_s_box_f = 'hf1;
    'ha2: inv_s_box_f = 'h1a;
    'ha3: inv_s_box_f = 'h71;
    'ha4: inv_s_box_f = 'h1d;
    'ha5: inv_s_box_f = 'h29;
    'ha6: inv_s_box_f = 'hc5;
    'ha7: inv_s_box_f = 'h89;
    'ha8: inv_s_box_f = 'h6f;
    'ha9: inv_s_box_f = 'hb7;
    'haa: inv_s_box_f = 'h62;
    'hab: inv_s_box_f = 'h0e;
    'hac: inv_s_box_f = 'haa;
    'had: inv_s_box_f = 'h18;
    'hae: inv_s_box_f = 'hbe;
    'haf: inv_s_box_f = 'h1b;

    'hb0: inv_s_box_f = 'hfc;
    'hb1: inv_s_box_f = 'h56;
    'hb2: inv_s_box_f = 'h3e;
    'hb3: inv_s_box_f = 'h4b;
    'hb4: inv_s_box_f = 'hc6;
    'hb5: inv_s_box_f = 'hd2;
    'hb6: inv_s_box_f = 'h79;
    'hb7: inv_s_box_f = 'h20;
    'hb8: inv_s_box_f = 'h9a;
    'hb9: inv_s_box_f = 'hdb;
    'hba: inv_s_box_f = 'hc0;
    'hbb: inv_s_box_f = 'hfe;
    'hbc: inv_s_box_f = 'h78;
    'hbd: inv_s_box_f = 'hcd;
    'hbe: inv_s_box_f = 'h5a;
    'hbf: inv_s_box_f = 'hf4;

    'hc0: inv_s_box_f = 'h1f;
    'hc1: inv_s_box_f = 'hdd;
    'hc2: inv_s_box_f = 'ha8;
    'hc3: inv_s_box_f = 'h33;
    'hc4: inv_s_box_f = 'h88;
    'hc5: inv_s_box_f = 'h07;
    'hc6: inv_s_box_f = 'hc7;
    'hc7: inv_s_box_f = 'h31;
    'hc8: inv_s_box_f = 'hb1;
    'hc9: inv_s_box_f = 'h12;
    'hca: inv_s_box_f = 'h10;
    'hcb: inv_s_box_f = 'h59;
    'hcc: inv_s_box_f = 'h27;
    'hcd: inv_s_box_f = 'h80;
    'hce: inv_s_box_f = 'hec;
    'hcf: inv_s_box_f = 'h5f;

    'hd0: inv_s_box_f = 'h60;
    'hd1: inv_s_box_f = 'h51;
    'hd2: inv_s_box_f = 'h7f;
    'hd3: inv_s_box_f = 'ha9;
    'hd4: inv_s_box_f = 'h19;
    'hd5: inv_s_box_f = 'hb5;
    'hd6: inv_s_box_f = 'h4a;
    'hd7: inv_s_box_f = 'h0d;
    'hd8: inv_s_box_f = 'h2d;
    'hd9: inv_s_box_f = 'he5;
    'hda: inv_s_box_f = 'h7a;
    'hdb: inv_s_box_f = 'h9f;
    'hdc: inv_s_box_f = 'h93;
    'hdd: inv_s_box_f = 'hc9;
    'hde: inv_s_box_f = 'h9c;
    'hdf: inv_s_box_f = 'hef;

    'he0: inv_s_box_f = 'ha0;
    'he1: inv_s_box_f = 'he0;
    'he2: inv_s_box_f = 'h3b;
    'he3: inv_s_box_f = 'h4d;
    'he4: inv_s_box_f = 'hae;
    'he5: inv_s_box_f = 'h2a;
    'he6: inv_s_box_f = 'hf5;
    'he7: inv_s_box_f = 'hb0;
    'he8: inv_s_box_f = 'hc8;
    'he9: inv_s_box_f = 'heb;
    'hea: inv_s_box_f = 'hbb;
    'heb: inv_s_box_f = 'h3c;
    'hec: inv_s_box_f = 'h83;
    'hed: inv_s_box_f = 'h53;
    'hee: inv_s_box_f = 'h99;
    'hef: inv_s_box_f = 'h61;

    'hf0: inv_s_box_f = 'h17;
    'hf1: inv_s_box_f = 'h2b;
    'hf2: inv_s_box_f = 'h04;
    'hf3: inv_s_box_f = 'h7e;
    'hf4: inv_s_box_f = 'hba;
    'hf5: inv_s_box_f = 'h77;
    'hf6: inv_s_box_f = 'hd6;
    'hf7: inv_s_box_f = 'h26;
    'hf8: inv_s_box_f = 'he1;
    'hf9: inv_s_box_f = 'h69;
    'hfa: inv_s_box_f = 'h14;
    'hfb: inv_s_box_f = 'h63;
    'hfc: inv_s_box_f = 'h55;
    'hfd: inv_s_box_f = 'h21;
    'hfe: inv_s_box_f = 'h0c;
    'hff: inv_s_box_f = 'h7d;
    default: inv_s_box_f = 'h00;
  endcase
endfunction

`endif