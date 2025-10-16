
`ifndef _aes_parameters_svh_

`define _aes_parameters_svh_

parameter int AES_COLUMN = 4;
parameter int AES_ROW = 4;

typedef logic [7:0] aes_matrix_t [AES_ROW-1:0][AES_COLUMN-1:0];

typedef logic [14:0][127:0] round_keys_t;
 
logic [31:0] round_constats[10:0] = {'h36000000, 'h1b000000, 'h80000000, 'h40000000, 'h20000000,
                                    'h10000000, 'h08000000, 'h04000000, 'h02000000, 'h01000000,
                                  'h00000000};

function automatic logic [31:0] rotWord(input logic[31:0] word_in);
  rotWord = {word_in[23:0], word_in[31:24]};
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

`endif