// ============================================================
// sub_bytes_state.v
// AES SubBytes transformation for the full 128-bit state.
// Byte 0 is state_in[127:120]. Purely combinational.
// ============================================================
module sub_bytes_state (
    input  wire [127:0] state_in,
    output wire [127:0] state_out
);
    wire [7:0] b0,  b1,  b2,  b3;
    wire [7:0] b4,  b5,  b6,  b7;
    wire [7:0] b8,  b9,  b10, b11;
    wire [7:0] b12, b13, b14, b15;

    sbox u0  (.addr(state_in[127:120]), .data(b0));
    sbox u1  (.addr(state_in[119:112]), .data(b1));
    sbox u2  (.addr(state_in[111:104]), .data(b2));
    sbox u3  (.addr(state_in[103:96]),  .data(b3));
    sbox u4  (.addr(state_in[95:88]),   .data(b4));
    sbox u5  (.addr(state_in[87:80]),   .data(b5));
    sbox u6  (.addr(state_in[79:72]),   .data(b6));
    sbox u7  (.addr(state_in[71:64]),   .data(b7));
    sbox u8  (.addr(state_in[63:56]),   .data(b8));
    sbox u9  (.addr(state_in[55:48]),   .data(b9));
    sbox u10 (.addr(state_in[47:40]),   .data(b10));
    sbox u11 (.addr(state_in[39:32]),   .data(b11));
    sbox u12 (.addr(state_in[31:24]),   .data(b12));
    sbox u13 (.addr(state_in[23:16]),   .data(b13));
    sbox u14 (.addr(state_in[15:8]),    .data(b14));
    sbox u15 (.addr(state_in[7:0]),     .data(b15));

    assign state_out = {
        b0, b1, b2, b3,
        b4, b5, b6, b7,
        b8, b9, b10, b11,
        b12, b13, b14, b15
    };
endmodule
