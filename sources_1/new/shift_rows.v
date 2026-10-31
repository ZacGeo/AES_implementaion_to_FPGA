// ============================================================
// shift_rows.v
// AES ShiftRows transformation
//
// State is a 4x4 byte array, filled column-by-column from the
// 128-bit input (byte0 = MSB). Each row is cyclically shifted
// LEFT by its row index:
//   Row 0: no shift
//   Row 1: shift left 1
//   Row 2: shift left 2
//   Row 3: shift left 3
//
// Purely combinational - just byte rewiring, no logic gates.
// ============================================================
module shift_rows (
    input  wire [127:0] state_in,
    output wire [127:0] state_out
);

    // Split input into 16 individual bytes (byte0 = MSB)
    wire [7:0] b0,  b1,  b2,  b3,  b4,  b5,  b6,  b7;
    wire [7:0] b8,  b9,  b10, b11, b12, b13, b14, b15;

    assign b0  = state_in[127:120];
    assign b1  = state_in[119:112];
    assign b2  = state_in[111:104];
    assign b3  = state_in[103:96];
    assign b4  = state_in[95:88];
    assign b5  = state_in[87:80];
    assign b6  = state_in[79:72];
    assign b7  = state_in[71:64];
    assign b8  = state_in[63:56];
    assign b9  = state_in[55:48];
    assign b10 = state_in[47:40];
    assign b11 = state_in[39:32];
    assign b12 = state_in[31:24];
    assign b13 = state_in[23:16];
    assign b14 = state_in[15:8];
    assign b15 = state_in[7:0];

    // State layout (row, col) -> byte index:
    //   Row0: b0  b4  b8  b12
    //   Row1: b1  b5  b9  b13
    //   Row2: b2  b6  b10 b14
    //   Row3: b3  b7  b11 b15
    //
    // After ShiftRows (each row shifted left by its row index):
    //   Row0: b0  b4  b8  b12   (unchanged)
    //   Row1: b5  b9  b13 b1    (shift left 1)
    //   Row2: b10 b14 b2  b6    (shift left 2)
    //   Row3: b15 b3  b7  b11   (shift left 3)

    assign state_out = { b0, b5, b10, b15,   // new column 0
                          b4, b9, b14, b3,    // new column 1
                          b8, b13, b2, b7,    // new column 2
                          b12, b1, b6, b11 }; // new column 3

endmodule