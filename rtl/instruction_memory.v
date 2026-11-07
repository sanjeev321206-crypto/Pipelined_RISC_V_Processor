
module instruction_memory #(
    parameter DEPTH = 256
)(
    input  wire [31:0] address,
    output reg  [31:0] instruction
);

    // Instruction memory: 256 words, 32 bits each
    reg [31:0] memory [0:DEPTH-1];

    integer i;

    // Initialize memory with NOP instructions
    initial begin

        for (i = 0; i < DEPTH; i = i + 1) begin
            memory[i] = 32'h00000013;
        end

        // Initial test program
        memory[0] = 32'h00A00093; // ADDI x1, x0, 10
        memory[1] = 32'h01400113; // ADDI x2, x0, 20
        memory[2] = 32'h002081B3; // ADD  x3, x1, x2
        memory[3] = 32'h00302023; // SW   x3, 0(x0)
        memory[4] = 32'h00002203; // LW   x4, 0(x0)

    end

    // Asynchronous instruction fetch
    always @(*) begin

        if (address[1:0] == 2'b00 &&
            address[31:2] < DEPTH)
            instruction = memory[address[31:2]];

        else
            instruction = 32'h00000013;

    end

endmodule
