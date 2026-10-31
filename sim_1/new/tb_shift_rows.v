// ============================================================
// tb_shift_rows.v
// Testbench for shift_rows.v and inv_shift_rows.v
//
// Uses a fully traceable input where every byte is unique
// (00,01,02,...,0F), so the expected output is derived directly
// from the row/column definition itself (not copied from an
// external source) - any wiring/transposition mistake would be
// immediately visible since no two bytes can be confused.
//
// Row/column layout of input bytes 00..0F:
//   Row0: 00 04 08 0c      Row1: 01 05 09 0d
//   Row2: 02 06 0a 0e      Row3: 03 07 0b 0f
//
// After ShiftRows (left-shift row r by r):
//   Row0: 00 04 08 0c (unchanged)
//   Row1: 05 09 0d 01 (left 1)
//   Row2: 0a 0e 02 06 (left 2)
//   Row3: 0f 03 07 0b (left 3)
// -> byte stream: 00 05 0a 0f 04 09 0e 03 08 0d 02 07 0c 01 06 0b
//
// Also verifies inv_shift_rows(shift_rows(x)) == x
// ============================================================
`timescale 1ns/1ps

module tb_shift_rows;

    reg  [127:0] state_in;
    wire [127:0] shifted;
    wire [127:0] unshifted;
    wire [127:0] roundtrip;

    integer errors;

    shift_rows u_shift (
        .state_in(state_in),
        .state_out(shifted)
    );

    inv_shift_rows u_inv_shift (
        .state_in(state_in),
        .state_out(unshifted)
    );

    // Round-trip: feed shift_rows' output back through inv_shift_rows
    inv_shift_rows u_roundtrip (
        .state_in(shifted),
        .state_out(roundtrip)
    );

    initial begin
        errors = 0;

        // --- Test 1: sequential byte pattern ---
        state_in = 128'h000102030405060708090a0b0c0d0e0f;
        #10;

        if (shifted !== 128'h00_05_0a_0f_04_09_0e_03_08_0d_02_07_0c_01_06_0b) begin
            $display("FAIL: shift_rows output = %h", shifted);
            $display("      expected           = 00050a0f04090e03080d02070c01060b");
            errors = errors + 1;
        end else
            $display("PASS: shift_rows matches hand-derived expected value");

        if (roundtrip !== state_in) begin
            $display("FAIL: inv_shift_rows(shift_rows(x)) = %h, expected %h", roundtrip, state_in);
            errors = errors + 1;
        end else
            $display("PASS: inv_shift_rows(shift_rows(x)) == x (round trip verified)");

        // --- Test 2: a second, different pattern for extra confidence ---
        state_in = 128'hf0e1d2c3b4a596887a6b5c4d3e2f1001;
        #10;

        if (roundtrip !== state_in) begin
            $display("FAIL: round trip failed on second pattern: got %h, expected %h", roundtrip, state_in);
            errors = errors + 1;
        end else
            $display("PASS: round trip verified on second (different) pattern");

        if (errors == 0)
            $display("\n=== ALL TESTS PASSED ===\n");
        else
            $display("\n=== %0d ERROR(S) FOUND ===\n", errors);

        $finish;
    end

endmodule