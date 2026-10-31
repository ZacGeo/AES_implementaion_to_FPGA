// ============================================================
// sub_word.v
// AES key expansion helper: SubWord
// Applies the S-box independently to each of the 4 bytes
// of a 32-bit word. Purely combinational - reuses the
// already-verified sbox module, 4 instances in parallel.
// ============================================================
module sub_word (
    input  wire [31:0] word_in,
    output wire [31:0] word_out
);

    wire [7:0] byte_a_in, byte_b_in, byte_c_in, byte_d_in;
    wire [7:0] byte_a_out, byte_b_out, byte_c_out, byte_d_out;

    assign byte_a_in = word_in[31:24];
    assign byte_b_in = word_in[23:16];
    assign byte_c_in = word_in[15:8];
    assign byte_d_in = word_in[7:0];

    sbox u_sbox_a ( .addr(byte_a_in), .data(byte_a_out) );
    sbox u_sbox_b ( .addr(byte_b_in), .data(byte_b_out) );
    sbox u_sbox_c ( .addr(byte_c_in), .data(byte_c_out) );
    sbox u_sbox_d ( .addr(byte_d_in), .data(byte_d_out) );

    assign word_out = { byte_a_out, byte_b_out, byte_c_out, byte_d_out };

endmodule