// ============================================================
// rcon_gen.v
// AES key expansion helper: Rcon (round constant) generator
// AES-256 only ever needs indices 1 through 7 (one per 256-bit
// "chunk" boundary in the key schedule). Pure lookup table,
// combinational, no clock needed.
// ============================================================
module rcon_gen (
    input  wire [3:0]  round_num,   // valid range: 1 to 7
    output reg  [7:0]  rcon_byte,   // the round constant byte
    output wire [31:0] rcon_word    // padded to a full word: {rcon_byte,00,00,00}
);

    always @(*) begin
        case (round_num)
            4'd1: rcon_byte = 8'h01;
            4'd2: rcon_byte = 8'h02;
            4'd3: rcon_byte = 8'h04;
            4'd4: rcon_byte = 8'h08;
            4'd5: rcon_byte = 8'h10;
            4'd6: rcon_byte = 8'h20;
            4'd7: rcon_byte = 8'h40;
            default: rcon_byte = 8'h00; // not used for AES-256, safe fallback
        endcase
    end

    assign rcon_word = { rcon_byte, 24'h000000 };

endmodule