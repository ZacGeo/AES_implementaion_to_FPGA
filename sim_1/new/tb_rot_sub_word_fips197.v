`timescale 1ns / 1ps

// ============================================================
// tb_rot_sub_word_fips197.v
//
// Verification of RotWord and SubWord using the worked
// AES key-expansion example from FIPS-197 Appendix A.1.
//
// Input:
//   w[3] = 09cf4f3c
//
// Expected:
//   RotWord(w[3])             = cf4f3c09
//   SubWord(RotWord(w[3]))    = 8a84eb01
//
// Required design sources:
//   Rot_word.v   -> module rot_word
//   Sub_word.v   -> module sub_word
//   S_box.v      -> module sbox
// ============================================================

module tb_rot_sub_word_fips197;

    reg  [31:0] word_in;

    wire [31:0] rot_out;
    wire [31:0] sub_out;

    reg rot_pass;
    reg sub_pass;
    reg all_pass;

    // --------------------------------------------------------
    // DUT 1: RotWord
    // --------------------------------------------------------
    rot_word u_rot_word (
        .word_in  (word_in),
        .word_out (rot_out)
    );

    // --------------------------------------------------------
    // DUT 2: SubWord
    // The output of RotWord is connected directly to SubWord.
    // This makes the complete sequence visible in the waveform:
    //
    // word_in -> RotWord -> SubWord
    // --------------------------------------------------------
    sub_word u_sub_word (
        .word_in  (rot_out),
        .word_out (sub_out)
    );

    initial begin

        // Initial values
        word_in  = 32'h00000000;
        rot_pass = 1'b0;
        sub_pass = 1'b0;
        all_pass = 1'b0;

        // Small initial delay so the waveform clearly shows
        // the transition to the FIPS test value.
        #10;

        // ----------------------------------------------------
        // FIPS-197 Appendix A.1 test
        // w[3] = 09cf4f3c
        // ----------------------------------------------------
        word_in = 32'h09cf4f3c;

        // Both modules are combinational, so only a short
        // simulation delay is required.
        #10;

        rot_pass = (rot_out == 32'hcf4f3c09);
        sub_pass = (sub_out == 32'h8a84eb01);
        all_pass = rot_pass && sub_pass;

        $display("");
        $display("======================================================");
        $display(" FIPS-197 Appendix A.1 - RotWord / SubWord Test");
        $display("======================================================");
        $display("Input word                 = %08h", word_in);
        $display("RotWord output             = %08h", rot_out);
        $display("Expected RotWord           = cf4f3c09");
        $display("SubWord(RotWord) output    = %08h", sub_out);
        $display("Expected SubWord           = 8a84eb01");
        $display("------------------------------------------------------");

        if (rot_pass)
            $display("PASS: RotWord matches FIPS-197.");
        else
            $display("FAIL: RotWord mismatch.");

        if (sub_pass)
            $display("PASS: SubWord matches FIPS-197.");
        else
            $display("FAIL: SubWord mismatch.");

        if (all_pass)
            $display("PASS: COMPLETE RotWord -> SubWord TEST PASSED.");
        else
            $display("FAIL: COMPLETE RotWord -> SubWord TEST FAILED.");

        $display("======================================================");
        $display("");

        // Keep final values visible in the waveform for a while.
        #30;

        $finish;
    end

endmodule
