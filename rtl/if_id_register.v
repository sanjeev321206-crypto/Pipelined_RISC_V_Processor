
module if_id_register (
    input  wire        clk,
    input  wire        reset,
    input  wire        stall,
    input  wire        flush,

    input  wire [31:0] pc_in,
    input  wire [31:0] pc_plus4_in,
    input  wire [31:0] instruction_in,

    output reg  [31:0] pc_out,
    output reg  [31:0] pc_plus4_out,
    output reg  [31:0] instruction_out
);

    // NOP instruction: ADDI x0, x0, 0
    localparam NOP = 32'h00000013;

    always @(posedge clk) begin

        if (reset) begin
            pc_out          <= 32'b0;
            pc_plus4_out    <= 32'b0;
            instruction_out <= NOP;
        end

        else if (flush) begin
            pc_out          <= 32'b0;
            pc_plus4_out    <= 32'b0;
            instruction_out <= NOP;
        end

        else if (!stall) begin
            pc_out          <= pc_in;
            pc_plus4_out    <= pc_plus4_in;
            instruction_out <= instruction_in;
        end

        // When stalled, retain previous values.

    end

endmodule
