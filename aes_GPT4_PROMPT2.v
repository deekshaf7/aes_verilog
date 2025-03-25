// aes_cipher_top.v
module aes_cipher_top (
    input         clk,
    input         rst,
    input         ld,           // load trigger
    output reg    done,         // encryption done
    input  [127:0] key,         // 128-bit AES key
    input  [127:0] text_in,     // plaintext input
    output [127:0] text_out     // ciphertext output
);

    // Parameters
    parameter Nr = 10;  // Number of rounds for AES-128

    // Internal signals
    reg [3:0] round;
    reg [127:0] state;
    wire [127:0] round_key;
    wire [127:0] state_next;
    wire        round_done;

    // State machine
    reg [2:0] state_fsm;
    parameter IDLE = 3'd0,
              INIT = 3'd1,
              ROUND = 3'd2,
              FINAL = 3'd3,
              DONE = 3'd4;

    // Key expansion instance
    wire [1407:0] w; // 44 words of 32 bits (AES-128)
    key_expansion key_exp(
        .clk(clk),
        .rst(rst),
        .key(key),
        .w(w)
    );

    // Round key mux
    assign round_key = w[(Nr-round)*128 +: 128]; // 4 words per round

    // Cipher core instance
    cipher_round round_unit (
        .clk(clk),
        .state_in(state),
        .round_key(round_key),
        .round(round),
        .final_round(round == Nr),
        .state_out(state_next),
        .done(round_done)
    );

    // Cipher output
    assign text_out = state;

    // FSM
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state_fsm <= IDLE;
            done <= 0;
            round <= 0;
            state <= 0;
        end else begin
            case (state_fsm)
                IDLE: begin
                    done <= 0;
                    if (ld) begin
                        state <= text_in;
                        round <= 0;
                        state_fsm <= INIT;
                    end
                end
                INIT: begin
                    state <= state ^ w[127:0]; // initial AddRoundKey
                    round <= 1;
                    state_fsm <= ROUND;
                end
                ROUND: begin
                    if (round_done) begin
                        state <= state_next;
                        if (round == Nr)
                            state_fsm <= DONE;
                        else
                            round <= round + 1;
                    end
                end
                DONE: begin
                    done <= 1;
                    state_fsm <= IDLE;
                end
            endcase
        end
    end
endmodule

