`timescale 1ns / 1ps

// ============================================================
// AES-256 FPGA WRAPPER
//
// Wrapper for the aes256_top core.
//
// The AES core internally still uses:
//   data_in  = 128 bits
//   key      = 256 bits
//   data_out = 128 bits
//
// However, data/key are loaded through an 8-bit external bus
// in order to drastically reduce the number of FPGA I/O pins.
//
// BYTE ORDER:
// First byte loaded = most significant byte.
//
// Example plaintext:
// 00112233445566778899aabbccddeeff
//
// Must be loaded as:
// 00, 11, 22, 33, 44, 55, 66, 77,
// 88, 99, aa, bb, cc, dd, ee, ff
//
// mode = 0 -> Encryption
// mode = 1 -> Decryption
// ============================================================

module aes256_fpga_top (

    // --------------------------------------------------------
    // Clock / reset
    // --------------------------------------------------------
    input  wire       clk,
    input  wire       rst,

    // --------------------------------------------------------
    // 8-bit input interface
    // --------------------------------------------------------
    input  wire [7:0] byte_in,

    // Pulse load_data once for every data byte
    input  wire       load_data,

    // Pulse load_key once for every key byte
    input  wire       load_key,

    // Start AES operation
    input  wire       start,

    // 0 = encrypt
    // 1 = decrypt
    input  wire       mode,

    // --------------------------------------------------------
    // 8-bit output interface
    // --------------------------------------------------------
    output wire [7:0] byte_out,

    // Advance to next output byte
    input  wire       read_next,

    // --------------------------------------------------------
    // Status outputs
    // --------------------------------------------------------
    output wire       done,
    output wire       busy,

    output reg        data_ready,
    output reg        key_ready,
    output reg        result_valid
);


    // ========================================================
    // INTERNAL REGISTERS
    // ========================================================

    // Complete 128-bit AES input block
    reg [127:0] data_reg;

    // Complete AES-256 key
    reg [255:0] key_reg;

    // AES result
    reg [127:0] result_reg;


    // --------------------------------------------------------
    // Counters
    // --------------------------------------------------------

    // 0...16
    reg [4:0] data_count;

    // 0...32
    reg [5:0] key_count;

    // 0...15
    reg [3:0] output_count;


    // ========================================================
    // AES CORE CONNECTIONS
    // ========================================================

    wire [127:0] core_data_out;
    wire         core_done;
    wire         core_busy;

    /*
     * Start is forwarded to the AES core only when:
     *
     * 1. 128-bit input has been completely loaded
     * 2. 256-bit key has been completely loaded
     * 3. AES core is not already busy
     */
    wire core_start;

    assign core_start =
        start &&
        data_ready &&
        key_ready &&
        !core_busy;


    // ========================================================
    // AES-256 CORE
    // ========================================================

    aes256_top u_aes256_core (

        .clk      (clk),
        .rst      (rst),

        .start    (core_start),
        .mode     (mode),

        .data_in  (data_reg),
        .key      (key_reg),

        .data_out (core_data_out),

        .done     (core_done),
        .busy     (core_busy)
    );


    // Forward status signals
    assign done = core_done;
    assign busy = core_busy;


    // ========================================================
    // BYTE OUTPUT
    // ========================================================

    /*
     * Output is also read MSB first.
     *
     * output_count = 0  -> bits 127:120
     * output_count = 1  -> bits 119:112
     * ...
     * output_count = 15 -> bits 7:0
     */

    assign byte_out =
        result_reg[127 - (output_count * 8) -: 8];


    // ========================================================
    // INPUT / OUTPUT CONTROL
    // ========================================================

    always @(posedge clk) begin

        if (rst) begin

            data_reg      <= 128'd0;
            key_reg       <= 256'd0;
            result_reg    <= 128'd0;

            data_count    <= 5'd0;
            key_count     <= 6'd0;
            output_count  <= 4'd0;

            data_ready    <= 1'b0;
            key_ready     <= 1'b0;
            result_valid  <= 1'b0;

        end

        else begin

            // =================================================
            // LOAD 128-BIT INPUT DATA
            // =================================================

            if (load_data) begin

                /*
                 * If one complete block was already loaded,
                 * begin loading a new block.
                 */
                if (data_count >= 5'd16) begin

                    data_reg[127:120] <= byte_in;

                    data_count <= 5'd1;
                    data_ready <= 1'b0;

                end

                else begin

                    /*
                     * Load bytes MSB first.
                     */
                    data_reg[
                        127 - (data_count * 8) -: 8
                    ] <= byte_in;


                    /*
                     * Byte number 15 is the final byte.
                     */
                    if (data_count == 5'd15) begin

                        data_count <= 5'd16;
                        data_ready <= 1'b1;

                    end

                    else begin

                        data_count <= data_count + 5'd1;

                    end

                end

            end


            // =================================================
            // LOAD 256-BIT KEY
            // =================================================

            if (load_key) begin

                /*
                 * If a complete key was previously loaded,
                 * begin loading a new key.
                 */
                if (key_count >= 6'd32) begin

                    key_reg[255:248] <= byte_in;

                    key_count <= 6'd1;
                    key_ready <= 1'b0;

                end

                else begin

                    /*
                     * Load key MSB first.
                     */
                    key_reg[
                        255 - (key_count * 8) -: 8
                    ] <= byte_in;


                    /*
                     * Byte number 31 is the final key byte.
                     */
                    if (key_count == 6'd31) begin

                        key_count <= 6'd32;
                        key_ready <= 1'b1;

                    end

                    else begin

                        key_count <= key_count + 6'd1;

                    end

                end

            end


            // =================================================
            // AES OPERATION STARTED
            // =================================================

            if (core_start) begin

                /*
                 * Old result is no longer considered valid.
                 */
                result_valid <= 1'b0;

                /*
                 * Reset output pointer.
                 */
                output_count <= 4'd0;

            end


            // =================================================
            // AES OPERATION FINISHED
            // =================================================

            if (core_done) begin

                /*
                 * Store complete 128-bit AES result.
                 */
                result_reg <= core_data_out;

                result_valid <= 1'b1;

                /*
                 * Begin output from first byte.
                 */
                output_count <= 4'd0;

            end


            // =================================================
            // READ NEXT OUTPUT BYTE
            // =================================================

            if (read_next && result_valid) begin

                if (output_count < 4'd15)
                    output_count <= output_count + 4'd1;

            end

        end

    end


endmodule