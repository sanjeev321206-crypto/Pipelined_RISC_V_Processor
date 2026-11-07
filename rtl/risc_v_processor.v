
module risc_v_processor (
    input wire clk,
    input wire reset
);

    // ==========================================
    // FETCH AND PIPELINE CONTROL
    // ==========================================

    wire stall;
    wire hazard_stall;
    wire redirect;
    wire [31:0] redirect_pc;

    wire [31:0] fetch_pc;
    wire [31:0] fetch_pc_plus4;
    wire [31:0] fetch_instruction;

    // ==========================================
    // DECODE STAGE
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

    // ==========================================
    // WRITEBACK SIGNALS
    // ==========================================

    wire [31:0] writeback_data;
    wire [4:0] writeback_rd;
    wire writeback_reg_write;

    // ==========================================
    // HAZARD DETECTION
    // ==========================================

    wire if_id_uses_rs1;
    wire if_id_uses_rs2;

    wire [6:0] current_opcode;

    assign current_opcode = fetch_instruction[6:0];

    assign if_id_uses_rs1 =
        (current_opcode == 7'b0110011) ||
        (current_opcode == 7'b0010011) ||
        (current_opcode == 7'b0000011) ||
        (current_opcode == 7'b0100011) ||
        (current_opcode == 7'b1100011);

    assign if_id_uses_rs2 =
        (current_opcode == 7'b0110011) ||
        (current_opcode == 7'b0100011) ||
        (current_opcode == 7'b1100011);

    // A redirect takes priority over a load-use stall.
    assign stall = hazard_stall && !redirect;

    // ==========================================
    // ID/EX PIPELINE OUTPUTS
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
    // EXECUTE STAGE
    // ==========================================

    wire [31:0] ex_alu_result;
    wire [31:0] ex_store_data;

    wire ex_branch_taken;
    wire [31:0] ex_branch_target;
    wire [31:0] ex_jump_target;

    wire [1:0] forward_a;
    wire [1:0] forward_b;

    // ==========================================
    // EX/MEM PIPELINE OUTPUTS
    // ==========================================

    wire [31:0] ex_mem_alu_result;
    wire [31:0] ex_mem_store_data;
    wire [31:0] ex_mem_pc_plus4;

    wire [4:0] ex_mem_rd;

    wire ex_mem_reg_write;
    wire ex_mem_mem_read;
    wire ex_mem_mem_write;
    wire ex_mem_mem_to_reg;
    wire ex_mem_jump;

    // ==========================================
    // MEMORY STAGE
    // ==========================================

    wire [31:0] memory_data;

    // ==========================================
    // MEM/WB PIPELINE OUTPUTS
    // ==========================================

    wire [31:0] mem_wb_alu_result;
    wire [31:0] mem_wb_memory_data;
    wire [31:0] mem_wb_pc_plus4;

    wire [4:0] mem_wb_rd;

    wire mem_wb_reg_write;
    wire mem_wb_mem_to_reg;
    wire mem_wb_jump;

    // ==========================================
    // FORWARDING DATA
    // ==========================================

    wire [31:0] ex_mem_forward_data;
    wire [31:0] mem_wb_forward_data;

    // Forward load data from EX/MEM because memory
    // provides asynchronous read data.
    assign ex_mem_forward_data =
        ex_mem_jump ? ex_mem_pc_plus4 :
        ex_mem_mem_to_reg ? memory_data :
        ex_mem_alu_result;

    assign mem_wb_forward_data = writeback_data;

    // ==========================================
    // HAZARD DETECTION UNIT
    // ==========================================

    hazard_detection_unit hazard_unit (
        .id_ex_mem_read(ex_mem_read),
        .id_ex_rd(ex_rd),

        .if_id_rs1(decode_rs1),
        .if_id_rs2(decode_rs2),

        .if_id_uses_rs1(if_id_uses_rs1),
        .if_id_uses_rs2(if_id_uses_rs2),

        .stall(hazard_stall)
    );

    // ==========================================
    // FETCH STAGE
    // ==========================================

    fetch_stage fetch_unit (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .flush(redirect),

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
        .flush(redirect || stall),

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

        .ex_mem_rd(ex_mem_rd),
        .ex_mem_reg_write(ex_mem_reg_write),

        .mem_wb_rd(mem_wb_rd),
        .mem_wb_reg_write(mem_wb_reg_write),

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
    // BRANCH / JUMP CONTROL
    // ==========================================

    assign redirect = ex_jump || ex_branch_taken;

    assign redirect_pc =
        ex_jump ? ex_jump_target : ex_branch_target;

    // ==========================================
    // EX/MEM PIPELINE REGISTER
    // ==========================================

    ex_mem_register ex_mem_unit (
        .clk(clk),
        .reset(reset),
        .flush(1'b0),

        .alu_result_in(ex_alu_result),
        .store_data_in(ex_store_data),
        .pc_plus4_in(ex_pc_plus4),

        .rd_in(ex_rd),

        .reg_write_in(ex_reg_write),
        .mem_read_in(ex_mem_read),
        .mem_write_in(ex_mem_write),
        .mem_to_reg_in(ex_mem_to_reg),
        .jump_in(ex_jump),

        .alu_result_out(ex_mem_alu_result),
        .store_data_out(ex_mem_store_data),
        .pc_plus4_out(ex_mem_pc_plus4),

        .rd_out(ex_mem_rd),

        .reg_write_out(ex_mem_reg_write),
        .mem_read_out(ex_mem_mem_read),
        .mem_write_out(ex_mem_mem_write),
        .mem_to_reg_out(ex_mem_mem_to_reg),
        .jump_out(ex_mem_jump)
    );

    // ==========================================
    // MEMORY STAGE
    // ==========================================

    memory_stage memory_unit (
        .clk(clk),

        .alu_result(ex_mem_alu_result),
        .store_data(ex_mem_store_data),

        .mem_read(ex_mem_mem_read),
        .mem_write(ex_mem_mem_write),

        .memory_data(memory_data)
    );

    // ==========================================
    // MEM/WB PIPELINE REGISTER
    // ==========================================

    mem_wb_register mem_wb_unit (
        .clk(clk),
        .reset(reset),
        .flush(1'b0),

        .alu_result_in(ex_mem_alu_result),
        .memory_data_in(memory_data),
        .pc_plus4_in(ex_mem_pc_plus4),

        .rd_in(ex_mem_rd),

        .reg_write_in(ex_mem_reg_write),
        .mem_to_reg_in(ex_mem_mem_to_reg),
        .jump_in(ex_mem_jump),

        .alu_result_out(mem_wb_alu_result),
        .memory_data_out(mem_wb_memory_data),
        .pc_plus4_out(mem_wb_pc_plus4),

        .rd_out(mem_wb_rd),

        .reg_write_out(mem_wb_reg_write),
        .mem_to_reg_out(mem_wb_mem_to_reg),
        .jump_out(mem_wb_jump)
    );

    // ==========================================
    // WRITEBACK MUX
    // ==========================================

    writeback_mux writeback_unit (
        .alu_result(mem_wb_alu_result),
        .memory_data(mem_wb_memory_data),
        .pc_plus4(mem_wb_pc_plus4),

        .mem_to_reg(mem_wb_mem_to_reg),
        .jump(mem_wb_jump),

        .writeback_data(writeback_data)
    );

    // ==========================================
    // REGISTER FILE WRITEBACK FEEDBACK
    // ==========================================

    assign writeback_rd = mem_wb_rd;
    assign writeback_reg_write = mem_wb_reg_write;

endmodule
