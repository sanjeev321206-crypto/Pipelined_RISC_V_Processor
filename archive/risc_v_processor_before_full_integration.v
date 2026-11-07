
module risc_v_processor (
    input wire clk,
    input wire reset
);

    // ==========================================
    // PIPELINE CONTROL
    // ==========================================

    wire stall;
    wire flush;
    wire redirect;

    wire [31:0] redirect_pc;

    assign stall = 1'b0;

    // Branch/jump redirect flushes younger instructions.
    assign flush = redirect;

    // ==========================================
    // FETCH STAGE SIGNALS
    // ==========================================

    wire [31:0] fetch_pc;
    wire [31:0] fetch_pc_plus4;
    wire [31:0] fetch_instruction;

    // ==========================================
    // DECODE STAGE SIGNALS
    // ==========================================

    wire [31:0] decode_read_data1;
    wire [31:0] decode_read_data2;

    wire [4:0] decode_rs1;
    wire [4:0] decode_rs2;
    wire [4:0] decode_rd;

    wire [2:0] decode_funct3;
    wire [6:0] decode_funct7;
    wire [31:0] decode_immediate;

    wire decode_reg_write;
    wire decode_mem_read;
    wire decode_mem_write;
    wire decode_mem_to_reg;
    wire decode_alu_src;
    wire decode_branch;
    wire decode_jump;

    wire [3:0] decode_alu_control;
    wire [1:0] decode_imm_type;

    // Temporary writeback signals.
    // These will be connected to MEM/WB later.
    wire [31:0] writeback_data;
    wire [4:0] writeback_rd;
    wire writeback_reg_write;

    assign writeback_data = 32'b0;
    assign writeback_rd = 5'b0;
    assign writeback_reg_write = 1'b0;

    // ==========================================
    // ID/EX PIPELINE REGISTER OUTPUTS
    // ==========================================

    wire [31:0] ex_pc;
    wire [31:0] ex_pc_plus4;
    wire [31:0] ex_read_data1;
    wire [31:0] ex_read_data2;
    wire [31:0] ex_immediate;

    wire [4:0] ex_rs1;
    wire [4:0] ex_rs2;
    wire [4:0] ex_rd;

    wire [2:0] ex_funct3;
    wire [6:0] ex_funct7;

    wire ex_reg_write;
    wire ex_mem_read;
    wire ex_mem_write;
    wire ex_mem_to_reg;
    wire ex_alu_src;
    wire ex_branch;
    wire ex_jump;

    wire [3:0] ex_alu_control;

    // ==========================================
    // EXECUTE STAGE SIGNALS
    // ==========================================

    wire [31:0] ex_alu_result;
    wire [31:0] ex_store_data;

    wire ex_branch_taken;
    wire [31:0] ex_branch_target;
    wire [31:0] ex_jump_target;

    // Forwarding controls
    wire [1:0] forward_a;
    wire [1:0] forward_b;

    // Temporary forwarding data.
    // Will be connected to EX/MEM and MEM/WB.
    wire [31:0] ex_mem_forward_data;
    wire [31:0] mem_wb_forward_data;

    wire [4:0] ex_mem_forward_rd;
    wire [4:0] mem_wb_forward_rd;

    wire ex_mem_forward_write;
    wire mem_wb_forward_write;

    assign ex_mem_forward_data = 32'b0;
    assign mem_wb_forward_data = 32'b0;

    assign ex_mem_forward_rd = 5'b0;
    assign mem_wb_forward_rd = 5'b0;

    assign ex_mem_forward_write = 1'b0;
    assign mem_wb_forward_write = 1'b0;

    // ==========================================
    // FETCH STAGE
    // ==========================================

    fetch_stage fetch_unit (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .flush(flush),
        .redirect_pc(redirect_pc),
        .redirect(redirect),

        .pc_out(fetch_pc),
        .pc_plus4_out(fetch_pc_plus4),
        .instruction_out(fetch_instruction)
    );

    // ==========================================
    // DECODE STAGE
    // ==========================================

    decode_stage decode_unit (
        .clk(clk),
        .instruction(fetch_instruction),

        .reg_write_wb(writeback_reg_write),
        .rd_wb(writeback_rd),
        .writeback_data(writeback_data),

        .read_data1(decode_read_data1),
        .read_data2(decode_read_data2),

        .rs1(decode_rs1),
        .rs2(decode_rs2),
        .rd(decode_rd),

        .funct3(decode_funct3),
        .funct7(decode_funct7),
        .immediate(decode_immediate),

        .reg_write(decode_reg_write),
        .mem_read(decode_mem_read),
        .mem_write(decode_mem_write),
        .mem_to_reg(decode_mem_to_reg),
        .alu_src(decode_alu_src),
        .branch(decode_branch),
        .jump(decode_jump),

        .alu_control(decode_alu_control),
        .imm_type(decode_imm_type)
    );

    // ==========================================
    // ID/EX PIPELINE REGISTER
    // ==========================================

    id_ex_register id_ex_unit (
        .clk(clk),
        .reset(reset),
        .flush(flush),

        .pc_in(fetch_pc),
        .pc_plus4_in(fetch_pc_plus4),

        .read_data1_in(decode_read_data1),
        .read_data2_in(decode_read_data2),
        .immediate_in(decode_immediate),

        .rs1_in(decode_rs1),
        .rs2_in(decode_rs2),
        .rd_in(decode_rd),

        .funct3_in(decode_funct3),
        .funct7_in(decode_funct7),

        .reg_write_in(decode_reg_write),
        .mem_read_in(decode_mem_read),
        .mem_write_in(decode_mem_write),
        .mem_to_reg_in(decode_mem_to_reg),
        .alu_src_in(decode_alu_src),
        .branch_in(decode_branch),
        .jump_in(decode_jump),
        .alu_control_in(decode_alu_control),

        .pc_out(ex_pc),
        .pc_plus4_out(ex_pc_plus4),

        .read_data1_out(ex_read_data1),
        .read_data2_out(ex_read_data2),
        .immediate_out(ex_immediate),

        .rs1_out(ex_rs1),
        .rs2_out(ex_rs2),
        .rd_out(ex_rd),

        .funct3_out(ex_funct3),
        .funct7_out(ex_funct7),

        .reg_write_out(ex_reg_write),
        .mem_read_out(ex_mem_read),
        .mem_write_out(ex_mem_write),
        .mem_to_reg_out(ex_mem_to_reg),
        .alu_src_out(ex_alu_src),
        .branch_out(ex_branch),
        .jump_out(ex_jump),
        .alu_control_out(ex_alu_control)
    );

    // ==========================================
    // FORWARDING UNIT
    // ==========================================

    forwarding_unit forwarding_unit_instance (
        .id_ex_rs1(ex_rs1),
        .id_ex_rs2(ex_rs2),

        .ex_mem_rd(ex_mem_forward_rd),
        .ex_mem_reg_write(ex_mem_forward_write),

        .mem_wb_rd(mem_wb_forward_rd),
        .mem_wb_reg_write(mem_wb_forward_write),

        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    // ==========================================
    // EXECUTE STAGE
    // ==========================================

    execute_stage execute_unit (
        .pc(ex_pc),

        .read_data1(ex_read_data1),
        .read_data2(ex_read_data2),
        .immediate(ex_immediate),

        .ex_mem_data(ex_mem_forward_data),
        .mem_wb_data(mem_wb_forward_data),

        .forward_a(forward_a),
        .forward_b(forward_b),

        .alu_src(ex_alu_src),
        .alu_control(ex_alu_control),

        .branch(ex_branch),
        .jump(ex_jump),
        .funct3(ex_funct3),

        .alu_result(ex_alu_result),
        .store_data(ex_store_data),

        .branch_taken(ex_branch_taken),
        .branch_target(ex_branch_target),
        .jump_target(ex_jump_target)
    );

    // ==========================================
    // BRANCH / JUMP REDIRECTION
    // ==========================================

    assign redirect = ex_jump || ex_branch_taken;

    assign redirect_pc =
        ex_jump ? ex_jump_target : ex_branch_target;

endmodule
