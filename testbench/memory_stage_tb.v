
`timescale 1ns/1ps

module memory_stage_tb;

    reg clk;
    reg [31:0] alu_result;
    reg [31:0] store_data;
    reg mem_read;
    reg mem_write;

    wire [31:0] memory_data;

    integer passed = 0;
    integer failed = 0;

    memory_stage dut (
        .clk(clk),
        .alu_result(alu_result),
        .store_data(store_data),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .memory_data(memory_data)
    );

    always #5 clk = ~clk;

    task check;
        input [31:0] expected;
        input [255:0] test_name;
        begin
            #1;
            if (memory_data === expected) begin
                $display("PASS: %0s", test_name);
                passed = passed + 1;
            end
            else begin
                $display("FAIL: %0s | Expected=%h Actual=%h",
                         test_name, expected, memory_data);
                failed = failed + 1;
            end
        end
    endtask

    initial begin

        $dumpfile("waveforms/memory_stage.vcd");
        $dumpvars(0, memory_stage_tb);

        clk = 0;
        alu_result = 0;
        store_data = 0;
        mem_read = 0;
        mem_write = 0;

        // Test 1: Write data into memory
        alu_result = 32'd0;
        store_data = 32'h12345678;
        mem_write = 1;

        @(posedge clk);
        #1;

        // Test 2: Read stored data
        mem_write = 0;
        mem_read = 1;
        #1;
        check(32'h12345678, "Read previously stored data");

        // Test 3: Write another memory location
        mem_read = 0;
        alu_result = 32'd4;
        store_data = 32'hAABBCCDD;
        mem_write = 1;

        @(posedge clk);
        #1;

        // Test 4: Read second memory location
        mem_write = 0;
        mem_read = 1;
        #1;
        check(32'hAABBCCDD, "Read second memory location");

        // Test 5: Disable memory read
        mem_read = 0;
        #1;
        check(32'h00000000, "Read disabled");

        $display("--------------------------------");
        $display("Memory Stage Results");
        $display("Passed: %0d", passed);
        $display("Failed: %0d", failed);
        $display("--------------------------------");

        $finish;
    end

endmodule
