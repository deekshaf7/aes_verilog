// subbytes.v
module subbytes (
    input  [127:0] state_in,
    output [127:0] state_out
);

    wire [7:0] sb [15:0];
    genvar i;

    generate
        for (i = 0; i < 16; i = i + 1) begin : sub_byte_loop
            sbox u_sbox (
                .in_byte(state_in[8*(15-i) +: 8]),
                .out_byte(sb[i])
            );
        end
    endgenerate

    assign state_out = {sb[15], sb[14], sb[13], sb[12],
                        sb[11], sb[10], sb[9],  sb[8],
                        sb[7],  sb[6],  sb[5],  sb[4],
                        sb[3],  sb[2],  sb[1],  sb[0]};

endmodule

