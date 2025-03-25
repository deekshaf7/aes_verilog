// shiftrows.v
module shiftrows (
    input  [127:0] state_in,
    output [127:0] state_out
);

    wire [7:0] s [15:0];

    // Unpack state_in into byte array
    assign {s[0],  s[1],  s[2],  s[3],
            s[4],  s[5],  s[6],  s[7],
            s[8],  s[9],  s[10], s[11],
            s[12], s[13], s[14], s[15]} = state_in;

    // Perform ShiftRows
    assign state_out = {
        s[0],  s[5],  s[10], s[15], // Row 0 (no shift)
        s[4],  s[9],  s[14], s[3],  // Row 1 (shift by 1)
        s[8],  s[13], s[2],  s[7],  // Row 2 (shift by 2)
        s[12], s[1],  s[6],  s[11]  // Row 3 (shift by 3)
    };

endmodule

