
module register_writeback (
    input wire clk,
    input wire reset,

    input wire reg_write,
    input wire [4:0] rd,
    input wire [31:0] writeback_data,

    output wire [31:0] register_data
);

    assign register_data = writeback_data;

    // This module provides the writeback interface.
    // The register file connection will be made
    // in the processor top-level module.

endmodule
