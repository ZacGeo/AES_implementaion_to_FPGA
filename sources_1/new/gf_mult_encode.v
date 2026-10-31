// ============================================================
// gf_mult_encode.v
// GF(2^8) multiply by 2 and by 3, the two non-trivial
// constants MixColumns needs for encryption (the matrix also
// uses 1, but multiplying by 1 is just the identity).
//
//   mul2 = xtime(a)
//   mul3 = xtime(a) XOR a
//
// Purely combinational, built from gf_xtime.
// ============================================================
module gf_mult_encode (
    input  wire [7:0] a,
    output wire [7:0] mul2,
    output wire [7:0] mul3
);

    gf_xtime u_x1 ( .a(a), .result(mul2) );

    assign mul3 = mul2 ^ a;

endmodule