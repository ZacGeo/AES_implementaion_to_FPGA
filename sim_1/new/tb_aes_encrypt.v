// ============================================================
// tb_aes_encrypt.v
// Testbench for aes_encrypt.v
//
// Uses the official FIPS-197 Appendix C.3 AES-256 known-answer
// test vector - this validates the ENTIRE encryption pipeline
// end-to-end (key expansion + all round transformations +
// control FSM) against a real published NIST result:
//
//   KEY:        000102030405060708090a0b0c0d0e0f
//               101112131415161718191a1b1c1d1e1f
//   PLAINTEXT:  00112233445566778899aabbccddeeff
//   CIPHERTEXT: 8ea2b7ca516745bfeafc49904b496089
//
// Follows the safe testbench timing pattern established
// earlier: every signal change/read happens after a #1 delay
// past the clock edge, to avoid racing the DUT's own clocked
// always block.
// ============================================================
`timescale 1ns/1ps

module tb_aes_encrypt;

    reg         clk;
    reg         rst;
    reg         start;
    reg  [127:0] plaintext;
    reg  [255:0] key;

    wire [127:0] ciphertext;
    wire         done;

    integer errors;
    integer timeout_count;

    reg [127:0] expected_ciphertext;

    aes_encrypt u_aes_encrypt (
        .clk(clk),
        .rst(rst),
        .start(start),
        .plaintext(plaintext),
        .key(key),
        .ciphertext(ciphertext),
        .done(done)
    );

    // 10ns clock period
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        errors = 0;
        timeout_count = 0;

        expected_ciphertext = 128'h8ea2b7ca516745bfeafc49904b496089;

        // --- Reset ---
        rst = 1; start = 0; plaintext = 128'd0; key = 256'd0;
        @(posedge clk);
        #1;
        rst = 0;

        // --- Load test vector and pulse start ---
        plaintext = 128'h00112233445566778899aabbccddeeff;
        key       = 256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f;
        start = 1;
        @(posedge clk);
        #1;
        start = 0;

        // --- Wait for done, with a generous timeout to avoid hanging forever on a bug ---
        while (!done && timeout_count < 100) begin
            @(posedge clk);
            #1;
            timeout_count = timeout_count + 1;
        end

        if (!done) begin
            $display("FAIL: encryption never completed (timed out after %0d cycles)", timeout_count);
            errors = errors + 1;
        end else begin
            $display("Encryption completed after %0d cycles", timeout_count);

            if (ciphertext !== expected_ciphertext) begin
                $display("FAIL: ciphertext = %h", ciphertext);
                $display("      expected   = %h", expected_ciphertext);
                errors = errors + 1;
            end else begin
                $display("PASS: ciphertext matches official FIPS-197 Appendix C.3 AES-256 test vector!");
                $display("      ciphertext = %h", ciphertext);
            end
        end

        if (errors == 0)
            $display("\n=== ALL TESTS PASSED (full AES-256 encryption pipeline verified against NIST test vector) ===\n");
        else
            $display("\n=== %0d ERROR(S) FOUND ===\n", errors);

        $finish;
    end

endmodule