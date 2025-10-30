`default_nettype none

`include "aes_parameters.svh"

module inverse_chiper_aes_round #(
  parameter int MIX_COLUMNS_EN = 1
)(
  input  wire  clk,
  input  wire  resetn,
  input  wire  [127:0] aes_in_tdata,
  input  wire  aes_in_tvalid,
  input  wire  aes_in_tlast,
  output wire  aes_in_tready,
  input  wire  [127:0] round_key,
  output logic [127:0] aes_out_tdata,
  output logic aes_out_tvalid,
  output logic aes_out_tlast,
  input  wire  aes_out_tready
);

aes_matrix_t inv_shift_rows_matrix;
aes_matrix_t inv_sub_bytes_matrix;
aes_matrix_t add_round_key_matrix;


int i,j;


always_ff @(posedge clk) begin : inv_shift_rows
  if(!resetn)begin
    for(i=0; i<AES_ROW; i++)begin
      for(j=0; j<AES_COLUMN; j++)begin
        inv_shift_rows_matrix[i][j] <= 'd0;
      end
    end
  end
  else begin
    if(aes_in_tvalid & aes_in_tready)begin
      inv_shift_rows_matrix[3][0] <= aes_in_tdata[63:56];
      inv_shift_rows_matrix[3][1] <= aes_in_tdata[95:88];
      inv_shift_rows_matrix[3][2] <= aes_in_tdata[127:120];
      inv_shift_rows_matrix[3][3] <= aes_in_tdata[31:24];

      inv_shift_rows_matrix[2][0] <= aes_in_tdata[87:80];
      inv_shift_rows_matrix[2][1] <= aes_in_tdata[119:112];
      inv_shift_rows_matrix[2][2] <= aes_in_tdata[23:16];
      inv_shift_rows_matrix[2][3] <= aes_in_tdata[55:48];

      inv_shift_rows_matrix[1][0] <= aes_in_tdata[111:104];
      inv_shift_rows_matrix[1][1] <= aes_in_tdata[15:8];
      inv_shift_rows_matrix[1][2] <= aes_in_tdata[47:40];
      inv_shift_rows_matrix[1][3] <= aes_in_tdata[79:72];

      inv_shift_rows_matrix[0][0] <= aes_in_tdata[7:0];
      inv_shift_rows_matrix[0][1] <= aes_in_tdata[39:32];
      inv_shift_rows_matrix[0][2] <= aes_in_tdata[71:64];
      inv_shift_rows_matrix[0][3] <= aes_in_tdata[103:96];
    end
  end
end : inv_shift_rows

always_ff @(posedge clk) begin : inv_sub_byte
  if(!resetn)begin
    for(i=0; i<AES_ROW; i++)begin
      for(j=0; j<AES_COLUMN; j++)begin
        inv_sub_bytes_matrix[i][j] <= 'd0;
      end
    end
  end
  else begin
    if(aes_in_tvalid & aes_in_tready)begin
      for(i=0; i<AES_ROW; i++)begin
        for(j=0; j<AES_COLUMN; j++)begin
          inv_sub_bytes_matrix[i][j] <= inv_s_box_f(inv_shift_rows_matrix[i][j]);
        end
      end
    end
  end
end : inv_sub_byte

always_ff @(posedge clk) begin : add_round_key
  if(!resetn)begin
    for(i=0; i<AES_ROW; i++)begin
      for(j=0; j<AES_COLUMN; j++)begin
        add_round_key_matrix[i][j] <= 'd0;
      end
    end
  end
  else begin
    for(i=0; i<AES_ROW; i++)begin
      for(j=0; j<AES_COLUMN; j++)begin
        add_round_key_matrix[i][j] <=  inv_sub_bytes_matrix[i][j] ^ round_key[8*(j*4+i)+:8];
      end
    end
  end
end : add_round_key



endmodule

`default_nettype wire
