
`timescale 1ns/1ps

module data_memory_tb;

    reg clk;
    reg mem_read;
    reg mem_write;

    reg [31:0] address;
    reg [31:0] write_data;

    wire [31:0] read_data;

    integer passed;
    integer failed;

    data_memory uut (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(address),
        .write_data(write_data),
        .read_data(read_data)
    );

    always #5 clk = ~clk;

    task check_result;
        input [8*40-1:0] test_name;
        input [31:0] expected;

        begin
            #1;
            if (read_data === expected) begin
                $display("%0s PASSED", test_name);
                passed = passed + 1;
            end
            else begin
                $display("%0s FAILED: Expected=%h Got=%h",
                         test_name, expected, read_data);
                failed = failed + 1;
            end
        end
    endtask

    initial begin

        clk = 0;
        mem_read = 0;
        mem_write = 0;
        address = 0;
        write_data = 0;

        passed = 0;
        failed = 0;

        $dumpfile("waveforms/data_memory.vcd");
        $dumpvars(0, data_memory_tb);

        // Test 1: Write a word
        @(negedge clk);
        address = 32'd0;
        write_data = 32'h12345678;
        mem_write = 1;

        @(posedge clk);
        #1;
        mem_write = 0;
        mem_read = 1;
        check_result("Word write and read", 32'h12345678);

        // Test 2: Little-endian storage
        if (uut.memory[0] === 8'h78 &&
            uut.memory[1] === 8'h56 &&
            uut.memory[2] === 8'h34 &&
            uut.memory[3] === 8'h12) begin
            $display("Little-endian storage PASSED");
            passed = passed + 1;
        end
        else begin
            $display("Little-endian storage FAILED");
            failed = failed + 1;
        end

        // Test 3: Write at another address
        @(negedge clk);
        address = 32'd8;
        write_data = 32'hAABBCCDD;
        mem_write = 1;
        mem_read = 0;

        @(posedge clk);
        #1;
        mem_write = 0;
        mem_read = 1;
        check_result("Second word write and read", 32'hAABBCCDD);

        // Test 4: Read disabled
        mem_read = 0;
        check_result("Read disabled", 32'b0);

        // Test 5: Misaligned address
        mem_read = 1;
        address = 32'd1;
        check_result("Misaligned read", 32'b0);

        // Test 6: Out-of-range address
        address = 32'd1024;
        check_result("Out-of-range read", 32'b0);

        // Test 7: Invalid store must be ignored
        @(negedge clk);
        address = 32'd1;
        write_data = 32'hFFFFFFFF;
        mem_write = 1;

        @(posedge clk);
        #1;
        mem_write = 0;

        if (uut.memory[0] === 8'h78 &&
            uut.memory[1] === 8'h56 &&
            uut.memory[2] === 8'h34 &&
            uut.memory[3] === 8'h12) begin
            $display("Invalid store protection PASSED");
            passed = passed + 1;
        end
        else begin
            $display("Invalid store protection FAILED");
            failed = failed + 1;
        end

        $display("--------------------------------");
        $display("DATA MEMORY TEST SUMMARY");
        $display("PASSED: %0d", passed);
        $display("FAILED: %0d", failed);
        $display("--------------------------------");

        $finish;

    end

endmodule
