
`timescale 1ns/1ps

module alu_tb;

    reg  [31:0] a;
    reg  [31:0] b;
    reg  [3:0]  alu_control;

    wire [31:0] result;
    wire        zero;

    // Instantiate the ALU
    alu uut (
        .a(a),
        .b(b),
        .alu_control(alu_control),
        .result(result),
        .zero(zero)
    );

    initial begin

        $dumpfile("waveforms/alu.vcd");
        $dumpvars(0, alu_tb);

        // Test 1: Addition
        a = 32'd10;
        b = 32'd5;
        alu_control = 4'b0000;
        #10;
        $display("ADD: %d + %d = %d", a, b, result);
        if (result !== 32'd15) $display("ADD FAILED");
        else $display("ADD PASSED");

        // Test 2: Subtraction
        a = 32'd10;
        b = 32'd5;
        alu_control = 4'b0001;
        #10;
        $display("SUB: %d - %d = %d", a, b, result);
        if (result !== 32'd5) $display("SUB FAILED");
        else $display("SUB PASSED");

        // Test 3: AND
        a = 32'hF0F0;
        b = 32'h0FF0;
        alu_control = 4'b0010;
        #10;
        $display("AND: %h", result);
        if (result !== 32'h00F0) $display("AND FAILED");
        else $display("AND PASSED");

        // Test 4: OR
        a = 32'hF000;
        b = 32'h00F0;
        alu_control = 4'b0011;
        #10;
        $display("OR: %h", result);
        if (result !== 32'hF0F0) $display("OR FAILED");
        else $display("OR PASSED");

        // Test 5: XOR
        a = 32'hAAAA;
        b = 32'hFFFF;
        alu_control = 4'b0100;
        #10;
        $display("XOR: %h", result);
        if (result !== 32'h5555) $display("XOR FAILED");
        else $display("XOR PASSED");

        // Test 6: Zero flag
        a = 32'd10;
        b = 32'd10;
        alu_control = 4'b0001;
        #10;
        $display("ZERO FLAG: %b", zero);
        if (zero !== 1'b1) $display("ZERO FLAG FAILED");
        else $display("ZERO FLAG PASSED");

        $display("--------------------------------");
        $display("ALU TESTING COMPLETED");
        $display("--------------------------------");

        $finish;

    end

endmodule
