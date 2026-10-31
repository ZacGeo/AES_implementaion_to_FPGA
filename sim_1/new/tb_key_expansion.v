// ============================================================
// tb_key_expansion.v
// Testbench for key_expansion.v
//
// Full round-trip test using the FIPS-197 AES-256 key:
//   1. Load the key (chunk 0)
//   2. Advance FORWARD 7 times to reach chunk 7 (RoundKey14)
//      - checks chunk 1 against the known value from
//        key_expansion_next_chunk's own testbench
//   3. Advance BACKWARD 7 times, direction reversed
//      - final chunk_reg must exactly equal the original key
//
// IMPORTANT TESTBENCH PATTERN: every signal read or write that
// relates to a clock edge happens only AFTER a #1 delay past
// that edge. This avoids a race between this testbench and the
// DUT's own always @(posedge clk) block sampling the same
// signals in the same simulation delta - a classic Verilog
// testbench pitfall.
// ============================================================
`timescale 1ns/1ps

module tb_key_expansion;

    reg         clk;
    reg         rst;
    reg  [255:0] key_in;
    reg         load;
    reg         advance;
    reg         direction;

    wire [255:0] chunk_reg;
    wire [3:0]   chunk_idx;

    integer errors;
    integer i;

    reg [255:0] original_key;
    reg [255:0] expected_chunk1;

    key_expansion u_kexp (
        .clk(clk),
        .rst(rst),
        .key_in(key_in),
        .load(load),
        .advance(advance),
        .direction(direction),
        .chunk_reg(chunk_reg),
        .chunk_idx(chunk_idx)
    );

    // 10ns clock period
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        errors = 0;

        original_key = { 32'h00010203, 32'h04050607, 32'h08090a0b, 32'h0c0d0e0f,
                          32'h10111213, 32'h14151617, 32'h18191a1b, 32'h1c1d1e1f };

        expected_chunk1 = { 32'ha573c29f, 32'ha176c498, 32'ha97fce93, 32'ha572c09c,
                             32'h1651a8cd, 32'h0244beda, 32'h1a5da4c1, 32'h0640bade };

        // --- Reset ---
        rst = 1; load = 0; advance = 0; direction = 0; key_in = 256'd0;
        @(posedge clk);
        #1;                    // let NBA settle before touching anything
        rst = 0;

        // --- Load the key as chunk 0 ---
        key_in = original_key;
        load = 1;
        @(posedge clk);
        #1;
        load = 0;

        if (chunk_reg !== original_key || chunk_idx !== 4'd0) begin
            $display("FAIL: after load, chunk_reg=%h chunk_idx=%0d", chunk_reg, chunk_idx);
            errors = errors + 1;
        end else
            $display("PASS: key loaded correctly as chunk 0");

        // --- Advance FORWARD once, check against known chunk 1 ---
        direction = 0;
        advance = 1;
        @(posedge clk);
        #1;
        advance = 0;

        if (chunk_reg !== expected_chunk1 || chunk_idx !== 4'd1) begin
            $display("FAIL: after 1 forward advance, chunk_reg=%h chunk_idx=%0d", chunk_reg, chunk_idx);
            errors = errors + 1;
        end else
            $display("PASS: forward step 1 matches known FIPS-197 chunk 1, chunk_idx=1");

        // --- Advance FORWARD 6 more times, to reach chunk 7 (RoundKey14) ---
        for (i = 0; i < 6; i = i + 1) begin
            advance = 1;
            @(posedge clk);
            #1;
            advance = 0;
        end

        if (chunk_idx !== 4'd7) begin
            $display("FAIL: after 7 total forward advances, chunk_idx=%0d, expected 7", chunk_idx);
            errors = errors + 1;
        end else
            $display("PASS: reached chunk_idx=7 (RoundKey14) after 7 forward advances");

        // --- Now advance BACKWARD 7 times ---
        direction = 1;
        for (i = 0; i < 7; i = i + 1) begin
            advance = 1;
            @(posedge clk);
            #1;
            advance = 0;
        end

        if (chunk_reg !== original_key || chunk_idx !== 4'd0) begin
            $display("FAIL: after 7 backward advances, chunk_reg=%h chunk_idx=%0d", chunk_reg, chunk_idx);
            $display("      expected chunk_reg=%h chunk_idx=0", original_key);
            errors = errors + 1;
        end else
            $display("PASS: 7 backward advances correctly return to the original key, chunk_idx=0");

        if (errors == 0)
            $display("\n=== ALL TESTS PASSED (full forward+backward key schedule round trip verified) ===\n");
        else
            $display("\n=== %0d ERROR(S) FOUND ===\n", errors);

        $finish;
    end

endmodule