
`timescale 1ns/1ps

module id_ex_register_tb;

    reg clk, reset, flush;

    reg [31:0] pc_in, pc_plus4_in;
    reg [31:0] read_data1_in, read_data2_in, immediate_in;

    reg [4:0] rs1_in, rs2_in, rd_in;
    reg [2:0] funct3_in;
    reg [6:0] funct7_in;

    reg reg_write_in, mem_read_in, mem_write_in;
    reg mem_to_reg_in, alu_src_in, branch_in, jump_in;
    reg [3:0] alu_control_in;

    wire [31:0] pc_out, pc_plus4_out;
    wire [31:0] read_data1_out, read_data2_out, immediate_out;

    wire [4:0] rs1_out, rs2_out, rd_out;
    wire [2:0] funct3_out;
    wire [6:0] funct7_out;

    wire reg_write_out, mem_read_out, mem_write_out;
    wire mem_to_reg_out, alu_src_out, branch_out, jump_out;
    wire [3:0] alu_control_out;

    integer passed, failed;

    id_ex_register uut (
        .clk(clk),
        .reset(reset),
        .flush(flush),

        .pc_in(pc_in),
        .pc_plus4_in(pc_plus4_in),
        .read_data1_in(read_data1_in),
        .read_data2_in(read_data2_in),
        .immediate_in(immediate_in),

        .rs1_in(rs1_in),
        .rs2_in(rs2_in),
        .rd_in(rd_in),

        .funct3_in(funct3_in),
        .funct7_in(funct7_in),

        .reg_write_in(reg_write_in),
        .mem_read_in(mem_read_in),
        .mem_write_in(mem_write_in),
        .mem_to_reg_in(mem_to_reg_in),
        .alu_src_in(alu_src_in),
        .branch_in(branch_in),
        .jump_in(jump_in),
        .alu_control_in(alu_control_in),

        .pc_out(pc_out),
        .pc_plus4_out(pc_plus4_out),
        .read_data1_out(read_data1_out),
        .read_data2_out(read_data2_out),
        .immediate_out(immediate_out),

        .rs1_out(rs1_out),
        .rs2_out(rs2_out),
        .rd_out(rd_out),

        .funct3_out(funct3_out),
        .funct7_out(funct7_out),

        .reg_write_out(reg_write_out),
        .mem_read_out(mem_read_out),
        .mem_write_out(mem_write_out),
        .mem_to_reg_out(mem_to_reg_out),
        .alu_src_out(alu_src_out),
        .branch_out(branch_out),
        .jump_out(jump_out),
        .alu_control_out(alu_control_out)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 0;
        flush = 0;

        pc_in = 0;
        pc_plus4_in = 0;
        read_data1_in = 0;
        read_data2_in = 0;
        immediate_in = 0;

        rs1_in = 0;
        rs2_in = 0;
        rd_in = 0;
        funct3_in = 0;
        funct7_in = 0;

        reg_write_in = 0;
        mem_read_in = 0;
        mem_write_in = 0;
        mem_to_reg_in = 0;
        alu_src_in = 0;
        branch_in = 0;
        jump_in = 0;
        alu_control_in = 0;

        passed = 0;
        failed = 0;

        $dumpfile("waveforms/id_ex_register.vcd");
        $dumpvars(0, id_ex_register_tb);

        // TEST 1: Reset
        @(negedge clk);
        reset = 1;

        @(posedge clk);
        #1;

        if (pc_out === 0 &&
            read_data1_out === 0 &&
            rd_out === 0 &&
            reg_write_out === 0 &&
            mem_write_out === 0) begin
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

        pc_in = 32'h00000004;
        pc_plus4_in = 32'h00000008;
        read_data1_in = 32'h0000000A;
        read_data2_in = 32'h00000014;
        immediate_in = 32'h00000020;

        rs1_in = 5'd1;
        rs2_in = 5'd2;
        rd_in = 5'd3;

        funct3_in = 3'b000;
        funct7_in = 7'b0000000;

        reg_write_in = 1;
        mem_read_in = 0;
        mem_write_in = 0;
        mem_to_reg_in = 0;
        alu_src_in = 0;
        branch_in = 0;
        jump_in = 0;
        alu_control_in = 4'b0000;

        @(posedge clk);
        #1;

        if (pc_out === 32'h00000004 &&
            pc_plus4_out === 32'h00000008 &&
            read_data1_out === 32'h0000000A &&
            read_data2_out === 32'h00000014 &&
            immediate_out === 32'h00000020 &&
            rs1_out === 5'd1 &&
            rs2_out === 5'd2 &&
            rd_out === 5'd3 &&
            funct3_out === 3'b000 &&
            funct7_out === 7'b0000000 &&
            reg_write_out === 1'b1 &&
            alu_control_out === 4'b0000) begin
            $display("TEST 2 PASSED: Data and control transfer");
            passed = passed + 1;
        end
        else begin
            $display("TEST 2 FAILED: Data and control transfer");
            failed = failed + 1;
        end

        // TEST 3: Flush clears data and control signals
        @(negedge clk);
        flush = 1;

        @(posedge clk);
        #1;

        if (pc_out === 0 &&
            pc_plus4_out === 0 &&
            read_data1_out === 0 &&
            read_data2_out === 0 &&
            immediate_out === 0 &&
            rs1_out === 0 &&
            rs2_out === 0 &&
            rd_out === 0 &&
            reg_write_out === 0 &&
            mem_read_out === 0 &&
            mem_write_out === 0 &&
            mem_to_reg_out === 0 &&
            alu_src_out === 0 &&
            branch_out === 0 &&
            jump_out === 0 &&
            alu_control_out === 0) begin
            $display("TEST 3 PASSED: Flush");
            passed = passed + 1;
        end
        else begin
            $display("TEST 3 FAILED: Flush");
            failed = failed + 1;
        end

        $display("--------------------------------");
        $display("ID/EX REGISTER TEST SUMMARY");
        $display("PASSED: %0d", passed);
        $display("FAILED: %0d", failed);
        $display("--------------------------------");

        $finish;

    end

endmodule
