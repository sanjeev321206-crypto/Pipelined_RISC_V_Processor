
`timescale 1ns/1ps

module next_pc_tb;

    reg [31:0] pc;
    reg [31:0] branch_target;
    reg [31:0] jump_target;

    reg branch_taken;
    reg jump;

    wire [31:0] next_pc;

    integer passed = 0;
    integer failed = 0;

    next_pc dut (
        .pc(pc),
        .branch_target(branch_target),
        .jump_target(jump_target),
        .branch_taken(branch_taken),
        .jump(jump),
        .next_pc(next_pc)
    );

    task check;
        input [31:0] expected;
        input [255:0] test_name;
        begin
            #5;
            if (next_pc === expected) begin
                $display("PASS: %0s", test_name);
                passed = passed + 1;
            end
            else begin
                $display("FAIL: %0s | Expected=%h Actual=%h",
                         test_name, expected, next_pc);
                failed = failed + 1;
            end
        end
    endtask

    initial begin

        $dumpfile("waveforms/next_pc.vcd");
        $dumpvars(0, next_pc_tb);

        // Test 1: Sequential execution
        pc = 32'h00000000;
        branch_target = 32'h00000020;
        jump_target = 32'h00000040;
        branch_taken = 0;
        jump = 0;
        check(32'h00000004, "Sequential PC plus 4");

        // Test 2: Another sequential address
        pc = 32'h00000010;
        check(32'h00000014, "Sequential execution at another address");

        // Test 3: Taken branch
        pc = 32'h00000010;
        branch_taken = 1;
        check(32'h00000020, "Taken branch selects branch target");

        // Test 4: Jump
        branch_taken = 0;
        jump = 1;
        check(32'h00000040, "Jump selects jump target");

        // Test 5: Jump has priority over branch
        branch_taken = 1;
        check(32'h00000040, "Jump priority over branch");

        // Test 6: Branch not taken
        jump = 0;
        branch_taken = 0;
        pc = 32'h00000080;
        check(32'h00000084, "Branch not taken continues sequentially");

        $display("--------------------------------");
        $display("Next PC Results");
        $display("Passed: %0d", passed);
        $display("Failed: %0d", failed);
        $display("--------------------------------");

        $finish;
    end

endmodule
