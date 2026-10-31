// ============================================================
// gf_xtime.v
// GF(2^8) multiply-by-2 ("xtime"), per FIPS-197 field
// x^8 + x^4 + x^3 + x + 1 (reduction constant 0x1B)
//
//   xtime(a) = (a << 1)                  if MSB(a) == 0
//   xtime(a) = (a << 1) XOR 0x1B         if MSB(a) == 1
//
// This single operation is the building block every other
// constant multiplication in MixColumns/InvMixColumns is
// built from.
// ============================================================
module gf_xtime (
    input  wire [7:0] a,
    output wire [7:0] result
);

    wire msb = a[7];
    wire [7:0] shifted = a << 1;

    assign result = msb ? (shifted ^ 8'h1B) : shifted;

endmodule