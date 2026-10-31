// ============================================================
// gf_mult_decode.v
// GF(2^8) multiply by 9, 11, 13, 14 - the four constants
// InvMixColumns needs for decryption.
//
//   x1 = xtime(a)             (a * 2)
//   x2 = xtime(x1)             (a * 4)
//   x3 = xtime(x2)             (a * 8)
//
//   mul9  = x3 XOR a                    (8+1)
//   mul11 = x3 XOR x1 XOR a             (8+2+1)
//   mul13 = x3 XOR x2 XOR a             (8+4+1)
//   mul14 = x3 XOR x2 XOR x1            (8+4+2)
//
// Purely combinational, built from 3 chained gf_xtime instances.
// ============================================================
module gf_mult_decode (
    input  wire [7:0] a,
    output wire [7:0] mul9,
    output wire [7:0] mul11,
    output wire [7:0] mul13,
    output wire [7:0] mul14
);

    wire [7:0] x1, x2, x3;

    gf_xtime u_x1 ( .a(a),  .result(x1) );  // a*2
    gf_xtime u_x2 ( .a(x1), .result(x2) );  // a*4
    gf_xtime u_x3 ( .a(x2), .result(x3) );  // a*8

    assign mul9  = x3 ^ a;
    assign mul11 = x3 ^ x1 ^ a;
    assign mul13 = x3 ^ x2 ^ a;
    assign mul14 = x3 ^ x2 ^ x1;

endmodule