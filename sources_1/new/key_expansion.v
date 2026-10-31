// ============================================================
// key_expansion.v
// Sequential AES-256 key-schedule wrapper.
//
// load=1:    chunk_reg <= key_in, chunk_idx <= 0
// advance=1: direction=0 -> next chunk
//            direction=1 -> previous chunk
//
// For encryption, aes_encrypt ties direction to 0.
// ============================================================
module key_expansion (
    input  wire         clk,
    input  wire         rst,
    input  wire [255:0] key_in,
    input  wire         load,
    input  wire         advance,
    input  wire         direction,
    output reg  [255:0] chunk_reg,
    output reg  [3:0]   chunk_idx
);
    wire [3:0] next_round_num = chunk_idx + 4'd1;

    wire [255:0] next_chunk;
    wire [255:0] prev_chunk;

    key_expansion_next_chunk u_next (
        .chunk_in(chunk_reg),
        .round_num(next_round_num),
        .chunk_out(next_chunk)
    );

    key_expansion_prev_chunk u_prev (
        .chunk_in(chunk_reg),
        .round_num(chunk_idx),
        .chunk_out(prev_chunk)
    );

    always @(posedge clk) begin
        if (rst) begin
            chunk_reg <= 256'd0;
            chunk_idx <= 4'd0;
        end else if (load) begin
            chunk_reg <= key_in;
            chunk_idx <= 4'd0;
        end else if (advance) begin
            if (!direction) begin
                if (chunk_idx < 4'd7) begin
                    chunk_reg <= next_chunk;
                    chunk_idx <= chunk_idx + 4'd1;
                end
            end else begin
                if (chunk_idx > 4'd0) begin
                    chunk_reg <= prev_chunk;
                    chunk_idx <= chunk_idx - 4'd1;
                end
            end
        end
    end
endmodule
