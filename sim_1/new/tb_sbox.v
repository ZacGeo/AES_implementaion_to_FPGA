// ============================================================
// tb_sbox.v
// Testbench for sbox.v and inv_sbox.v
// Checks a handful of known FIPS-197 S-box values,
// and verifies that inv_sbox(sbox(x)) == x for all 256 values
// ============================================================
`timescale 1ns/1ps

module tb_sbox;

    reg  [7:0] test_addr;
    wire [7:0] sbox_out;
    wire [7:0] inv_sbox_out;
    wire [7:0] roundtrip_out;

    integer i;
    integer errors;

    sbox u_sbox (
        .addr(test_addr),
        .data(sbox_out)
    );

    inv_sbox u_inv_sbox (
        .addr(test_addr),
        .data(inv_sbox_out)
    );

    inv_sbox u_inv_sbox_roundtrip (
        .addr(sbox_out),
        .data(roundtrip_out)
    );

    initial begin
        errors = 0;

        test_addr = 8'h00; #10;
        if (sbox_out !== 8'h63) begin
            $display("FAIL: sbox(00) = %h, expected 63", sbox_out);
            errors = errors + 1;
        end else
            $display("PASS: sbox(00) = %h", sbox_out);

        test_addr = 8'hff; #10;
        if (sbox_out !== 8'h16) begin
            $display("FAIL: sbox(ff) = %h, expected 16", sbox_out);
            errors = errors + 1;
        end else
            $display("PASS: sbox(ff) = %h", sbox_out);

        test_addr = 8'h53; #10;
        if (sbox_out !== 8'hed) begin
            $display("FAIL: sbox(53) = %h, expected ed", sbox_out);
            errors = errors + 1;
        end else
            $display("PASS: sbox(53) = %h", sbox_out);

        test_addr = 8'h63; #10;
        if (inv_sbox_out !== 8'h00) begin
            $display("FAIL: inv_sbox(63) = %h, expected 00", inv_sbox_out);
            errors = errors + 1;
        end else
            $display("PASS: inv_sbox(63) = %h", inv_sbox_out);

        test_addr = 8'h16; #10;
        if (inv_sbox_out !== 8'hff) begin
            $display("FAIL: inv_sbox(16) = %h, expected ff", inv_sbox_out);
            errors = errors + 1;
        end else
            $display("PASS: inv_sbox(16) = %h", inv_sbox_out);

        for (i = 0; i < 256; i = i + 1) begin
            test_addr = i[7:0];
            #10;
            if (roundtrip_out !== i[7:0]) begin
                $display("FAIL: roundtrip mismatch at x=%h -> sbox=%h -> inv_sbox=%h",
                          i[7:0], sbox_out, roundtrip_out);
                errors = errors + 1;
            end
        end

        if (errors == 0)
            $display("\n=== ALL TESTS PASSED (256/256 round-trip + spot checks) ===\n");
        else
            $display("\n=== %0d ERROR(S) FOUND ===\n", errors);

        $finish;
    end

endmodule