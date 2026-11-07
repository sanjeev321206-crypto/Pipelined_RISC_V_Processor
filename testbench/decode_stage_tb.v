
`timescale 1ns/1ps

module decode_stage_tb;

    reg clk;
    reg [31:0] instruction;

    reg reg_write_wb;
    reg [4:0] rd_wb;
    reg [31:0] writeback_data;

    wire [31:0] read_data1;
    wire [31:0] read_data2;

    wire [4:0] rs1, rs2, rd;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [31:0] immediate;

    wire reg_write;
    wire mem_read;
    wire mem_write;
    wire mem_to_reg;
    wire alu_src;
    wire branch;
    wire jump;

    wire [3:0] alu_control;
    wire [1:0] imm_type;

    integer passed = 0;
    integer failed = 0;

    decode_stage dut (
        .clk(clk),
        .instruction(instruction),

        .reg_write_wb(reg_write_wb),
        .rd_wb(rd_wb),
        .writeback_data(writeback_data),

        .read_data1(read_data1),
        .read_data2(read_data2),

        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),

        .funct3(funct3),
        .funct7(funct7),

        .immediate(immediate),

        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .alu_src(alu_src),
        .branch(branch),
        .jump(jump),

        .alu_control(alu_control),
        .imm_type(imm_type)
    );

    always #5 clk = ~clk;

    task check;
        input condition;
        input [255:0] test_name;
        begin
            #1;
            if (condition === 1'b1) begin
                $display("PASS: %0s", test_name);
                passed = passed + 1;
            end
            else begin
                $display("FAIL: %0s", test_name);
                failed = failed + 1;
            end
        end
    endtask

    initial begin

        $dumpfile("waveforms/decode_stage.vcd");
        $dumpvars(0, decode_stage_tb);

        clk = 0;
        instruction = 32'h00000013;

        reg_write_wb = 0;
        rd_wb = 0;
        writeback_data = 0;

        // Test 1: ADDI register fields
        instruction = 32'h00A00093;
        #1;
        check(rs1 == 0 && rd == 1,
              "ADDI instruction register fields");

        // Test 2: ADDI immediate
        check(immediate == 32'd10,
              "ADDI immediate generation");

        // Test 3: ADDI control signals
        check(reg_write && alu_src && !mem_read &&
              !mem_write && !branch && !jump,
              "ADDI control signals");

        // Test 4: Write x5 through writeback interface
        @(negedge clk);
        reg_write_wb = 1;
        rd_wb = 5'd5;
        writeback_data = 32'd42;

        @(posedge clk);
        #1;
        reg_write_wb = 0;

        // Test 5: Decode ADD x6, x5, x0
        instruction = 32'h00028333;
        #1;
        check(rs1 == 5 && rs2 == 0 && rd == 6,
              "ADD instruction register fields");

        // Test 6: Register file read
        check(read_data1 == 32'd42 && read_data2 == 32'd0,
              "Register file reads correct values");

        // Test 7: R-type control signals
        check(reg_write && !alu_src &&
              !mem_read && !mem_write,
              "R-type control signals");

        // Test 8: BEQ decoding
        instruction = 32'h00208463;
        #1;
        check(branch && !reg_write && !mem_write,
              "BEQ control signals");

        // Test 9: LW decoding
        instruction = 32'h00002203;
        #1;
        check(mem_read && mem_to_reg &&
              reg_write && alu_src,
              "LW control signals");

        // Test 10: LW immediate
        check(immediate == 32'd0,
              "LW immediate generation");

        $display("--------------------------------");
        $display("Decode Stage Results");
        $display("Passed: %0d", passed);
        $display("Failed: %0d", failed);
        $display("--------------------------------");

        $finish;

    end

endmodule
