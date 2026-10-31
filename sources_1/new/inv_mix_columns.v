// ============================================================
// inv_mix_columns.v
// AES InvMixColumns transformation (decrypt direction)
//
// Splits the 128-bit state into its 4 columns and applies
// inv_mix_single_column to each independently.
// ============================================================
module inv_mix_columns (
    input  wire [127:0] state_in,
    output wire [127:0] state_out
);

    wire [31:0] col0_in, col1_in, col2_in, col3_in;
    assign col0_in = state_in[127:96];
    assign col1_in = state_in[95:64];
    assign col2_in = state_in[63:32];
    assign col3_in = state_in[31:0];

    wire [31:0] col0_out, col1_out, col2_out, col3_out;

    inv_mix_single_column u0 ( .col_in(col0_in), .col_out(col0_out) );
    inv_mix_single_column u1 ( .col_in(col1_in), .col_out(col1_out) );
    inv_mix_single_column u2 ( .col_in(col2_in), .col_out(col2_out) );
    inv_mix_single_column u3 ( .col_in(col3_in), .col_out(col3_out) );

    assign state_out = { col0_out, col1_out, col2_out, col3_out };

endmodule