// ============================================================
// tb_sub_bytes_state.v
// Testbench for sub_bytes_state.v and inv_sub_bytes_state.v
//
// Test 1: spot check using bytes whose sbox mapping is already
//          verified (00->63, ff->16, 53->ed from tb_sbox.v)
// Test 2: round trip - inv_sub_bytes_state(sub_bytes_state(x))
//          must equal x, for the full 128-bit state
// ============================================================
`timescale 1ns/1ps

module tb_sub_bytes_state;

    reg  [127:0] state_in;
    wire [127:0] state_out;
    wire [127:0] roundtrip_out;

    integer errors;

    sub_bytes_state u_sub (
        .state_in(state_in),
        .state_out(state_out)
    );

    inv_sub_bytes_state u_inv_roundtrip (
        .state_in(state_out),
        .state_out(roundtrip_out)
    );

    initial begin
        errors = 0;

        // --- Test 1: spot check, using bytes with known sbox mappings ---
        // 00->63, ff->16, 53->ed (verified earlier in tb_sbox.v),
        // remaining bytes arbitrary but traceable
        state_in = 128'h00_ff_53_01_02_03_04_05_06_07_08_09_0a_0b_0c_0d;
        #10;

        if (state_out[127:120] !== 8'h63) begin
            $display("FAIL: sub_bytes_state byte0 (from 00) = %h, expected 63", state_out[127:120]);
            errors = errors + 1;
        end else
            $display("PASS: sub_bytes_state byte0 (00->63) = %h", state_out[127:120]);

        if (state_out[119:112] !== 8'h16) begin
            $display("FAIL: sub_bytes_state byte1 (from ff) = %h, expected 16", state_out[119:112]);
            errors = errors + 1;
        end else
            $display("PASS: sub_bytes_state byte1 (ff->16) = %h", state_out[119:112]);

        if (state_out[111:104] !== 8'hed) begin
            $display("FAIL: sub_bytes_state byte2 (from 53) = %h, expected ed", state_out[111:104]);
            errors = errors + 1;
        end else
            $display("PASS: sub_bytes_state byte2 (53->ed) = %h", state_out[111:104]);

        // --- Test 2: full round trip on this state ---
        if (roundtrip_out !== state_in) begin
            $display("FAIL: inv_sub_bytes_state(sub_bytes_state(x)) = %h, expected %h", roundtrip_out, state_in);
            errors = errors + 1;
        end else
            $display("PASS: round trip verified (128-bit state)");

        // --- Test 3: round trip on a second, different state ---
        state_in = 128'hdeadbeefcafebabe0123456789abcdef;
        #10;

        if (roundtrip_out !== state_in) begin
            $display("FAIL: round trip failed on second state: got %h, expected %h", roundtrip_out, state_in);
            errors = errors + 1;
        end else
            $display("PASS: round trip verified on second (different) state");

        if (errors == 0)
            $display("\n=== ALL TESTS PASSED ===\n");
        else
            $display("\n=== %0d ERROR(S) FOUND ===\n", errors);

        $finish;
    end

endmodule