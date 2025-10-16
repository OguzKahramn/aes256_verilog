`default_nettype none

`include "aes_parameters.svh"

module key_expansion #(
  parameter int KEY_WIDTH = 256
)(
  input  wire clk,
  input  wire resetn,

  input  wire [KEY_WIDTH-1:0] aes_key_i,
  input  wire aes_key_valid_i,

  output round_keys_t round_keys_o,
  output wire round_keys_valid_o
);

logic [31:0] w_reg[0:59];
logic [31:0] temp_word;
logic keys_valid;
logic aes_key_valid_pre;

logic [5:0] word_counter;

int i;

always_ff @(posedge clk) begin
  if (keys_valid) begin
    round_keys_o <= '{
      {w_reg[56], w_reg[57], w_reg[58], w_reg[59]},
      {w_reg[52], w_reg[53], w_reg[54], w_reg[55]},
      {w_reg[48], w_reg[49], w_reg[50], w_reg[51]},
      {w_reg[44], w_reg[45], w_reg[46], w_reg[47]},
      {w_reg[40], w_reg[41], w_reg[42], w_reg[43]},
      {w_reg[36], w_reg[37], w_reg[38], w_reg[39]},
      {w_reg[32], w_reg[33], w_reg[34], w_reg[35]},
      {w_reg[28], w_reg[29], w_reg[30], w_reg[31]},
      {w_reg[24], w_reg[25], w_reg[26], w_reg[27]},
      {w_reg[20], w_reg[21], w_reg[22], w_reg[23]},
      {w_reg[16], w_reg[17], w_reg[18], w_reg[19]},
      {w_reg[12], w_reg[13], w_reg[14], w_reg[15]},
      {w_reg[8],  w_reg[9],  w_reg[10], w_reg[11]},
      {w_reg[4], w_reg[5], w_reg[6], w_reg[7]},
      {w_reg[0], w_reg[1], w_reg[2], w_reg[3]}
    };
  end
end
assign round_keys_valid_o = keys_valid;

typedef enum {
  IDLE_S,
  EXPAND_S,
  DONE_S
} state_t;

state_t state;

always_ff @(posedge clk ) begin
  if (!resetn) begin
    for (i=0; i<8; i++) begin
      w_reg[i] <= 'd0;
    end
    keys_valid <= 'd0;
    aes_key_valid_pre <= 'd0;
    word_counter <= 'd0;
    state <= IDLE_S;
  end
  else begin
    aes_key_valid_pre <= aes_key_valid_i;
    case(state)
    
    IDLE_S:begin
      if (aes_key_valid_i && ~aes_key_valid_pre) begin
        for(i=0;i<8; i++) begin
          w_reg[i] <= aes_key_i[255-32*i-:32];
        end
        word_counter <= 'd8;
        state <= EXPAND_S;
        keys_valid <= 1'b0;
      end
      else begin
        
        word_counter <= 'd0;
        state <= IDLE_S;
      end
    end

    EXPAND_S: begin
      if(word_counter == 'd60)begin
        word_counter <= 'd0;
        state <= DONE_S;
      end
      else begin
        if(word_counter % 8 == 0)begin
          w_reg[word_counter] <= subWord(rotWord(w_reg[word_counter-1])) ^ round_constats[(word_counter/8)] ^ w_reg[word_counter-8];
        end
        else if (word_counter % 8 == 4)begin
          w_reg[word_counter] <= subWord(w_reg[word_counter-1]) ^ w_reg[word_counter-8];
        end
        else begin
          w_reg[word_counter] <= w_reg[word_counter-1] ^ w_reg[word_counter-8];
        end
        word_counter <= word_counter + 'd1;
      end
    end

    DONE_S : begin
      keys_valid <= 1'b1;
      state <= IDLE_S;
    end
    default: state <= IDLE_S;
    endcase
  end
end

endmodule

`default_nettype wire
