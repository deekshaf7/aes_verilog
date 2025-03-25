// mixcolumns.v
module mixcolumns (
    input  [127:0] state_in,
    output [127:0] state_out
);

    wire [7:0] s [15:0];
    wire [7:0] mc [15:0];

    // Unpack state input
    assign {s[0],  s[1],  s[2],  s[3],
            s[4],  s[5],  s[6],  s[7],
            s[8],  s[9],  s[10], s[11],
            s[12], s[13], s[14], s[15]} = state_in;

    genvar c;
    generate
        for (c = 0; c < 4; c = c + 1) begin : mix_column
            mixcolumn_single mcs (
                .s0(s[c*4 + 0]),
                .s1(s[c*4 + 1]),
                .s2(s[c*4 + 2]),
                .s3(s[c*4 + 3]),
                .mc0(mc[c*4 + 0]),
                .mc1(mc[c*4 + 1]),
                .mc2(mc[c*4 + 2]),
                .mc3(mc[c*4 + 3])
            );
        end
    endgenerate

    assign state_out = {mc[0],  mc[1],  mc[2],  mc[3],
                        mc[4],  mc[5],  mc[6],  mc[7],
                        mc[8],  mc[9],  mc[10], mc[11],
                        mc[12], mc[13], mc[14], mc[15]};
endmodule

