
`timescale 1ns/1ps

module program_counter_tb;

    reg clk;
    reg reset;
    reg enable;
    reg [31:0] next_pc;

    wire [31:0] pc;

    integer passed = 0;
    integer failed = 0;

    program_counter dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .next_pc(next_pc),
        .pc(pc)
    );

    always #5 clk = ~clk;

    task check;
        input [31:0] expected;
        input [255:0] test_name;
        begin
            #1;
            if (pc === expected) begin
                $display("PASS: %0s", test_name);
                passed = passed + 1;
            end
            else begin
                $display("FAIL: %0s | Expected=%h Actual=%h",
                         test_name, expected, pc);
                failed = failed + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("waveforms/program_counter.vcd");
        $dumpvars(0, program_counter_tb);

        clk = 0;
        reset = 1;
        enable = 0;
        next_pc = 0;

        // Test 1: Reset
        @(posedge clk);
        #1;
        check(32'h00000000, "PC reset");

        // Test 2: Normal increment
        reset = 0;
        enable = 1;
        next_pc = 32'h00000004;
        @(posedge clk);
        check(32'h00000004, "PC advances to next instruction");

        // Test 3: Another increment
        next_pc = 32'h00000008;
        @(posedge clk);
        check(32'h00000008, "PC advances again");

        // Test 4: Hold during stall
        enable = 0;
        next_pc = 32'h0000000C;
        @(posedge clk);
        check(32'h00000008, "PC holds when enable is low");

        // Test 5: Branch or jump target
        enable = 1;
        next_pc = 32'h00000040;
        @(posedge clk);
        check(32'h00000040, "PC accepts branch or jump target");

        // Test 6: Reset again
        reset = 1;
        @(posedge clk);
        check(32'h00000000, "PC resets again");

        $display("--------------------------------");
        $display("Program Counter Results");
        $display("Passed: %0d", passed);
        $display("Failed: %0d", failed);
        $display("--------------------------------");

        $finish;
    end

endmodule
