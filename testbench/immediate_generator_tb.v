
`timescale 1ns/1ps

module immediate_generator_tb;

    reg  [31:0] instruction;
    reg  [1:0]  imm_type;

    wire [31:0] immediate;

    // Instantiate Immediate Generator
    immediate_generator uut (
        .instruction(instruction),
        .imm_type(imm_type),
        .immediate(immediate)
    );

    initial begin

        $dumpfile("waveforms/immediate_generator.vcd");
        $dumpvars(0, immediate_generator_tb);

        // Test 1: I-type positive immediate (+10)
        instruction = {12'd10, 5'd0, 3'b000, 5'd1, 7'b0010011};
        imm_type = 2'b00;
        #10;

        if (immediate === 32'd10)
            $display("TEST 1 PASSED: I-type positive");
        else
            $display("TEST 1 FAILED: Got %h", immediate);

        // Test 2: I-type negative immediate (-1)
        instruction = {12'hFFF, 20'b0};
        imm_type = 2'b00;
        #10;

        if (immediate === 32'hFFFFFFFF)
            $display("TEST 2 PASSED: I-type sign extension");
        else
            $display("TEST 2 FAILED: Got %h", immediate);

        // Test 3: S-type immediate (-4)
        instruction = {
            7'b1111111,
            5'd2,
            5'd1,
            3'b010,
            5'b11100,
            7'b0100011
        };
        imm_type = 2'b01;
        #10;

        if (immediate === 32'hFFFFFFFC)
            $display("TEST 3 PASSED: S-type");
        else
            $display("TEST 3 FAILED: Got %h", immediate);

        // Test 4: B-type immediate (+8)
        instruction = {
            1'b0,
            6'b000000,
            5'd2,
            5'd1,
            3'b000,
            4'b0100,
            1'b0,
            7'b1100011
        };
        imm_type = 2'b10;
        #10;

        if (immediate === 32'd8)
            $display("TEST 4 PASSED: B-type");
        else
            $display("TEST 4 FAILED: Got %h", immediate);

        // Test 5: J-type immediate (+16)
        instruction = {
            1'b0,
            10'd8,
            1'b0,
            8'd0,
            5'd1,
            7'b1101111
        };
        imm_type = 2'b11;
        #10;

        if (immediate === 32'd16)
            $display("TEST 5 PASSED: J-type");
        else
            $display("TEST 5 FAILED: Got %h", immediate);

        $display("--------------------------------");
        $display("IMMEDIATE GENERATOR TESTING DONE");
        $display("--------------------------------");

        $finish;

    end

endmodule
