
`timescale 1ns/1ps

module branch_comparator_tb;

    reg [31:0] operand_a;
    reg [31:0] operand_b;
    reg [2:0] funct3;

    wire branch_taken;

    integer passed = 0;
    integer failed = 0;

    branch_comparator dut (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .funct3(funct3),
        .branch_taken(branch_taken)
    );

    task check;
        input expected;
        input [255:0] test_name;
        begin
            #5;
            if (branch_taken === expected) begin
                $display("PASS: %0s", test_name);
                passed = passed + 1;
            end
            else begin
                $display("FAIL: %0s | Expected=%b Actual=%b",
                         test_name, expected, branch_taken);
                failed = failed + 1;
            end
        end
    endtask

    initial begin

        $dumpfile("waveforms/branch_comparator.vcd");
        $dumpvars(0, branch_comparator_tb);

        // Test 1: BEQ with equal operands
        operand_a = 32'd10;
        operand_b = 32'd10;
        funct3 = 3'b000;
        check(1'b1, "BEQ with equal operands");

        // Test 2: BEQ with unequal operands
        operand_a = 32'd10;
        operand_b = 32'd20;
        check(1'b0, "BEQ with unequal operands");

        // Test 3: BNE with unequal operands
        operand_a = 32'd15;
        operand_b = 32'd25;
        funct3 = 3'b001;
        check(1'b1, "BNE with unequal operands");

        // Test 4: BNE with equal operands
        operand_a = 32'd30;
        operand_b = 32'd30;
        check(1'b0, "BNE with equal operands");

        // Test 5: BEQ with zero operands
        operand_a = 32'd0;
        operand_b = 32'd0;
        funct3 = 3'b000;
        check(1'b1, "BEQ with zero operands");

        // Test 6: Unsupported branch funct3
        operand_a = 32'd10;
        operand_b = 32'd10;
        funct3 = 3'b010;
        check(1'b0, "Unsupported branch funct3");

        $display("--------------------------------");
        $display("Branch Comparator Results");
        $display("Passed: %0d", passed);
        $display("Failed: %0d", failed);
        $display("--------------------------------");

        $finish;
    end

endmodule
