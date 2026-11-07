
`timescale 1ns/1ps

module fetch_stage_tb;

    reg clk;
    reg reset;
    reg stall;
    reg flush;

    reg [31:0] redirect_pc;
    reg redirect;

    wire [31:0] pc_out;
    wire [31:0] pc_plus4_out;
    wire [31:0] instruction_out;

    integer passed = 0;
    integer failed = 0;

    fetch_stage dut (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .flush(flush),
        .redirect_pc(redirect_pc),
        .redirect(redirect),
        .pc_out(pc_out),
        .pc_plus4_out(pc_plus4_out),
        .instruction_out(instruction_out)
    );

    always #5 clk = ~clk;

    task check;
        input [31:0] expected_pc;
        input [31:0] expected_instruction;
        input [31:0] expected_pc_plus4;
        input [255:0] test_name;

        begin
            #1;

            if ((pc_out === expected_pc) &&
                (instruction_out === expected_instruction) &&
                (pc_plus4_out === expected_pc_plus4)) begin

                $display("PASS: %0s", test_name);
                passed = passed + 1;

            end
            else begin

                $display("FAIL: %0s", test_name);
                $display("Expected PC=%h Instruction=%h PC+4=%h",
                         expected_pc, expected_instruction,
                         expected_pc_plus4);

                $display("Actual   PC=%h Instruction=%h PC+4=%h",
                         pc_out, instruction_out, pc_plus4_out);

                failed = failed + 1;

            end
        end
    endtask

    initial begin

        $dumpfile("waveforms/fetch_stage.vcd");
        $dumpvars(0, fetch_stage_tb);

        clk = 0;
        reset = 1;
        stall = 0;
        flush = 0;
        redirect = 0;
        redirect_pc = 0;

        // Test 1: Reset
        @(posedge clk);
        #1;
        check(
            32'h00000000,
            32'h00000013,
            32'h00000000,
            "Reset"
        );

        // Test 2: Fetch first instruction
        @(negedge clk);
        reset = 0;

        #1;
        check(
            32'h00000000,
            32'h00A00093,
            32'h00000004,
            "Fetch first instruction"
        );

        // Test 3: Fetch second instruction
        @(posedge clk);
        #1;
        check(
            32'h00000000,
            32'h00A00093,
            32'h00000004,
            "IF/ID captures first instruction"
        );

        // Test 4: Fetch third instruction
        @(posedge clk);
        #1;
        check(
            32'h00000004,
            32'h01400113,
            32'h00000008,
            "IF/ID captures second instruction"
        );

        // Test 5: Stall
        @(negedge clk);
        stall = 1;

        @(posedge clk);
        #1;
        check(
            32'h00000004,
            32'h01400113,
            32'h00000008,
            "PC and IF/ID hold during stall"
        );

        // Test 6: Redirect
        @(negedge clk);
        stall = 0;
        redirect = 1;
        redirect_pc = 32'h00000010;

        @(posedge clk);
        #1;

        if ((dut.current_pc === 32'h00000010) &&
            (instruction_out === 32'h00000013)) begin

            $display("PASS: Redirect and IF/ID flush");
            passed = passed + 1;

        end
        else begin

            $display("FAIL: Redirect and IF/ID flush");
            failed = failed + 1;

        end

        // Check fetch at redirected address
        @(negedge clk);
        redirect = 0;

        #1;
        if ((dut.current_pc === 32'h00000010) &&
            (dut.fetched_instruction === 32'h00002203)) begin

            $display("PASS: Instruction fetched from redirect target");
            passed = passed + 1;

        end
        else begin

            $display("FAIL: Instruction fetched from redirect target");
            failed = failed + 1;

        end

        $display("--------------------------------");
        $display("Fetch Stage Results");
        $display("Passed: %0d", passed);
        $display("Failed: %0d", failed);
        $display("--------------------------------");

        $finish;

    end

endmodule
