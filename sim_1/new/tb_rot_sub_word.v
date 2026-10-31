// ============================================================
// tb_rot_sub_word.v
// Testbench for rot_word.v and sub_word.v
// Uses the official FIPS-197 AES-128 key expansion worked
// example: for key 2b7e151628aed2a6abf7158809cf4f3c,
// w[3] = 09cf4f3c
//   RotWord(09cf4f3c) = cf4f3c09
//   SubWord(cf4f3c09) = 8a84eb01
// ============================================================
`timescale 1ns/1ps

module tb_rot_sub_word;

    reg  [31:0] rot_in;
    wire [31:0] rot_out;

    reg  [31:0] sub_in;
    wire [31:0] sub_out;

    integer errors;

    rot_word u_rot_word (
        .word_in(rot_in),
        .word_out(rot_out)
    );

    sub_word u_sub_word (
        .word_in(sub_in),
        .word_out(sub_out)
    );

    initial begin
        errors = 0;

        rot_in = 32'h09cf4f3c;
        #10;
        if (rot_out !== 32'hcf4f3c09) begin
            $display("FAIL: RotWord(09cf4f3c) = %h, expected cf4f3c09", rot_out);
            errors = errors + 1;
        end else
            $display("PASS: RotWord(09cf4f3c) = %h", rot_out);

        sub_in = 32'hcf4f3c09;
        #10;
        if (sub_out !== 32'h8a84eb01) begin
            $display("FAIL: SubWord(cf4f3c09) = %h, expected 8a84eb01", sub_out);
            errors = errors + 1;
        end else
            $display("PASS: SubWord(cf4f3c09) = %h", sub_out);

        rot_in = 32'h09cf4f3c;
        #10;
        sub_in = rot_out;
        #10;
        if (sub_out !== 32'h8a84eb01) begin
            $display("FAIL: SubWord(RotWord(09cf4f3c)) = %h, expected 8a84eb01", sub_out);
            errors = errors + 1;
        end else
            $display("PASS: SubWord(RotWord(09cf4f3c)) = %h", sub_out);

        if (errors == 0)
            $display("\n=== ALL TESTS PASSED ===\n");
        else
            $display("\n=== %0d ERROR(S) FOUND ===\n", errors);

        $finish;
    end

endmodule