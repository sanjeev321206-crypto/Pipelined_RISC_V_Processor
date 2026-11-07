
`timescale 1ns/1ps

module instruction_memory_tb;

    reg  [31:0] address;
    wire [31:0] instruction;

    integer passed;
    integer failed;

    // Instantiate Instruction Memory
    instruction_memory uut (
        .address(address),
        .instruction(instruction)
    );

    task check_instruction;
        input [31:0] test_address;
        input [31:0] expected_instruction;
        input [8*40-1:0] test_name;

        begin
            address = test_address;
            #10;

            if (instruction === expected_instruction) begin
                $display("%0s PASSED: Address=%h Instruction=%h",
                         test_name, address, instruction);
                passed = passed + 1;
            end
            else begin
                $display("%0s FAILED: Address=%h Expected=%h Got=%h",
                         test_name, address,
                         expected_instruction, instruction);
                failed = failed + 1;
            end
        end
    endtask

    initial begin

        $dumpfile("waveforms/instruction_memory.vcd");
        $dumpvars(0, instruction_memory_tb);

        passed = 0;
        failed = 0;
        address = 0;

        // Test 1: First instruction
        check_instruction(32'h00000000, 32'h00A00093,
                          "Instruction 1");

        // Test 2: Second instruction
        check_instruction(32'h00000004, 32'h01400113,
                          "Instruction 2");

        // Test 3: Third instruction
        check_instruction(32'h00000008, 32'h002081B3,
                          "Instruction 3");

        // Test 4: Store instruction
        check_instruction(32'h0000000C, 32'h00302023,
                          "Store instruction");

        // Test 5: Load instruction
        check_instruction(32'h00000010, 32'h00002203,
                          "Load instruction");

        // Test 6: Uninitialized location returns NOP
        check_instruction(32'h00000014, 32'h00000013,
                          "Default NOP");

        // Test 7: Misaligned address returns NOP
        check_instruction(32'h00000002, 32'h00000013,
                          "Misaligned address");

        // Test 8: Out-of-range address returns NOP
        check_instruction(32'h00000400, 32'h00000013,
                          "Out-of-range address");

        $display("--------------------------------");
        $display("INSTRUCTION MEMORY TEST SUMMARY");
        $display("PASSED: %0d", passed);
        $display("FAILED: %0d", failed);
        $display("--------------------------------");

        $finish;

    end

endmodule
