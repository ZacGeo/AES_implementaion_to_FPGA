// ============================================================
// tb_key_expansion_next_chunk.v
// Testbench for key_expansion_next_chunk.v
//
// Uses the official FIPS-197 Appendix A.3 AES-256 key
// expansion example. Key:
//   000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f
// i.e. w0..w7 = 00010203 04050607 08090a0b 0c0d0e0f
//               10111213 14151617 18191a1b 1c1d1e1f
//
// Expected next chunk (w8..w15):
//   a573c29f a176c498 a97fce93 a572c09c
//   1651a8cd 0244beda 1a5da4c1 0640bade
// ============================================================
`timescale 1ns/1ps

module tb_key_expansion_next_chunk;

    reg  [255:0] chunk_in;
    reg  [3:0]   round_num;
    wire [255:0] chunk_out;

    // Individual words of chunk_out, for readable waveform inspection
    wire [31:0] w8, w9, w10, w11, w12, w13, w14, w15;
    assign w8  = chunk_out[255:224];
    assign w9  = chunk_out[223:192];
    assign w10 = chunk_out[191:160];
    assign w11 = chunk_out[159:128];
    assign w12 = chunk_out[127:96];
    assign w13 = chunk_out[95:64];
    assign w14 = chunk_out[63:32];
    assign w15 = chunk_out[31:0];

    integer errors;

    key_expansion_next_chunk u_kexp (
        .chunk_in(chunk_in),
        .round_num(round_num),
        .chunk_out(chunk_out)
    );

    reg [255:0] expected;

    initial begin
        errors = 0;

        chunk_in = { 32'h00010203, 32'h04050607, 32'h08090a0b, 32'h0c0d0e0f,
                     32'h10111213, 32'h14151617, 32'h18191a1b, 32'h1c1d1e1f };
        round_num = 4'd1;

        expected = { 32'ha573c29f, 32'ha176c498, 32'ha97fce93, 32'ha572c09c,
                     32'h1651a8cd, 32'h0244beda, 32'h1a5da4c1, 32'h0640bade };

        #10;

        if (chunk_out !== expected) begin
            $display("FAIL: chunk_out = %h", chunk_out);
            $display("      expected  = %h", expected);
            errors = errors + 1;
        end else begin
            $display("PASS: chunk_out matches expected FIPS-197 AES-256 chunk 1");
        end

        // Individual word spot-checks, for clarity in the report
        if (w8  !== 32'ha573c29f) begin $display("FAIL: w8  = %h, expected a573c29f", w8);  errors=errors+1; end else $display("PASS: w8  = %h", w8);
        if (w9  !== 32'ha176c498) begin $display("FAIL: w9  = %h, expected a176c498", w9);  errors=errors+1; end else $display("PASS: w9  = %h", w9);
        if (w10 !== 32'ha97fce93) begin $display("FAIL: w10 = %h, expected a97fce93", w10); errors=errors+1; end else $display("PASS: w10 = %h", w10);
        if (w11 !== 32'ha572c09c) begin $display("FAIL: w11 = %h, expected a572c09c", w11); errors=errors+1; end else $display("PASS: w11 = %h", w11);
        if (w12 !== 32'h1651a8cd) begin $display("FAIL: w12 = %h, expected 1651a8cd", w12); errors=errors+1; end else $display("PASS: w12 = %h", w12);
        if (w13 !== 32'h0244beda) begin $display("FAIL: w13 = %h, expected 0244beda", w13); errors=errors+1; end else $display("PASS: w13 = %h", w13);
        if (w14 !== 32'h1a5da4c1) begin $display("FAIL: w14 = %h, expected 1a5da4c1", w14); errors=errors+1; end else $display("PASS: w14 = %h", w14);
        if (w15 !== 32'h0640bade) begin $display("FAIL: w15 = %h, expected 0640bade", w15); errors=errors+1; end else $display("PASS: w15 = %h", w15);

        if (errors == 0)
            $display("\n=== ALL TESTS PASSED (FIPS-197 AES-256 key expansion chunk 1 verified) ===\n");
        else
            $display("\n=== %0d ERROR(S) FOUND ===\n", errors);

        $finish;
    end

endmodule