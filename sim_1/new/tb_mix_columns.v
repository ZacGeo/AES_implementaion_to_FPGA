// ============================================================
// tb_mix_columns.v
// Testbench for mix_single_column.v, mix_columns.v,
// inv_mix_single_column.v, inv_mix_columns.v
//
// Test vector db,13,53,45 -> 8e,4d,a1,bc is a widely-cited
// classic MixColumns worked example. Rather than trust it from
// memory, it was independently hand-verified byte-by-byte
// against the already-proven gf_xtime rule before being used
// here (see conversation notes / report for the full derivation).
//
// Tests:
//   1. mix_single_column on db135345 -> 8e4da1bc
//   2. Full mix_columns (all 4 state columns = db135345)
//      -> all 4 output columns = 8e4da1bc
//   3. Round trip: inv_mix_columns(mix_columns(x)) == x,
//      for two different state patterns
// ============================================================
`timescale 1ns/1ps

module tb_mix_columns;

    reg  [31:0] col_in;
    wire [31:0] col_out;

    reg  [127:0] state_in;
    wire [127:0] state_out;
    wire [127:0] roundtrip_out;

    integer errors;

    mix_single_column u_single (
        .col_in(col_in),
        .col_out(col_out)
    );

    mix_columns u_mix (
        .state_in(state_in),
        .state_out(state_out)
    );

    inv_mix_columns u_inv_mix (
        .state_in(state_out),
        .state_out(roundtrip_out)
    );

    initial begin
        errors = 0;

        // --- Test 1: single column, classic worked example ---
        col_in = 32'hdb135345;
        #10;

        if (col_out !== 32'h8e4da1bc) begin
            $display("FAIL: mix_single_column(db135345) = %h, expected 8e4da1bc", col_out);
            errors = errors + 1;
        end else
            $display("PASS: mix_single_column(db135345) = %h", col_out);

        // --- Test 2: full 128-bit state, same column repeated 4x ---
        state_in = { 32'hdb135345, 32'hdb135345, 32'hdb135345, 32'hdb135345 };
        #10;

        if (state_out !== { 32'h8e4da1bc, 32'h8e4da1bc, 32'h8e4da1bc, 32'h8e4da1bc }) begin
            $display("FAIL: mix_columns state_out = %h", state_out);
            errors = errors + 1;
        end else
            $display("PASS: mix_columns correctly applies to all 4 columns");

        // --- Test 3: round trip on this same state ---
        if (roundtrip_out !== state_in) begin
            $display("FAIL: inv_mix_columns(mix_columns(x)) = %h, expected %h", roundtrip_out, state_in);
            errors = errors + 1;
        end else
            $display("PASS: inv_mix_columns(mix_columns(x)) == x (round trip verified)");

        // --- Test 4: round trip on a second, different state ---
        state_in = 128'h00112233445566778899aabbccddeeff;
        #10;

        if (roundtrip_out !== state_in) begin
            $display("FAIL: round trip failed on second state: got %h, expected %h", roundtrip_out, state_in);
            errors = errors + 1;
        end else
            $display("PASS: round trip verified on second (different) state");

        if (errors == 0)
            $display("\n=== ALL TESTS PASSED (MixColumns / InvMixColumns verified) ===\n");
        else
            $display("\n=== %0d ERROR(S) FOUND ===\n", errors);

        $finish;
    end

endmodule