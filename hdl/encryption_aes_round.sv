`default_nettype none

`include "aes_parameters.svh"

module encryption_aes_round #(
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

aes_matrix_t sub_byte_matrix;
aes_matrix_t shift_rows_matrix;
aes_matrix_t mix_columns_matrix;

logic sub_byte_matrix_tvalid;
logic sub_byte_matrix_tlast;

logic shift_rows_matrix_tvalid;
logic shift_rows_matrix_tlast;

logic mix_columns_matrix_tvalid;
logic mix_columns_matrix_tlast;

logic [127:0] add_round_key_data;

int i,j;

assign aes_out_tdata = add_round_key_data;
assign aes_in_tready = aes_out_tready;

always_ff @(posedge clk) begin : sub_byte
  if(!resetn)begin
    for(i=0; i<AES_ROW; i++)begin
      for(j=0; j<AES_COLUMN; j++)begin
        sub_byte_matrix[i][j] <= 'd0;
      end
    end
  end
  else begin
    if(aes_in_tvalid & aes_in_tready)begin
      for(i=0; i<AES_ROW; i++)begin
        for(j=0; j<AES_COLUMN; j++)begin
          sub_byte_matrix[i][j] <= s_box_f(aes_in_tdata[8*(j*4+i)+:8]);
        end
      end
    end
  end
end : sub_byte

always_ff @(posedge clk) begin : shift_rows
  if(!resetn)begin
    for(i=0; i<AES_ROW; i++)begin
      for(j=0; j<AES_COLUMN; j++)begin
        shift_rows_matrix[i][j] <= 'd0;
      end
    end
  end
  else begin
    shift_rows_matrix[3][0] <= sub_byte_matrix[3][0];
    shift_rows_matrix[3][1] <= sub_byte_matrix[3][1];
    shift_rows_matrix[3][2] <= sub_byte_matrix[3][2];
    shift_rows_matrix[3][3] <= sub_byte_matrix[3][3];

    shift_rows_matrix[2][0] <= sub_byte_matrix[2][3];
    shift_rows_matrix[2][1] <= sub_byte_matrix[2][0];
    shift_rows_matrix[2][2] <= sub_byte_matrix[2][1];
    shift_rows_matrix[2][3] <= sub_byte_matrix[2][2];

    shift_rows_matrix[1][0] <= sub_byte_matrix[1][2];
    shift_rows_matrix[1][1] <= sub_byte_matrix[1][3];
    shift_rows_matrix[1][2] <= sub_byte_matrix[1][0];
    shift_rows_matrix[1][3] <= sub_byte_matrix[1][1];

    shift_rows_matrix[0][0] <= sub_byte_matrix[0][1];
    shift_rows_matrix[0][1] <= sub_byte_matrix[0][2];
    shift_rows_matrix[0][2] <= sub_byte_matrix[0][3];
    shift_rows_matrix[0][3] <= sub_byte_matrix[0][0];
  end
end : shift_rows

generate
  if(MIX_COLUMNS_EN) begin : gen_mix_columns
    always_ff @(posedge clk) begin : mix_columns
      if(!resetn)begin
        for(i=0; i<AES_ROW; i++)begin
          for(j=0; j<AES_COLUMN; j++)begin
            mix_columns_matrix[i][j] <= 'd0;
          end
        end
      end
      else begin
        for(i=0; i<AES_ROW; i++)begin
          for(j=0; j<AES_COLUMN; j++)begin
            mix_columns_matrix[i][j] <= gf_mult (shift_rows_matrix[0][j], MIX_COLUMN_MATRIX[i][0]) ^
                                        gf_mult (shift_rows_matrix[1][j], MIX_COLUMN_MATRIX[i][1]) ^
                                        gf_mult (shift_rows_matrix[2][j], MIX_COLUMN_MATRIX[i][2]) ^
                                        gf_mult (shift_rows_matrix[3][j], MIX_COLUMN_MATRIX[i][3]);
          end
        end
      end
    end
  end
  else begin : gen_no_mix_columns
    always_ff @(posedge clk) begin : mix_columns
      if(!resetn)begin
        for(i=0; i<AES_ROW; i++)begin
          for(j=0; j<AES_COLUMN; j++)begin
            mix_columns_matrix[i][j] <= 'd0;
          end
        end
      end
      else begin
        for(i=0; i<AES_ROW; i++)begin
          for(j=0; j<AES_COLUMN; j++)begin
            mix_columns_matrix[i][j] <= shift_rows_matrix[i][j];
          end
        end
      end
    end
  end
endgenerate


always_ff @(posedge clk) begin : add_round_key
  if(!resetn)begin
    add_round_key_data <= 'd0;
  end
  else begin
    for(i=0; i<AES_ROW; i++)begin
      for(j=0; j<AES_COLUMN; j++)begin
        add_round_key_data[8*(j*4+i)+:8] <=  mix_columns_matrix[i][j] ^ round_key[8*(j*4+i)+:8];
      end
    end
  end
end : add_round_key

always_ff @(posedge clk) begin : sub_byte_metadata
  if(!resetn)begin
    sub_byte_matrix_tvalid <= 'd0;
    sub_byte_matrix_tlast <= 'd0;
  end
  else begin
    sub_byte_matrix_tvalid <= aes_in_tvalid & aes_in_tready;
    sub_byte_matrix_tlast <= aes_in_tlast & aes_in_tvalid & aes_in_tready;
  end
end

always_ff @(posedge clk) begin : shift_rows_metadata
  if(!resetn)begin
    shift_rows_matrix_tvalid <= 'd0;
    shift_rows_matrix_tlast <= 'd0;
  end
  else begin
    shift_rows_matrix_tvalid <= sub_byte_matrix_tvalid;
    shift_rows_matrix_tlast <= sub_byte_matrix_tlast;
  end
end

always_ff @(posedge clk) begin : mix_columns_metadata
  if(!resetn)begin
    mix_columns_matrix_tvalid <= 'd0;
    mix_columns_matrix_tlast <= 'd0;
  end
  else begin
    mix_columns_matrix_tvalid <= shift_rows_matrix_tvalid;
    mix_columns_matrix_tlast <= shift_rows_matrix_tlast;
  end
end

always_ff @(posedge clk) begin : round_keys_metadata
  if(!resetn)begin
    aes_out_tvalid <= 'd0;
    aes_out_tlast <= 'd0;
  end
  else begin
    aes_out_tvalid <= mix_columns_matrix_tvalid;
    aes_out_tlast <= mix_columns_matrix_tlast;
  end
end
endmodule

`default_nettype wire
