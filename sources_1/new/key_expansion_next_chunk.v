// ============================================================
// key_expansion_next_chunk.v
// AES-256 key schedule: generates the next 256-bit chunk
// (8 words) from the current 256-bit chunk.
//
// round_num is the new chunk index / Rcon index, valid 1..7.
// Example: input w0..w7 with round_num=1 -> output w8..w15.
// ============================================================
module key_expansion_next_chunk (
    input  wire [255:0] chunk_in,
    input  wire [3:0]   round_num,
    output wire [255:0] chunk_out
);
    wire [31:0] w0, w1, w2, w3, w4, w5, w6, w7;
    assign w0 = chunk_in[255:224];
    assign w1 = chunk_in[223:192];
    assign w2 = chunk_in[191:160];
    assign w3 = chunk_in[159:128];
    assign w4 = chunk_in[127:96];
    assign w5 = chunk_in[95:64];
    assign w6 = chunk_in[63:32];
    assign w7 = chunk_in[31:0];

    wire [31:0] rot_w7;
    wire [31:0] sub_rot_w7;
    wire [31:0] rcon_word;
    wire [7:0]  rcon_byte_unused;

    rot_word u_rot (
        .word_in(w7),
        .word_out(rot_w7)
    );

    sub_word u_sub_rot (
        .word_in(rot_w7),
        .word_out(sub_rot_w7)
    );

    rcon_gen u_rcon (
        .round_num(round_num),
        .rcon_byte(rcon_byte_unused),
        .rcon_word(rcon_word)
    );

    wire [31:0] n0, n1, n2, n3, n4, n5, n6, n7;
    wire [31:0] sub_n3;

    assign n0 = w0 ^ sub_rot_w7 ^ rcon_word;
    assign n1 = w1 ^ n0;
    assign n2 = w2 ^ n1;
    assign n3 = w3 ^ n2;

    sub_word u_sub_n3 (
        .word_in(n3),
        .word_out(sub_n3)
    );

    assign n4 = w4 ^ sub_n3;
    assign n5 = w5 ^ n4;
    assign n6 = w6 ^ n5;
    assign n7 = w7 ^ n6;

    assign chunk_out = {n0, n1, n2, n3, n4, n5, n6, n7};
endmodule
