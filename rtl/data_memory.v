
module data_memory #(
    parameter MEM_SIZE = 1024
)(
    input  wire        clk,
    input  wire        mem_read,
    input  wire        mem_write,

    input  wire [31:0] address,
    input  wire [31:0] write_data,

    output reg  [31:0] read_data
);

    // Byte-addressable memory
    reg [7:0] memory [0:MEM_SIZE-1];

    integer i;

    // Initialize memory to zero
    initial begin
        for (i = 0; i < MEM_SIZE; i = i + 1) begin
            memory[i] = 8'b0;
        end
    end

    // Synchronous word write
    always @(posedge clk) begin

        if (mem_write &&
            address[1:0] == 2'b00 &&
            address <= MEM_SIZE - 4) begin

            // Little-endian storage
            memory[address]     <= write_data[7:0];
            memory[address + 1] <= write_data[15:8];
            memory[address + 2] <= write_data[23:16];
            memory[address + 3] <= write_data[31:24];

        end

    end

    // Asynchronous word read
    always @(*) begin

        read_data = 32'b0;

        if (mem_read &&
            address[1:0] == 2'b00 &&
            address <= MEM_SIZE - 4) begin

            // Reconstruct word from little-endian bytes
            read_data = {
                memory[address + 3],
                memory[address + 2],
                memory[address + 1],
                memory[address]
            };

        end

    end

endmodule
