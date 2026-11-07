
`timescale 1ns/1ps

module alu_operand_mux_tb;

    reg [31:0] forwarded_register_data;
    reg [31:0] immediate;
    reg alu_src;

    wire [31:0] alu_operand;

    integer passed = 0;
    integer failed = 0;

    alu_operand_mux dut (
        .forwarded_register_data(forwarded_register_data),
        .immediate(immediate),
        .alu_src(alu_src),
        .alu_operand(alu_operand)
    );

    task check;
        input [31:0] expected;
        input [255:0] test_name;
        begin
            #5;
            if (alu_operand === expected) begin
                $display("PASS: %0s", test_name);
                passed = passed + 1;
            end
            else begin
                $display("FAIL: %0s | Expected=%h Actual=%h",
                         test_name, expected, alu_operand);
                failed = failed + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("waveforms/alu_operand_mux.vcd");
        $dumpvars(0, alu_operand_mux_tb);

        // Test 1: Select register operand
        forwarded_register_data = 32'd25;
        immediate = 32'd10;
        alu_src = 0;
        check(32'd25, "Select forwarded register data");

        // Test 2: Select immediate operand
        alu_src = 1;
        check(32'd10, "Select immediate value");

        // Test 3: Select a negative immediate
        immediate = -32'd8;
        check(32'hFFFFFFF8, "Select negative immediate");

        // Test 4: Updated register value
        forwarded_register_data = 32'd100;
        alu_src = 0;
        check(32'd100, "Select updated register data");

        // Test 5: Updated immediate
        immediate = 32'd200;
        alu_src = 1;
        check(32'd200, "Select updated immediate");

        $display("--------------------------------");
        $display("ALU Operand MUX Results");
        $display("Passed: %0d", passed);
        $display("Failed: %0d", failed);
        $display("--------------------------------");

        $finish;
    end

endmodule
