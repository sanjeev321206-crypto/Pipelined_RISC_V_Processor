
`timescale 1ns/1ps

module hazard_detection_unit_tb;

    reg id_ex_mem_read;
    reg [4:0] id_ex_rd;

    reg [4:0] if_id_rs1;
    reg [4:0] if_id_rs2;

    reg if_id_uses_rs1;
    reg if_id_uses_rs2;

    wire stall;

    integer passed = 0;
    integer failed = 0;

    hazard_detection_unit dut (
        .id_ex_mem_read(id_ex_mem_read),
        .id_ex_rd(id_ex_rd),
        .if_id_rs1(if_id_rs1),
        .if_id_rs2(if_id_rs2),
        .if_id_uses_rs1(if_id_uses_rs1),
        .if_id_uses_rs2(if_id_uses_rs2),
        .stall(stall)
    );

    task check;
        input expected;
        input [255:0] test_name;
        begin
            #10;
            if (stall === expected) begin
                $display("PASS: %0s", test_name);
                passed = passed + 1;
            end
            else begin
                $display("FAIL: %0s | Expected=%b Actual=%b",
                         test_name, expected, stall);
                failed = failed + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("waveforms/hazard_detection_unit.vcd");
        $dumpvars(0, hazard_detection_unit_tb);

        // Test 1: Load-use hazard through rs1
        id_ex_mem_read = 1;
        id_ex_rd = 5'd5;
        if_id_rs1 = 5'd5;
        if_id_rs2 = 5'd2;
        if_id_uses_rs1 = 1;
        if_id_uses_rs2 = 1;
        check(1, "Load-use hazard through rs1");

        // Test 2: Load-use hazard through rs2
        id_ex_mem_read = 1;
        id_ex_rd = 5'd7;
        if_id_rs1 = 5'd1;
        if_id_rs2 = 5'd7;
        if_id_uses_rs1 = 1;
        if_id_uses_rs2 = 1;
        check(1, "Load-use hazard through rs2");

        // Test 3: No matching source register
        id_ex_mem_read = 1;
        id_ex_rd = 5'd5;
        if_id_rs1 = 5'd1;
        if_id_rs2 = 5'd2;
        if_id_uses_rs1 = 1;
        if_id_uses_rs2 = 1;
        check(0, "No dependency");

        // Test 4: Destination is x0
        id_ex_mem_read = 1;
        id_ex_rd = 5'd0;
        if_id_rs1 = 5'd0;
        if_id_rs2 = 5'd0;
        if_id_uses_rs1 = 1;
        if_id_uses_rs2 = 1;
        check(0, "No hazard when destination is x0");

        // Test 5: Previous instruction is not a load
        id_ex_mem_read = 0;
        id_ex_rd = 5'd5;
        if_id_rs1 = 5'd5;
        if_id_rs2 = 5'd2;
        if_id_uses_rs1 = 1;
        if_id_uses_rs2 = 1;
        check(0, "No hazard when previous instruction is not a load");

        // Test 6: Immediate instruction does not use rs2
        id_ex_mem_read = 1;
        id_ex_rd = 5'd5;
        if_id_rs1 = 5'd1;
        if_id_rs2 = 5'd5;
        if_id_uses_rs1 = 1;
        if_id_uses_rs2 = 0;
        check(0, "Ignore unused rs2 field");

        // Test 7: Both source registers are unused
        id_ex_mem_read = 1;
        id_ex_rd = 5'd5;
        if_id_rs1 = 5'd5;
        if_id_rs2 = 5'd5;
        if_id_uses_rs1 = 0;
        if_id_uses_rs2 = 0;
        check(0, "No hazard when neither source is used");

        $display("--------------------------------");
        $display("Hazard Detection Unit Results");
        $display("Passed: %0d", passed);
        $display("Failed: %0d", failed);
        $display("--------------------------------");

        $finish;
    end

endmodule
