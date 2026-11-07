
module decode_stage (

    input wire clk,
    input wire [31:0] instruction,

    // Register writeback interface
    input wire reg_write_wb,
    input wire [4:0] rd_wb,
    input wire [31:0] writeback_data,

    // Register outputs
    output wire [31:0] read_data1,
    output wire [31:0] read_data2,

    // Instruction fields
    output wire [4:0] rs1,
    output wire [4:0] rs2,
    output wire [4:0] rd,

    output wire [2:0] funct3,
    output wire [6:0] funct7,

    // Immediate
    output wire [31:0] immediate,

    // Control signals
    output wire reg_write,
    output wire mem_read,
    output wire mem_write,
    output wire mem_to_reg,
    output wire alu_src,
    output wire branch,
    output wire jump,
    output wire [3:0] alu_control,
    output wire [1:0] imm_type

);

    // Extract instruction fields
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign rd = instruction[11:7];

    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];

    // Register file
    register_file register_file_unit (
        .clk(clk),
        .reg_write(reg_write_wb),
        .read_addr1(rs1),
        .read_addr2(rs2),
        .write_addr(rd_wb),
        .write_data(writeback_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // Immediate generator
    immediate_generator immediate_unit (
        .instruction(instruction),
        .imm_type(imm_type),
        .immediate(immediate)
    );

    // Control unit
    control_unit control_unit_instance (
        .opcode(instruction[6:0]),
        .funct3(funct3),
        .funct7(funct7),

        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .alu_src(alu_src),
        .branch(branch),
        .jump(jump),
        .alu_control(alu_control),
        .imm_type(imm_type)
    );

endmodule
