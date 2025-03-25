// mixcolumn_single.v
module mixcolumn_single (
    input  [7:0] s0, s1, s2, s3,
    output [7:0] mc0, mc1, mc2, mc3
);

    function [7:0] xtime(input [7:0] b);
        xtime = (b[7] ? ((b << 1) ^ 8'h1b) : (b << 1));
    endfunction

    function [7:0] mul_by_02(input [7:0] b);
        mul_by_02 = xtime(b);
    endfunction

    function [7:0] mul_by_03(input [7:0] b);
        mul_by_03 = xtime(b) ^ b;
    endfunction

    assign mc0 = mul_by_02(s0) ^ mul_by_03(s1) ^ s2 ^ s3;
    assign mc1 = s0 ^ mul_by_02(s1) ^ mul_by_03(s2) ^ s3;
    assign mc2 = s0 ^ s1 ^ mul_by_02(s2) ^ mul_by_03(s3);
    assign mc3 = mul_by_03(s0) ^ s1 ^ s2 ^ mul_by_02(s3);

endmodule

