
module writeback_mux (
    input wire [31:0] alu_result,
    input wire [31:0] memory_data,
    input wire [31:0] pc_plus4,
    
    input wire mem_to_reg,
    input wire jump,

    output reg [31:0] writeback_data
);

    always @(*) begin

        // JAL has priority: write PC + 4
        if (jump)
            writeback_data = pc_plus4;

        // Load instruction: write memory data
        else if (mem_to_reg)
            writeback_data = memory_data;

        // Otherwise: write ALU result
        else
            writeback_data = alu_result;

    end

endmodule
