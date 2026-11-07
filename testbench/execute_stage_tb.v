
`timescale 1ns/1ps

module execute_stage_tb;

    reg [31:0] pc;
    reg [31:0] read_data1;
    reg [31:0] read_data2;
    reg [31:0] immediate;

    reg [31:0] ex_mem_data;
    reg [31:0] mem_wb_data;

    reg [1:0] forward_a;
    reg [1:0] forward_b;

    reg alu_src;
    reg [3:0] alu_control;
    reg branch;
    reg jump;
    reg [2:0] funct3;

    wire [31:0] alu_result;
    wire [31:0] store_data;

    wire branch_taken;
    wire [31:0] branch_target;
    wire [31:0] jump_target;

    integer passed = 0;
    integer failed = 0;

    execute_stage dut (
        .pc(pc),
        .read_data1(read_data1),
        .read_data2(read_data2),
        .immediate(immediate),
        .ex_mem_data(ex_mem_data),
        .mem_wb_data(mem_wb_data),
        .forward_a(forward_a),
        .forward_b(forward_b),
        .alu_src(alu_src),
        .alu_control(alu_control),
        .branch(branch),
        .jump(jump),
        .funct3(funct3),
        .alu_result(alu_result),
        .store_data(store_data),
        .branch_taken(branch_taken),
        .branch_target(branch_target),
        .jump_target(jump_target)
    );

    task check;
        input [31:0] expected_alu;
        input expected_branch;
        input [255:0] test_name;
        begin
            #10;
            if ((alu_result === expected_alu) &&
                (branch_taken === expected_branch)) begin
                $display("PASS: %0s", test_name);
                passed = passed + 1;
            end
            else begin
                $display("FAIL: %0s | ALU expected=%h actual=%h | Branch expected=%b actual=%b",
                         test_name, expected_alu, alu_result,
                         expected_branch, branch_taken);
                failed = failed + 1;
            end
        end
    endtask

    initial begin

        $dumpfile("waveforms/execute_stage.vcd");
        $dumpvars(0, execute_stage_tb);

        // Initial values
        pc = 32'h00000000;
        read_data1 = 32'd10;
        read_data2 = 32'd20;
        immediate = 32'd5;

        ex_mem_data = 32'd0;
        mem_wb_data = 32'd0;

        forward_a = 2'b00;
        forward_b = 2'b00;

        alu_src = 0;
        alu_control = 4'b0000;
        branch = 0;
        jump = 0;
        funct3 = 3'b000;

        // Test 1: ADD
        alu_control = 4'b0000;
        check(32'd30, 0, "ADD operation");

        // Test 2: SUB
        alu_control = 4'b0001;
        check(32'hFFFFFFF6, 0, "SUB operation");

        // Test 3: ADDI
        alu_src = 1;
        alu_control = 4'b0000;
        check(32'd15, 0, "ADDI operation");

        // Test 4: Forward operand A from EX/MEM
        alu_src = 0;
        alu_control = 4'b0000;
        forward_a = 2'b10;
        ex_mem_data = 32'd50;
        check(32'd70, 0, "Forward operand A from EX/MEM");

        // Test 5: Forward operand B from MEM/WB
        forward_a = 2'b00;
        forward_b = 2'b01;
        mem_wb_data = 32'd40;
        check(32'd50, 0, "Forward operand B from MEM/WB");

        // Test 6: BEQ taken
        forward_b = 2'b00;
        read_data1 = 32'd25;
        read_data2 = 32'd25;
        branch = 1;
        funct3 = 3'b000;
        check(32'd50, 1, "BEQ taken");

        // Test 7: BEQ not taken
        read_data2 = 32'd30;
        check(32'd55, 0, "BEQ not taken");

        // Test 8: BNE taken
        funct3 = 3'b001;
        check(32'd55, 1, "BNE taken");

        // Test 9: JAL target calculation
        branch = 0;
        jump = 1;
        pc = 32'h00000040;
        immediate = 32'd16;
        #10;
        if (jump_target === 32'h00000050) begin
            $display("PASS: JAL target calculation");
            passed = passed + 1;
        end
        else begin
            $display("FAIL: JAL target calculation");
            failed = failed + 1;
        end

        // Test 10: Store data forwarding
        read_data2 = 32'd10;
        forward_b = 2'b10;
        ex_mem_data = 32'd99;
        #10;
        if (store_data === 32'd99) begin
            $display("PASS: Store data forwarding");
            passed = passed + 1;
        end
        else begin
            $display("FAIL: Store data forwarding");
            failed = failed + 1;
        end

        $display("--------------------------------");
        $display("Execute Stage Results");
        $display("Passed: %0d", passed);
        $display("Failed: %0d", failed);
        $display("--------------------------------");

        $finish;

    end

endmodule
