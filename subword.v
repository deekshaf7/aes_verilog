// subword.v
module subword (
    input         clk,
    input  [31:0] in_word,
    output [31:0] out_word,
    input         req,
    output reg    ack
);

    reg [7:0] sbox_in [0:3];
    wire [7:0] sbox_out [0:3];

    assign out_word = {sbox_out[0], sbox_out[1], sbox_out[2], sbox_out[3]};

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin: sbox_block
            sbox u_sbox (
                .in_byte(in_word[31 - i*8 -: 8]),
                .out_byte(sbox_out[i])
            );
        end
    endgenerate

    always @(posedge clk) begin
        ack <= req;
    end
endmodule

