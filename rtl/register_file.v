
module register_file (
    input wire clk,
    input wire reg_write,

    input wire [4:0] read_addr1,
    input wire [4:0] read_addr2,
    input wire [4:0] write_addr,

    input wire [31:0] write_data,

    output wire [31:0] read_data1,
    output wire [31:0] read_data2
);

    // 32 registers, each 32 bits wide
    reg [31:0] registers [0:31];

    integer i;

    // Initialize all registers to zero
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'b0;
        end
    end

    // Synchronous register write
    always @(posedge clk) begin
        if (reg_write && write_addr != 5'd0) begin
            registers[write_addr] <= write_data;
        end
    end

    // Asynchronous reads with writeback bypass
    assign read_data1 =
        (read_addr1 == 5'd0) ? 32'b0 :
        (reg_write && write_addr != 5'd0 &&
         write_addr == read_addr1) ? write_data :
        registers[read_addr1];

    assign read_data2 =
        (read_addr2 == 5'd0) ? 32'b0 :
        (reg_write && write_addr != 5'd0 &&
         write_addr == read_addr2) ? write_data :
        registers[read_addr2];

endmodule
