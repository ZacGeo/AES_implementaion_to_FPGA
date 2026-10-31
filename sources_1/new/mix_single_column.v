// ============================================================
// mix_single_column.v
// AES MixColumns matrix applied to one 32-bit column
// (4 bytes: a0,a1,a2,a3, top row to bottom row)
//
//   b0 = 2*a0 ^ 3*a1 ^   a2 ^   a3
//   b1 =   a0 ^ 2*a1 ^ 3*a2 ^   a3
//   b2 =   a0 ^   a1 ^ 2*a2 ^ 3*a3
//   b3 = 3*a0 ^   a1 ^   a2 ^ 2*a3
//
// Purely combinational, built from 4x gf_mult_encode.
// ============================================================
module mix_single_column (
    input  wire [31:0] col_in,   // a0||a1||a2||a3
    output wire [31:0] col_out   // b0||b1||b2||b3
);

    wire [7:0] a0, a1, a2, a3;
    assign a0 = col_in[31:24];
    assign a1 = col_in[23:16];
    assign a2 = col_in[15:8];
    assign a3 = col_in[7:0];

    wire [7:0] mul2_a0, mul3_a0;
    wire [7:0] mul2_a1, mul3_a1;
    wire [7:0] mul2_a2, mul3_a2;
    wire [7:0] mul2_a3, mul3_a3;

    gf_mult_encode u0 ( .a(a0), .mul2(mul2_a0), .mul3(mul3_a0) );
    gf_mult_encode u1 ( .a(a1), .mul2(mul2_a1), .mul3(mul3_a1) );
    gf_mult_encode u2 ( .a(a2), .mul2(mul2_a2), .mul3(mul3_a2) );
    gf_mult_encode u3 ( .a(a3), .mul2(mul2_a3), .mul3(mul3_a3) );

    wire [7:0] b0 = mul2_a0 ^ mul3_a1 ^ a2      ^ a3;
    wire [7:0] b1 = a0      ^ mul2_a1 ^ mul3_a2 ^ a3;
    wire [7:0] b2 = a0      ^ a1      ^ mul2_a2 ^ mul3_a3;
    wire [7:0] b3 = mul3_a0 ^ a1      ^ a2      ^ mul2_a3;

    assign col_out = { b0, b1, b2, b3 };

endmodule