
module memory_stage (
    input wire clk,

    input wire [31:0] alu_result,
    input wire [31:0] store_data,

    input wire mem_read,
    input wire mem_write,

    output wire [31:0] memory_data
);

    data_memory #(
        .MEM_SIZE(1024)
    ) data_memory_unit (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(alu_result),
        .write_data(store_data),
        .read_data(memory_data)
    );

endmodule
