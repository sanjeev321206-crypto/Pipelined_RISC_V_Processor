
`timescale 1ns/1ps

module control_unit_tb;

    reg [6:0] opcode;
    reg [2:0] funct3;
    reg [6:0] funct7;

    wire reg_write;
    wire mem_read;
    wire mem_write;
    wire mem_to_reg;
    wire alu_src;
    wire branch;
    wire jump;
    wire [3:0] alu_control;
    wire [1:0] imm_type;

    integer passed;
    integer failed;

    control_unit uut (
        .opcode(opcode),
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

    task check_result;
        input [8*40-1:0] test_name;
        input exp_reg_write;
        input exp_mem_read;
        input exp_mem_write;
        input exp_mem_to_reg;
        input exp_alu_src;
        input exp_branch;
        input exp_jump;
        input [3:0] exp_alu_control;
        input [1:0] exp_imm_type;

        begin
            #5;

            if (
                reg_write   === exp_reg_write &&
                mem_read    === exp_mem_read &&
                mem_write   === exp_mem_write &&
                mem_to_reg  === exp_mem_to_reg &&
                alu_src     === exp_alu_src &&
                branch      === exp_branch &&
                jump        === exp_jump &&
                alu_control === exp_alu_control &&
                imm_type    === exp_imm_type
            ) begin
                $display("%0s PASSED", test_name);
                passed = passed + 1;
            end
            else begin
                $display("%0s FAILED", test_name);
                failed = failed + 1;
            end
        end
    endtask

    initial begin

        $dumpfile("waveforms/control_unit.vcd");
        $dumpvars(0, control_unit_tb);

        passed = 0;
        failed = 0;

        // Test 1: ADD
        opcode = 7'b0110011;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        check_result("ADD", 1,0,0,0,0,0,0,4'b0000,2'b00);

        // Test 2: SUB
        opcode = 7'b0110011;
        funct3 = 3'b000;
        funct7 = 7'b0100000;
        check_result("SUB", 1,0,0,0,0,0,0,4'b0001,2'b00);

        // Test 3: AND
        opcode = 7'b0110011;
        funct3 = 3'b111;
        funct7 = 7'b0000000;
        check_result("AND", 1,0,0,0,0,0,0,4'b0010,2'b00);

        // Test 4: OR
        opcode = 7'b0110011;
        funct3 = 3'b110;
        funct7 = 7'b0000000;
        check_result("OR", 1,0,0,0,0,0,0,4'b0011,2'b00);

        // Test 5: XOR
        opcode = 7'b0110011;
        funct3 = 3'b100;
        funct7 = 7'b0000000;
        check_result("XOR", 1,0,0,0,0,0,0,4'b0100,2'b00);

        // Test 6: ADDI
        opcode = 7'b0010011;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        check_result("ADDI", 1,0,0,0,1,0,0,4'b0000,2'b00);

        // Test 7: LW
        opcode = 7'b0000011;
        funct3 = 3'b010;
        funct7 = 7'b0000000;
        check_result("LW", 1,1,0,1,1,0,0,4'b0000,2'b00);

        // Test 8: SW
        opcode = 7'b0100011;
        funct3 = 3'b010;
        funct7 = 7'b0000000;
        check_result("SW", 0,0,1,0,1,0,0,4'b0000,2'b01);

        // Test 9: BEQ
        opcode = 7'b1100011;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        check_result("BEQ", 0,0,0,0,0,1,0,4'b0001,2'b10);

        // Test 10: BNE
        opcode = 7'b1100011;
        funct3 = 3'b001;
        funct7 = 7'b0000000;
        check_result("BNE", 0,0,0,0,0,1,0,4'b0001,2'b10);

        // Test 11: JAL
        opcode = 7'b1101111;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        check_result("JAL", 1,0,0,0,0,0,1,4'b0000,2'b11);

        // Test 12: Unsupported opcode
        opcode = 7'b1111111;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        check_result("Unsupported instruction", 0,0,0,0,0,0,0,4'b0000,2'b00);

        $display("--------------------------------");
        $display("CONTROL UNIT TEST SUMMARY");
        $display("PASSED: %0d", passed);
        $display("FAILED: %0d", failed);
        $display("--------------------------------");

        $finish;

    end

endmodule
