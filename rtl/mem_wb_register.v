
module mem_wb_register (
    input wire clk,
    input wire reset,
    input wire flush,

    // Data inputs
    input wire [31:0] alu_result_in,
    input wire [31:0] memory_data_in,
    input wire [31:0] pc_plus4_in,

    // Destination register
    input wire [4:0] rd_in,

    // Control inputs
    input wire reg_write_in,
    input wire mem_to_reg_in,
    input wire jump_in,

    // Data outputs
    output reg [31:0] alu_result_out,
    output reg [31:0] memory_data_out,
    output reg [31:0] pc_plus4_out,

    // Destination register
    output reg [4:0] rd_out,

    // Control outputs
    output reg reg_write_out,
    output reg mem_to_reg_out,
    output reg jump_out
);

    always @(posedge clk) begin

        if (reset || flush) begin

            // Clear data fields
            alu_result_out  <= 32'b0;
            memory_data_out <= 32'b0;
            pc_plus4_out    <= 32'b0;

            // Clear destination register
            rd_out <= 5'b0;

            // Clear control signals
            reg_write_out  <= 1'b0;
            mem_to_reg_out <= 1'b0;
            jump_out       <= 1'b0;

        end

        else begin

            // Transfer data
            alu_result_out  <= alu_result_in;
            memory_data_out <= memory_data_in;
            pc_plus4_out    <= pc_plus4_in;

            // Transfer destination register
            rd_out <= rd_in;

            // Transfer control signals
            reg_write_out  <= reg_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            jump_out       <= jump_in;

        end

    end

endmodule
