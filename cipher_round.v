// cipher_round.v
module cipher_round (
    input         clk,
    input  [127:0] state_in,
    input  [127:0] round_key,
    input  [3:0]   round,
    input         final_round,
    `ifdef DEEKSHA
    output reg [127:0] state_out,
    `else 
    output wire [127:0] state_out,
    `endif
    output reg         done
);

    wire [127:0] sb_out, sr_out, mc_out;
    wire [127:0] arkey_in;

    // SubBytes
    subbytes u_subbytes (
        .state_in(state_in),
        .state_out(sb_out)
    );

    // ShiftRows
    shiftrows u_shiftrows (
        .state_in(sb_out),
        .state_out(sr_out)
    );

    // MixColumns (not used in final round)
    mixcolumns u_mixcolumns (
        .state_in(sr_out),
        .state_out(mc_out)
    );

    assign arkey_in = final_round ? sr_out : mc_out;

    // AddRoundKey
    assign state_out = arkey_in ^ round_key;

    // done flag delayed by 1 cycle
    always @(posedge clk) begin
        done <= 1'b1;
    end

endmodule

