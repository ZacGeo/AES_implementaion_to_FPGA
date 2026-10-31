// ============================================================
// key_expansion_prev_chunk.v
// Inverse step for the AES-256 key schedule.
// Reconstructs chunk k-1 from chunk k.
// round_num is the CURRENT chunk index k, valid 1..7.
// Used by the supplied key-expansion round-trip testbench.
// ============================================================
module key_expansion_prev_chunk (
    input  wire [255:0] chunk_in,
    input  wire [3:0]   round_num,
    output wire [255:0] chunk_out
);
    wire [31:0] c0, c1, c2, c3, c4, c5, c6, c7;
    assign c0 = chunk_in[255:224];
    assign c1 = chunk_in[223:192];
    assign c2 = chunk_in[191:160];
    assign c3 = chunk_in[159:128];
    assign c4 = chunk_in[127:96];
    assign c5 = chunk_in[95:64];
    assign c6 = chunk_in[63:32];
    assign c7 = chunk_in[31:0];

    // Recover p1..p3 and p5..p7 directly from XOR chains.
    wire [31:0] p1 = c1 ^ c0;
    wire [31:0] p2 = c2 ^ c1;
    wire [31:0] p3 = c3 ^ c2;
    wire [31:0] p5 = c5 ^ c4;
    wire [31:0] p6 = c6 ^ c5;
    wire [31:0] p7 = c7 ^ c6;

    // c4 = p4 XOR SubWord(c3)
    wire [31:0] sub_c3;
    sub_word u_sub_c3 (
        .word_in(c3),
        .word_out(sub_c3)
    );
    wire [31:0] p4 = c4 ^ sub_c3;

    // c0 = p0 XOR SubWord(RotWord(p7)) XOR Rcon[k]
    wire [31:0] rot_p7;
    wire [31:0] sub_rot_p7;
    wire [31:0] rcon_word;
    wire [7:0]  rcon_byte_unused;

    rot_word u_rot (
        .word_in(p7),
        .word_out(rot_p7)
    );

    sub_word u_sub_rot (
        .word_in(rot_p7),
        .word_out(sub_rot_p7)
    );

    rcon_gen u_rcon (
        .round_num(round_num),
        .rcon_byte(rcon_byte_unused),
        .rcon_word(rcon_word)
    );

    wire [31:0] p0 = c0 ^ sub_rot_p7 ^ rcon_word;

    assign chunk_out = {p0, p1, p2, p3, p4, p5, p6, p7};
endmodule
