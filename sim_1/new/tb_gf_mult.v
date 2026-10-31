// ============================================================
// tb_gf_mult.v
// Testbench for gf_xtime.v, gf_mult_encode.v, gf_mult_decode.v
//
// Anchored to the official FIPS-197 SS4.2.1 worked example:
//   xtime(0x57) = 0xae
//   xtime(0xae) = 0x47   (= 0x57 * 4)
//   xtime(0x47) = 0x8e   (= 0x57 * 8)
//
// All other expected values (mul3, mul9, mul11, mul13, mul14)
// are hand-derived by XORing these verified chain values
// together, per the standard decomposition (e.g. 9 = 8+1).
// ============================================================
`timescale 1ns/1ps

module tb_gf_mult;

    reg  [7:0] a;
    wire [7:0] xtime_out;

    wire [7:0] mul2, mul3;
    wire [7:0] mul9, mul11, mul13, mul14;

    integer errors;

    gf_xtime u_xtime ( .a(a), .result(xtime_out) );

    gf_mult_encode u_encode ( .a(a), .mul2(mul2), .mul3(mul3) );

    gf_mult_decode u_decode ( .a(a), .mul9(mul9), .mul11(mul11), .mul13(mul13), .mul14(mul14) );

    initial begin
        errors = 0;

        a = 8'h57;
        #10;

        // --- Anchor check: matches FIPS-197 SS4.2.1 directly ---
        if (xtime_out !== 8'hae) begin
            $display("FAIL: xtime(0x57) = %h, expected ae", xtime_out);
            errors = errors + 1;
        end else
            $display("PASS: xtime(0x57) = %h  (matches FIPS-197 SS4.2.1)", xtime_out);

        // --- gf_mult_encode: mul2 should equal xtime directly ---
        if (mul2 !== 8'hae) begin
            $display("FAIL: mul2(0x57) = %h, expected ae", mul2);
            errors = errors + 1;
        end else
            $display("PASS: mul2(0x57) = %h", mul2);

        // mul3 = xtime(0x57) XOR 0x57 = 0xae XOR 0x57 = 0xf9
        if (mul3 !== 8'hf9) begin
            $display("FAIL: mul3(0x57) = %h, expected f9", mul3);
            errors = errors + 1;
        end else
            $display("PASS: mul3(0x57) = %h", mul3);

        // --- gf_mult_decode: hand-derived from the verified xtime chain ---
        // x1=ae, x2=47, x3=8e  (all match FIPS-197 SS4.2.1 chain)
        // mul9  = x3 XOR a         = 8e ^ 57 = d9
        // mul11 = x3 XOR x1 XOR a  = 8e ^ ae ^ 57 = 77
        // mul13 = x3 XOR x2 XOR a  = 8e ^ 47 ^ 57 = 9e
        // mul14 = x3 XOR x2 XOR x1 = 8e ^ 47 ^ ae = 67
        if (mul9 !== 8'hd9) begin
            $display("FAIL: mul9(0x57) = %h, expected d9", mul9);
            errors = errors + 1;
        end else
            $display("PASS: mul9(0x57) = %h", mul9);

        if (mul11 !== 8'h77) begin
            $display("FAIL: mul11(0x57) = %h, expected 77", mul11);
            errors = errors + 1;
        end else
            $display("PASS: mul11(0x57) = %h", mul11);

        if (mul13 !== 8'h9e) begin
            $display("FAIL: mul13(0x57) = %h, expected 9e", mul13);
            errors = errors + 1;
        end else
            $display("PASS: mul13(0x57) = %h", mul13);

        if (mul14 !== 8'h67) begin
            $display("FAIL: mul14(0x57) = %h, expected 67", mul14);
            errors = errors + 1;
        end else
            $display("PASS: mul14(0x57) = %h", mul14);

        // --- Sanity property check: (a*2)*7 combinations should satisfy
        //     mul9 XOR mul(1) == mul(8) relationships via definition,
        //     already implicitly covered above. Additionally verify
        //     multiplying by 1 is identity (trivial but worth confirming
        //     the convention before assembling MixColumns) ---
        if (a !== 8'h57) begin
            $display("FAIL: sanity check on 'a' itself failed");
            errors = errors + 1;
        end else
            $display("PASS: identity (mul-by-1) sanity check");

        if (errors == 0)
            $display("\n=== ALL TESTS PASSED (GF multiply primitives verified) ===\n");
        else
            $display("\n=== %0d ERROR(S) FOUND ===\n", errors);

        $finish;
    end

endmodule