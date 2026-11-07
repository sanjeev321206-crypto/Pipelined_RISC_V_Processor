
module id_ex_register (
    input wire clk,
    input wire reset,
    input wire flush,

    // Data inputs
    input wire [31:0] pc_in,
    input wire [31:0] pc_plus4_in,
    input wire [31:0] read_data1_in,
    input wire [31:0] read_data2_in,
    input wire [31:0] immediate_in,

    // Register addresses
    input wire [4:0] rs1_in,
    input wire [4:0] rs2_in,
    input wire [4:0] rd_in,

    // Instruction function fields
    input wire [2:0] funct3_in,
    input wire [6:0] funct7_in,

    // Control inputs
    input wire reg_write_in,
    input wire mem_read_in,
    input wire mem_write_in,
    input wire mem_to_reg_in,
    input wire alu_src_in,
    input wire branch_in,
    input wire jump_in,
    input wire [3:0] alu_control_in,

    // Data outputs
    output reg [31:0] pc_out,
    output reg [31:0] pc_plus4_out,
    output reg [31:0] read_data1_out,
    output reg [31:0] read_data2_out,
    output reg [31:0] immediate_out,

    // Register address outputs
    output reg [4:0] rs1_out,
    output reg [4:0] rs2_out,
    output reg [4:0] rd_out,

    // Instruction function outputs
    output reg [2:0] funct3_out,
    output reg [6:0] funct7_out,

    // Control outputs
    output reg reg_write_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg mem_to_reg_out,
    output reg alu_src_out,
    output reg branch_out,
    output reg jump_out,
    output reg [3:0] alu_control_out
);

    always @(posedge clk) begin

        if (reset || flush) begin

            // Clear data fields
            pc_out          <= 32'b0;
            pc_plus4_out    <= 32'b0;
            read_data1_out  <= 32'b0;
            read_data2_out  <= 32'b0;
            immediate_out   <= 32'b0;

            // Clear register addresses
            rs1_out         <= 5'b0;
            rs2_out         <= 5'b0;
            rd_out          <= 5'b0;

            // Clear instruction function fields
            funct3_out      <= 3'b0;
            funct7_out      <= 7'b0;

            // Clear control signals
            reg_write_out   <= 1'b0;
            mem_read_out    <= 1'b0;
            mem_write_out   <= 1'b0;
            mem_to_reg_out  <= 1'b0;
            alu_src_out     <= 1'b0;
            branch_out      <= 1'b0;
            jump_out        <= 1'b0;
            alu_control_out <= 4'b0;

        end

        else begin

            // Transfer data
            pc_out          <= pc_in;
            pc_plus4_out    <= pc_plus4_in;
            read_data1_out  <= read_data1_in;
            read_data2_out  <= read_data2_in;
            immediate_out   <= immediate_in;

            // Transfer register addresses
            rs1_out         <= rs1_in;
            rs2_out         <= rs2_in;
            rd_out          <= rd_in;

            // Transfer instruction function fields
            funct3_out      <= funct3_in;
            funct7_out      <= funct7_in;

            // Transfer control signals
            reg_write_out   <= reg_write_in;
            mem_read_out    <= mem_read_in;
            mem_write_out   <= mem_write_in;
            mem_to_reg_out  <= mem_to_reg_in;
            alu_src_out     <= alu_src_in;
            branch_out      <= branch_in;
            jump_out        <= jump_in;
            alu_control_out <= alu_control_in;

        end

    end

endmodule
