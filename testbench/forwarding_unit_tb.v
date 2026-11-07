
`timescale 1ns/1ps

module forwarding_unit_tb;

    reg [4:0] id_ex_rs1;
    reg [4:0] id_ex_rs2;

    reg [4:0] ex_mem_rd;
    reg ex_mem_reg_write;

    reg [4:0] mem_wb_rd;
    reg mem_wb_reg_write;

    wire [1:0] forward_a;
    wire [1:0] forward_b;

    integer passed = 0;
    integer failed = 0;

    forwarding_unit dut (
        .id_ex_rs1(id_ex_rs1),
        .id_ex_rs2(id_ex_rs2),
        .ex_mem_rd(ex_mem_rd),
        .ex_mem_reg_write(ex_mem_reg_write),
        .mem_wb_rd(mem_wb_rd),
        .mem_wb_reg_write(mem_wb_reg_write),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    task check;
        input [1:0] expected_a;
        input [1:0] expected_b;
        input [255:0] test_name;
        begin
            #10;
            if ((forward_a === expected_a) &&
                (forward_b === expected_b)) begin
                $display("PASS: %0s", test_name);
                passed = passed + 1;
            end
            else begin
                $display("FAIL: %0s | Expected A=%b B=%b | Actual A=%b B=%b",
                         test_name, expected_a, expected_b,
                         forward_a, forward_b);
                failed = failed + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("waveforms/forwarding_unit.vcd");
        $dumpvars(0, forwarding_unit_tb);

        // Test 1: No forwarding required
        id_ex_rs1 = 5'd1;
        id_ex_rs2 = 5'd2;
        ex_mem_rd = 5'd5;
        ex_mem_reg_write = 1;
        mem_wb_rd = 5'd6;
        mem_wb_reg_write = 1;
        check(2'b00, 2'b00, "No forwarding required");

        // Test 2: Forward operand A from EX/MEM
        id_ex_rs1 = 5'd5;
        id_ex_rs2 = 5'd2;
        ex_mem_rd = 5'd5;
        ex_mem_reg_write = 1;
        mem_wb_rd = 5'd6;
        mem_wb_reg_write = 1;
        check(2'b10, 2'b00, "Forward A from EX/MEM");

        // Test 3: Forward operand B from EX/MEM
        id_ex_rs1 = 5'd1;
        id_ex_rs2 = 5'd7;
        ex_mem_rd = 5'd7;
        ex_mem_reg_write = 1;
        mem_wb_rd = 5'd6;
        mem_wb_reg_write = 1;
        check(2'b00, 2'b10, "Forward B from EX/MEM");

        // Test 4: Forward both operands from MEM/WB
        id_ex_rs1 = 5'd3;
        id_ex_rs2 = 5'd4;
        ex_mem_rd = 5'd8;
        ex_mem_reg_write = 1;
        mem_wb_rd = 5'd3;
        mem_wb_reg_write = 1;
        check(2'b01, 2'b00, "Forward A from MEM/WB");

        // Test 5: Forward B from MEM/WB
        id_ex_rs1 = 5'd1;
        id_ex_rs2 = 5'd4;
        ex_mem_rd = 5'd8;
        ex_mem_reg_write = 1;
        mem_wb_rd = 5'd4;
        mem_wb_reg_write = 1;
        check(2'b00, 2'b01, "Forward B from MEM/WB");

        // Test 6: EX/MEM has priority over MEM/WB
        id_ex_rs1 = 5'd9;
        id_ex_rs2 = 5'd10;
        ex_mem_rd = 5'd9;
        ex_mem_reg_write = 1;
        mem_wb_rd = 5'd9;
        mem_wb_reg_write = 1;
        check(2'b10, 2'b00, "EX/MEM priority over MEM/WB");

        // Test 7: Do not forward register x0
        id_ex_rs1 = 5'd0;
        id_ex_rs2 = 5'd0;
        ex_mem_rd = 5'd0;
        ex_mem_reg_write = 1;
        mem_wb_rd = 5'd0;
        mem_wb_reg_write = 1;
        check(2'b00, 2'b00, "Never forward register x0");

        // Test 8: Respect register write enable
        id_ex_rs1 = 5'd5;
        id_ex_rs2 = 5'd6;
        ex_mem_rd = 5'd5;
        ex_mem_reg_write = 0;
        mem_wb_rd = 5'd6;
        mem_wb_reg_write = 0;
        check(2'b00, 2'b00, "No forwarding when write enable is disabled");

        $display("--------------------------------");
        $display("Forwarding Unit Results");
        $display("Passed: %0d", passed);
        $display("Failed: %0d", failed);
        $display("--------------------------------");

        $finish;
    end

endmodule
