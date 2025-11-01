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

logic [127:0] inv_shift_rows_data;
aes_matrix_t inv_sub_bytes_matrix;
aes_matrix_t add_round_key_matrix;
aes_matrix_t inv_mix_column_matrix;
logic inv_sub_bytes_valid;
logic inv_sub_bytes_last;
logic inv_mix_columns_valid;
logic inv_mix_columns_last;
logic add_round_key_valid;
logic add_round_key_last;

int i,j;

assign aes_out_tdata = inv_shift_rows_data;
assign aes_in_tready = aes_out_tready;


always_ff @(posedge clk) begin : add_round_key
  if(!resetn)begin
    for(i=0; i<AES_ROW; i++)begin
      for(j=0; j<AES_COLUMN; j++)begin
        add_round_key_matrix[i][j] <= 'd0;
      end
    end
  end
  else begin
    if(aes_in_tvalid & aes_in_tready)begin
      for(i=0; i<AES_ROW; i++)begin
        for(j=0; j<AES_COLUMN; j++)begin
          add_round_key_matrix[i][j] <=  aes_in_tdata[8*(j*4+i)+:8] ^ round_key[8*(j*4+i)+:8];
        end
      end
    end
  end
end : add_round_key

generate
  if(MIX_COLUMNS_EN) begin : gen_mix_columns
    always_ff @(posedge clk)begin : inv_mix_columns
      if(!resetn)begin
        for(i=0; i<AES_ROW; i++)begin
          for(j=0; j<AES_COLUMN; j++)begin
            inv_mix_column_matrix[i][j] <= 'd0;
          end
        end
      end
      else begin
        for(i=0; i<AES_ROW; i++)begin
          for(j=0; j<AES_COLUMN; j++)begin
            inv_mix_column_matrix[i][j] <= gf_mult(add_round_key_matrix[0][j], IC_MIX_COLUMN_MATRIX[i][0]) ^
                                           gf_mult(add_round_key_matrix[1][j], IC_MIX_COLUMN_MATRIX[i][1]) ^
                                           gf_mult(add_round_key_matrix[2][j], IC_MIX_COLUMN_MATRIX[i][2]) ^
                                           gf_mult(add_round_key_matrix[3][j], IC_MIX_COLUMN_MATRIX[i][3]);
          end
        end
      end
    end
  end
  else begin
    always_ff @(posedge clk)begin : inv_mix_columns
      if(!resetn)begin
        for(i=0; i<AES_ROW; i++)begin
          for(j=0; j<AES_COLUMN; j++)begin
            inv_mix_column_matrix[i][j] <= 'd0;
          end
        end
      end
      else begin
        for(i=0; i<AES_ROW; i++)begin
          for(j=0; j<AES_COLUMN; j++)begin
            inv_mix_column_matrix[i][j] <= add_round_key_matrix[i][j];
          end
        end
      end
    end
  end

endgenerate

always_ff @(posedge clk) begin : inv_sub_byte
  if(!resetn)begin
    for(i=0; i<AES_ROW; i++)begin
      for(j=0; j<AES_COLUMN; j++)begin
        inv_sub_bytes_matrix[i][j] <= 'd0;
      end
    end
  end
  else begin
    for(i=0; i<AES_ROW; i++)begin
      for(j=0; j<AES_COLUMN; j++)begin
        inv_sub_bytes_matrix[i][j] <= inv_s_box_f(inv_mix_column_matrix[i][j]);
      end
    end
  end
end : inv_sub_byte

always_ff @(posedge clk) begin : inv_shift_rows
  if(!resetn)begin
    inv_shift_rows_data <= 'd0;
  end
  else begin
    inv_shift_rows_data[7:0]     <= inv_sub_bytes_matrix[0][3];
    inv_shift_rows_data[15:8]    <= inv_sub_bytes_matrix[1][2];
    inv_shift_rows_data[23:16]   <= inv_sub_bytes_matrix[2][1];
    inv_shift_rows_data[31:24]   <= inv_sub_bytes_matrix[3][0];

    inv_shift_rows_data[39:32]   <= inv_sub_bytes_matrix[0][0];
    inv_shift_rows_data[47:40]   <= inv_sub_bytes_matrix[1][3];
    inv_shift_rows_data[55:48]   <= inv_sub_bytes_matrix[2][2];
    inv_shift_rows_data[63:56]   <= inv_sub_bytes_matrix[3][1];

    inv_shift_rows_data[71:64]   <= inv_sub_bytes_matrix[0][1];
    inv_shift_rows_data[79:72]   <= inv_sub_bytes_matrix[1][0];
    inv_shift_rows_data[87:80]   <= inv_sub_bytes_matrix[2][3];
    inv_shift_rows_data[95:88]   <= inv_sub_bytes_matrix[3][2];

    inv_shift_rows_data[103:96]  <= inv_sub_bytes_matrix[0][2];
    inv_shift_rows_data[111:104] <= inv_sub_bytes_matrix[1][1];
    inv_shift_rows_data[119:112] <= inv_sub_bytes_matrix[2][0];
    inv_shift_rows_data[127:120] <= inv_sub_bytes_matrix[3][3];
  end
end : inv_shift_rows


always_ff @(posedge clk) begin : add_round_key_metada
  if(!resetn)begin
    add_round_key_valid <= 'd0;
    add_round_key_last <= 'd0;
  end
  else begin
    add_round_key_valid <= aes_in_tready & aes_in_tvalid;
    add_round_key_last <= aes_in_tready & aes_in_tvalid & aes_in_tlast;
  end
end

always_ff @(posedge clk) begin : inv_mix_columns_metadata
  if(!resetn)begin
    inv_mix_columns_valid <= 'd0;
    inv_mix_columns_last <= 'd0;
  end
  else begin
    inv_mix_columns_valid <= add_round_key_valid;
    inv_mix_columns_last <= add_round_key_last;
  end
end

always_ff @(posedge clk) begin : inv_sub_bytes_metada
  if(!resetn)begin
    inv_sub_bytes_valid <= 'd0;
    inv_sub_bytes_last <= 'd0;
  end
  else begin
    inv_sub_bytes_valid <= inv_mix_columns_valid;
    inv_sub_bytes_last <= inv_mix_columns_last;
  end
end

always_ff @(posedge clk) begin : inv_shift_rows_metada
  if(!resetn)begin
    aes_out_tvalid <= 'd0;
    aes_out_tlast <= 'd0;
  end
  else begin
    aes_out_tvalid <= inv_sub_bytes_valid;
    aes_out_tlast <= inv_sub_bytes_last;
  end
end


endmodule

`default_nettype wire
