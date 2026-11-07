
`timescale 1ns/1ps

module if_id_register_tb;

    reg clk;
    reg reset;
    reg stall;
    reg flush;

    reg [31:0] pc_in;
    reg [31:0] pc_plus4_in;
    reg [31:0] instruction_in;

    wire [31:0] pc_out;
    wire [31:0] pc_plus4_out;
    wire [31:0] instruction_out;

    integer passed;
    integer failed;

    if_id_register uut (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .flush(flush),
        .pc_in(pc_in),
        .pc_plus4_in(pc_plus4_in),
        .instruction_in(instruction_in),
        .pc_out(pc_out),
        .pc_plus4_out(pc_plus4_out),
        .instruction_out(instruction_out)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 0;
        stall = 0;
        flush = 0;

        pc_in = 0;
        pc_plus4_in = 0;
        instruction_in = 0;

        passed = 0;
        failed = 0;

        $dumpfile("waveforms/if_id_register.vcd");
        $dumpvars(0, if_id_register_tb);

        // Test 1: Reset
        @(negedge clk);
        reset = 1;

        @(posedge clk);
        #1;

        if (pc_out === 0 &&
            pc_plus4_out === 0 &&
            instruction_out === 32'h00000013) begin
            $display("TEST 1 PASSED: Reset");
            passed = passed + 1;
        end
        else begin
            $display("TEST 1 FAILED: Reset");
            failed = failed + 1;
        end

        // Test 2: Normal operation
        @(negedge clk);
        reset = 0;
        pc_in = 32'h00000004;
        pc_plus4_in = 32'h00000008;
        instruction_in = 32'h00A00093;

        @(posedge clk);
        #1;

        if (pc_out === 32'h00000004 &&
            pc_plus4_out === 32'h00000008 &&
            instruction_out === 32'h00A00093) begin
            $display("TEST 2 PASSED: Normal operation");
            passed = passed + 1;
        end
        else begin
            $display("TEST 2 FAILED: Normal operation");
            failed = failed + 1;
        end

        // Test 3: Stall holds previous values
        @(negedge clk);
        stall = 1;
        pc_in = 32'h00000020;
        pc_plus4_in = 32'h00000024;
        instruction_in = 32'h01400113;

        @(posedge clk);
        #1;

        if (pc_out === 32'h00000004 &&
            pc_plus4_out === 32'h00000008 &&
            instruction_out === 32'h00A00093) begin
            $display("TEST 3 PASSED: Stall");
            passed = passed + 1;
        end
        else begin
            $display("TEST 3 FAILED: Stall");
            failed = failed + 1;
        end

        // Test 4: Flush inserts NOP
        @(negedge clk);
        stall = 0;
        flush = 1;

        @(posedge clk);
        #1;

        if (pc_out === 0 &&
            pc_plus4_out === 0 &&
            instruction_out === 32'h00000013) begin
            $display("TEST 4 PASSED: Flush");
            passed = passed + 1;
        end
        else begin
            $display("TEST 4 FAILED: Flush");
            failed = failed + 1;
        end

        $display("--------------------------------");
        $display("IF/ID REGISTER TEST SUMMARY");
        $display("PASSED: %0d", passed);
        $display("FAILED: %0d", failed);
        $display("--------------------------------");

        $finish;

    end

endmodule
