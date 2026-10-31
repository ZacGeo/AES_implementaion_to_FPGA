// ============================================================
// inv_mix_single_column.v
// AES InvMixColumns matrix applied to one 32-bit column
// (4 bytes: a0,a1,a2,a3, top row to bottom row)
//
//   b0 = 14*a0 ^ 11*a1 ^ 13*a2 ^  9*a3
//   b1 =  9*a0 ^ 14*a1 ^ 11*a2 ^ 13*a3
//   b2 = 13*a0 ^  9*a1 ^ 14*a2 ^ 11*a3
//   b3 = 11*a0 ^ 13*a1 ^  9*a2 ^ 14*a3
//
// Purely combinational, built from 4x gf_mult_decode.
// ============================================================
module inv_mix_single_column (
    input  wire [31:0] col_in,
    output wire [31:0] col_out
);

    wire [7:0] a0, a1, a2, a3;
    assign a0 = col_in[31:24];
    assign a1 = col_in[23:16];
    assign a2 = col_in[15:8];
    assign a3 = col_in[7:0];

    wire [7:0] m9_0, m11_0, m13_0, m14_0;
    wire [7:0] m9_1, m11_1, m13_1, m14_1;
    wire [7:0] m9_2, m11_2, m13_2, m14_2;
    wire [7:0] m9_3, m11_3, m13_3, m14_3;

    gf_mult_decode u0 ( .a(a0), .mul9(m9_0), .mul11(m11_0), .mul13(m13_0), .mul14(m14_0) );
    gf_mult_decode u1 ( .a(a1), .mul9(m9_1), .mul11(m11_1), .mul13(m13_1), .mul14(m14_1) );
    gf_mult_decode u2 ( .a(a2), .mul9(m9_2), .mul11(m11_2), .mul13(m13_2), .mul14(m14_2) );
    gf_mult_decode u3 ( .a(a3), .mul9(m9_3), .mul11(m11_3), .mul13(m13_3), .mul14(m14_3) );

    wire [7:0] b0 = m14_0 ^ m11_1 ^ m13_2 ^ m9_3;
    wire [7:0] b1 = m9_0  ^ m14_1 ^ m11_2 ^ m13_3;
    wire [7:0] b2 = m13_0 ^ m9_1  ^ m14_2 ^ m11_3;
    wire [7:0] b3 = m11_0 ^ m13_1 ^ m9_2  ^ m14_3;

    assign col_out = { b0, b1, b2, b3 };

endmodule