
module execute_stage (

    input wire [31:0] pc,
    input wire [31:0] read_data1,
    input wire [31:0] read_data2,
    input wire [31:0] immediate,

    // Forwarding inputs
    input wire [31:0] ex_mem_data,
    input wire [31:0] mem_wb_data,

    input wire [1:0] forward_a,
    input wire [1:0] forward_b,

    // Control inputs
    input wire alu_src,
    input wire [3:0] alu_control,
    input wire branch,
    input wire jump,
    input wire [2:0] funct3,

    // Execute outputs
    output wire [31:0] alu_result,
    output wire [31:0] store_data,

    output wire branch_taken,
    output wire [31:0] branch_target,
    output wire [31:0] jump_target

);

    wire [31:0] forwarded_a;
    wire [31:0] forwarded_b;
    wire [31:0] alu_operand_b;

    wire comparator_result;

    // Forwarding MUX for ALU operand A
    forwarding_mux forwarding_mux_a (
        .register_data(read_data1),
        .ex_mem_data(ex_mem_data),
        .mem_wb_data(mem_wb_data),
        .forward_select(forward_a),
        .forwarded_data(forwarded_a)
    );

    // Forwarding MUX for register operand B
    forwarding_mux forwarding_mux_b (
        .register_data(read_data2),
        .ex_mem_data(ex_mem_data),
        .mem_wb_data(mem_wb_data),
        .forward_select(forward_b),
        .forwarded_data(forwarded_b)
    );

    // Select register data or immediate for ALU operand B
    alu_operand_mux operand_mux (
        .forwarded_register_data(forwarded_b),
        .immediate(immediate),
        .alu_src(alu_src),
        .alu_operand(alu_operand_b)
    );

    // Arithmetic and logical operations
    alu execute_alu (
        .a(forwarded_a),
        .b(alu_operand_b),
        .alu_control(alu_control),
        .result(alu_result),
        .zero()
    );

    // Branch comparison uses forwarded register operands
    branch_comparator branch_check (
        .operand_a(forwarded_a),
        .operand_b(forwarded_b),
        .funct3(funct3),
        .branch_taken(comparator_result)
    );

    // A branch is taken only when the instruction is a branch
    assign branch_taken = branch && comparator_result;

    // Branch and JAL targets are relative to the current PC
    assign branch_target = pc + immediate;
    assign jump_target = pc + immediate;

    // Forwarded second register operand is used by SW
    assign store_data = forwarded_b;

endmodule
