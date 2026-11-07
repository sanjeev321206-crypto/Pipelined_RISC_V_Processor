
`timescale 1ns/1ps

module ex_mem_register_tb;

    reg clk, reset, flush;

    reg [31:0] alu_result_in;
    reg [31:0] store_data_in;
    reg [31:0] pc_plus4_in;

    reg [4:0] rd_in;

    reg reg_write_in;
    reg mem_read_in;
    reg mem_write_in;
    reg mem_to_reg_in;
    reg jump_in;

    wire [31:0] alu_result_out;
    wire [31:0] store_data_out;
    wire [31:0] pc_plus4_out;

    wire [4:0] rd_out;

    wire reg_write_out;
    wire mem_read_out;
    wire mem_write_out;
    wire mem_to_reg_out;
    wire jump_out;

    integer passed, failed;

    ex_mem_register uut (
        .clk(clk),
        .reset(reset),
        .flush(flush),

        .alu_result_in(alu_result_in),
        .store_data_in(store_data_in),
        .pc_plus4_in(pc_plus4_in),

        .rd_in(rd_in),

        .reg_write_in(reg_write_in),
        .mem_read_in(mem_read_in),
        .mem_write_in(mem_write_in),
        .mem_to_reg_in(mem_to_reg_in),
        .jump_in(jump_in),

        .alu_result_out(alu_result_out),
        .store_data_out(store_data_out),
        .pc_plus4_out(pc_plus4_out),

        .rd_out(rd_out),

        .reg_write_out(reg_write_out),
        .mem_read_out(mem_read_out),
        .mem_write_out(mem_write_out),
        .mem_to_reg_out(mem_to_reg_out),
        .jump_out(jump_out)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 0;
        flush = 0;

        alu_result_in = 0;
        store_data_in = 0;
        pc_plus4_in = 0;
        rd_in = 0;

        reg_write_in = 0;
        mem_read_in = 0;
        mem_write_in = 0;
        mem_to_reg_in = 0;
        jump_in = 0;

        passed = 0;
        failed = 0;

        $dumpfile("waveforms/ex_mem_register.vcd");
        $dumpvars(0, ex_mem_register_tb);

        // TEST 1: Reset
        @(negedge clk);
        reset = 1;

        @(posedge clk);
        #1;

        if (alu_result_out === 0 &&
            store_data_out === 0 &&
            pc_plus4_out === 0 &&
            rd_out === 0 &&
            reg_write_out === 0 &&
            mem_read_out === 0 &&
            mem_write_out === 0 &&
            mem_to_reg_out === 0 &&
            jump_out === 0) begin

            $display("TEST 1 PASSED: Reset");
            passed = passed + 1;
        end
        else begin
            $display("TEST 1 FAILED: Reset");
            failed = failed + 1;
        end

        // TEST 2: Normal data and control transfer
        @(negedge clk);
        reset = 0;

        alu_result_in = 32'h0000001E;
        store_data_in = 32'h12345678;
        pc_plus4_in = 32'h00000020;

        rd_in = 5'd4;

        reg_write_in = 1;
        mem_read_in = 1;
        mem_write_in = 0;
        mem_to_reg_in = 1;
        jump_in = 0;

        @(posedge clk);
        #1;

        if (alu_result_out === 32'h0000001E &&
            store_data_out === 32'h12345678 &&
            pc_plus4_out === 32'h00000020 &&
            rd_out === 5'd4 &&
            reg_write_out === 1'b1 &&
            mem_read_out === 1'b1 &&
            mem_write_out === 1'b0 &&
            mem_to_reg_out === 1'b1 &&
            jump_out === 1'b0) begin

            $display("TEST 2 PASSED: Data and control transfer");
            passed = passed + 1;
        end
        else begin
            $display("TEST 2 FAILED: Data and control transfer");
            failed = failed + 1;
        end

        // TEST 3: Flush
        @(negedge clk);
        flush = 1;

        @(posedge clk);
        #1;

        if (alu_result_out === 0 &&
            store_data_out === 0 &&
            pc_plus4_out === 0 &&
            rd_out === 0 &&
            reg_write_out === 0 &&
            mem_read_out === 0 &&
            mem_write_out === 0 &&
            mem_to_reg_out === 0 &&
            jump_out === 0) begin

            $display("TEST 3 PASSED: Flush");
            passed = passed + 1;
        end
        else begin
            $display("TEST 3 FAILED: Flush");
            failed = failed + 1;
        end

        $display("--------------------------------");
        $display("EX/MEM REGISTER TEST SUMMARY");
        $display("PASSED: %0d", passed);
        $display("FAILED: %0d", failed);
        $display("--------------------------------");

        $finish;

    end

endmodule
