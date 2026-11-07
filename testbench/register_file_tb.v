
`timescale 1ns/1ps

module register_file_tb;

    reg clk;
    reg reg_write;

    reg [4:0] read_addr1;
    reg [4:0] read_addr2;
    reg [4:0] write_addr;

    reg [31:0] write_data;

    wire [31:0] read_data1;
    wire [31:0] read_data2;

    // Instantiate register file
    register_file uut (
        .clk(clk),
        .reg_write(reg_write),
        .read_addr1(read_addr1),
        .read_addr2(read_addr2),
        .write_addr(write_addr),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reg_write = 0;
        read_addr1 = 0;
        read_addr2 = 0;
        write_addr = 0;
        write_data = 0;

        $dumpfile("waveforms/register_file.vcd");
        $dumpvars(0, register_file_tb);

        // Test 1: Write to x1
        @(negedge clk);
        write_addr = 5'd1;
        write_data = 32'h12345678;
        reg_write = 1;

        @(posedge clk);
        #1;
        read_addr1 = 5'd1;
        #1;

        if (read_data1 === 32'h12345678)
            $display("TEST 1 PASSED: Write and read x1");
        else
            $display("TEST 1 FAILED");

        // Test 2: Write to x2
        @(negedge clk);
        write_addr = 5'd2;
        write_data = 32'hABCDEF01;

        @(posedge clk);
        #1;
        read_addr2 = 5'd2;
        #1;

        if (read_data2 === 32'hABCDEF01)
            $display("TEST 2 PASSED: Write and read x2");
        else
            $display("TEST 2 FAILED");

        // Test 3: x0 must always return zero
        @(negedge clk);
        write_addr = 5'd0;
        write_data = 32'hFFFFFFFF;

        @(posedge clk);
        #1;
        read_addr1 = 5'd0;
        read_addr2 = 5'd0;
        #1;

        if (read_data1 === 32'b0 &&
            read_data2 === 32'b0)
            $display("TEST 3 PASSED: x0 protection");
        else
            $display("TEST 3 FAILED");

        // Test 4: Disable writing
        @(negedge clk);
        write_addr = 5'd3;
        write_data = 32'h55555555;
        reg_write = 0;

        @(posedge clk);
        #1;
        read_addr1 = 5'd3;
        #1;

        if (read_data1 === 32'b0)
            $display("TEST 4 PASSED: Write disabled");
        else
            $display("TEST 4 FAILED");

        $display("--------------------------------");
        $display("REGISTER FILE TESTING COMPLETED");
        $display("--------------------------------");

        $finish;

    end

endmodule
