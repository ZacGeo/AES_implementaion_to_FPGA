// ============================================================
// inv_sub_bytes_state.v
// AES InvSubBytes transformation, full 128-bit state
// (decryption). Same structure as sub_bytes_state.v, using
// inv_sbox instead of sbox.
// ============================================================
module inv_sub_bytes_state (
    input  wire [127:0] state_in,
    output wire [127:0] state_out
);

    wire [7:0] b_in  [0:15];
    wire [7:0] b_out [0:15];

    assign b_in[0]  = state_in[127:120];
    assign b_in[1]  = state_in[119:112];
    assign b_in[2]  = state_in[111:104];
    assign b_in[3]  = state_in[103:96];
    assign b_in[4]  = state_in[95:88];
    assign b_in[5]  = state_in[87:80];
    assign b_in[6]  = state_in[79:72];
    assign b_in[7]  = state_in[71:64];
    assign b_in[8]  = state_in[63:56];
    assign b_in[9]  = state_in[55:48];
    assign b_in[10] = state_in[47:40];
    assign b_in[11] = state_in[39:32];
    assign b_in[12] = state_in[31:24];
    assign b_in[13] = state_in[23:16];
    assign b_in[14] = state_in[15:8];
    assign b_in[15] = state_in[7:0];

    inv_sbox u0  ( .addr(b_in[0]),  .data(b_out[0])  );
    inv_sbox u1  ( .addr(b_in[1]),  .data(b_out[1])  );
    inv_sbox u2  ( .addr(b_in[2]),  .data(b_out[2])  );
    inv_sbox u3  ( .addr(b_in[3]),  .data(b_out[3])  );
    inv_sbox u4  ( .addr(b_in[4]),  .data(b_out[4])  );
    inv_sbox u5  ( .addr(b_in[5]),  .data(b_out[5])  );
    inv_sbox u6  ( .addr(b_in[6]),  .data(b_out[6])  );
    inv_sbox u7  ( .addr(b_in[7]),  .data(b_out[7])  );
    inv_sbox u8  ( .addr(b_in[8]),  .data(b_out[8])  );
    inv_sbox u9  ( .addr(b_in[9]),  .data(b_out[9])  );
    inv_sbox u10 ( .addr(b_in[10]), .data(b_out[10]) );
    inv_sbox u11 ( .addr(b_in[11]), .data(b_out[11]) );
    inv_sbox u12 ( .addr(b_in[12]), .data(b_out[12]) );
    inv_sbox u13 ( .addr(b_in[13]), .data(b_out[13]) );
    inv_sbox u14 ( .addr(b_in[14]), .data(b_out[14]) );
    inv_sbox u15 ( .addr(b_in[15]), .data(b_out[15]) );

    assign state_out = { b_out[0],  b_out[1],  b_out[2],  b_out[3],
                          b_out[4],  b_out[5],  b_out[6],  b_out[7],
                          b_out[8],  b_out[9],  b_out[10], b_out[11],
                          b_out[12], b_out[13], b_out[14], b_out[15] };

endmodule