// ============================================================
// aes_encrypt.v
// AES-256 encryption core: top-level control FSM
//
// Iterative architecture: one round computed per clock cycle,
// using a single shared round datapath (SubBytes -> ShiftRows
// -> MixColumns -> AddRoundKey), reused 14 times via a round
// counter rather than physically unrolled.
//
// Uses an internal key_expansion instance running FORWARD ONLY
// (direction tied to 0), generating round keys on the fly -
// nothing is precomputed or stored beyond the current 256-bit
// chunk.
//
// Round-to-chunk mapping: round r=2k uses chunk k's UPPER half,
// round r=2k+1 uses chunk k's LOWER half. The chunk advances
// right after finishing an odd round, so the new chunk is ready
// by the time the next (even) round needs it.
// ============================================================
module aes_encrypt (
    input  wire         clk,
    input  wire         rst,         // synchronous, active high
    input  wire         start,       // pulse: begin encryption
    input  wire [127:0] plaintext,
    input  wire [255:0] key,

    output reg  [127:0] ciphertext,
    output reg          done
);

    // --- FSM states ---
    localparam S_IDLE    = 3'd0;
    localparam S_LOAD    = 3'd1;
    localparam S_ADDKEY0 = 3'd2;
    localparam S_ROUND   = 3'd3;
    localparam S_DONE    = 3'd4;

    reg [2:0] state, next_state;

    reg [127:0] state_reg;   // current AES state (128-bit block)
    reg [4:0]   round_num;   // 0 to 14

    // --- Key expansion (forward direction only) ---
    reg         ke_load;
    wire [255:0] chunk_reg;
    wire [3:0]   chunk_idx;

    // ke_advance must be COMBINATIONAL, not registered: it needs to be
    // asserted during the very same cycle round_num is odd, so that
    // key_expansion's own clocked block samples it at the correct edge.
    // (A registered version would add an extra cycle of latency here,
    // since key_expansion itself takes one cycle to act on 'advance'.)
    wire        ke_advance = (state == S_ROUND) && round_num[0];

    key_expansion u_key_expansion (
        .clk(clk),
        .rst(rst),
        .key_in(key),
        .load(ke_load),
        .advance(ke_advance),
        .direction(1'b0),          // always forward in the encrypt core
        .chunk_reg(chunk_reg),
        .chunk_idx(chunk_idx)
    );

    wire [127:0] round_key_upper = chunk_reg[255:128];
    wire [127:0] round_key_lower = chunk_reg[127:0];

    // --- Combinational round datapath ---
    wire [127:0] sub_out, shift_out, mix_out;

    sub_bytes_state u_subbytes ( .state_in(state_reg), .state_out(sub_out) );
    shift_rows      u_shiftrows ( .state_in(sub_out),   .state_out(shift_out) );
    mix_columns     u_mixcolumns( .state_in(shift_out), .state_out(mix_out) );

    // Skip MixColumns on the final round (round 14)
    wire [127:0] pre_addkey = (round_num == 5'd14) ? shift_out : mix_out;

    // Select the correct round key half: odd round -> lower, even -> upper
    wire [127:0] this_round_key = round_num[0] ? round_key_lower : round_key_upper;

    wire [127:0] new_state = pre_addkey ^ this_round_key;

    // --- FSM: state register ---
    always @(posedge clk) begin
        if (rst)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    // --- FSM: next-state logic ---
    always @(*) begin
        next_state = state;
        case (state)
            S_IDLE:    next_state = start ? S_LOAD : S_IDLE;
            S_LOAD:    next_state = S_ADDKEY0;
            S_ADDKEY0: next_state = S_ROUND;
            S_ROUND:   next_state = (round_num == 5'd14) ? S_DONE : S_ROUND;
            S_DONE:    next_state = S_IDLE;
            default:   next_state = S_IDLE;
        endcase
    end

    // --- Datapath and control signal updates ---
    always @(posedge clk) begin
        if (rst) begin
            state_reg  <= 128'd0;
            round_num  <= 5'd0;
            ke_load    <= 1'b0;
            ciphertext <= 128'd0;
            done       <= 1'b0;
        end else begin
            // Default each cycle (pulses unless explicitly set below)
            ke_load    <= 1'b0;
            done       <= 1'b0;

            case (state)
                S_IDLE: begin
                    if (start) begin
                        state_reg <= plaintext;
                        ke_load   <= 1'b1;   // load the key as chunk 0
                        round_num <= 5'd0;
                    end
                end

                S_LOAD: begin
                    // waiting one cycle for key_expansion's load to land
                    // (chunk_reg becomes valid = key on this edge)
                end

                S_ADDKEY0: begin
                    // Initial AddRoundKey: state XOR RoundKey0 (chunk0 upper half)
                    state_reg <= state_reg ^ round_key_upper;
                    round_num <= 5'd1;
                end

                S_ROUND: begin
                    state_reg <= new_state;
                    round_num <= round_num + 5'd1;
                end

                S_DONE: begin
                    ciphertext <= state_reg;
                    done       <= 1'b1;
                end

                default: ;
            endcase
        end
    end

endmodule