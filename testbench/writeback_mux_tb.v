
`timescale 1ns/1ps

module writeback_mux_tb;

    reg [31:0] alu_result;
    reg [31:0] memory_data;
    reg [31:0] pc_plus4;

    reg mem_to_reg;
    reg jump;

    wire [31:0] writeback_data;

    integer passed = 0;
    integer failed = 0;

    writeback_mux dut (
        .alu_result(alu_result),
        .memory_data(memory_data),
        .pc_plus4(pc_plus4),
        .mem_to_reg(mem_to_reg),
        .jump(jump),
        .writeback_data(writeback_data)
    );

    task check;
        input [31:0] expected;
        input [255:0] test_name;
        begin
            #5;
            if (writeback_data === expected) begin
                $display("PASS: %0s", test_name);
                passed = passed + 1;
            end
            else begin
                $display("FAIL: %0s | Expected=%h Actual=%h",
                         test_name, expected, writeback_data);
                failed = failed + 1;
            end
        end
    endtask

    initial begin

        $dumpfile("waveforms/writeback_mux.vcd");
        $dumpvars(0, writeback_mux_tb);

        alu_result = 32'h0000001E;
        memory_data = 32'h00000064;
        pc_plus4 = 32'h00000004;

        // Test 1: ALU result
        mem_to_reg = 0;
        jump = 0;
        check(32'h0000001E, "Select ALU result");

        // Test 2: Memory data
        mem_to_reg = 1;
        jump = 0;
        check(32'h00000064, "Select memory data");

        // Test 3: JAL PC + 4
        mem_to_reg = 0;
        jump = 1;
        check(32'h00000004, "Select PC plus 4 for JAL");

        // Test 4: Jump priority over memory selection
        mem_to_reg = 1;
        jump = 1;
        check(32'h00000004, "JAL priority over memory selection");

        // Test 5: Updated ALU result
        alu_result = 32'hABCDEF12;
        mem_to_reg = 0;
        jump = 0;
        check(32'hABCDEF12, "Select updated ALU result");

        $display("--------------------------------");
        $display("Writeback MUX Results");
        $display("Passed: %0d", passed);
        $display("Failed: %0d", failed);
        $display("--------------------------------");

        $finish;
    end

endmodule
