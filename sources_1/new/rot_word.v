// ============================================================
// rot_word.v
// AES key expansion helper: RotWord
// Cyclically rotates a 32-bit word left by one byte:
//   {a,b,c,d} -> {b,c,d,a}   (a = MSB byte, d = LSB byte)
// Purely combinational - just rewiring, no logic gates needed
// ============================================================
module rot_word (
    input  wire [31:0] word_in,
    output wire [31:0] word_out
);

    assign word_out = { word_in[23:16], word_in[15:8], word_in[7:0], word_in[31:24] };

endmodule