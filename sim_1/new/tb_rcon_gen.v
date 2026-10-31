// ============================================================
// tb_rcon_gen.v
// Testbench for rcon_gen.v
// Verifies the standard AES Rcon sequence: 01,02,04,08,10,20,40
// (the 7 values AES-256 key expansion actually uses)
// ============================================================
`timescale 1ns/1ps

module tb_rcon_gen;

    reg  [3:0]  round_num;
    wire [7:0]  rcon_byte;
    wire [31:0] rcon_word;

    integer errors;
    integer i;

    reg [7:0] expected [1:7];

    rcon_gen u_rcon_gen (
        .round_num(round_num),
        .rcon_byte(rcon_byte),
        .rcon_word(rcon_word)
    );

    initial begin
        errors = 0;

        expected[1] = 8'h01;
        expected[2] = 8'h02;
        expected[3] = 8'h04;
        expected[4] = 8'h08;
        expected[5] = 8'h10;
        expected[6] = 8'h20;
        expected[7] = 8'h40;

        for (i = 1; i <= 7; i = i + 1) begin
            round_num = i[3:0];
            #10;

            if (rcon_byte !== expected[i]) begin
                $display("FAIL: Rcon[%0d] byte = %h, expected %h", i, rcon_byte, expected[i]);
                errors = errors + 1;
            end else
                $display("PASS: Rcon[%0d] byte = %h", i, rcon_byte);

            if (rcon_word !== {expected[i], 24'h000000}) begin
                $display("FAIL: Rcon[%0d] word = %h, expected %h", i, rcon_word, {expected[i], 24'h000000});
                errors = errors + 1;
            end else
                $display("PASS: Rcon[%0d] word = %h", i, rcon_word);
        end

        if (errors == 0)
            $display("\n=== ALL TESTS PASSED (Rcon sequence 1-7 verified) ===\n");
        else
            $display("\n=== %0d ERROR(S) FOUND ===\n", errors);

        $finish;
    end

endmodule