`timescale 1ns/1ps

module load_use_hazard_tb;

    reg clk;
    reg reset;

    risc_v_processor uut (
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;

        #1;

        // Initialize data memory: address 0 contains 42
        uut.memory_unit.data_memory_unit.memory[0] = 8'd42;
        uut.memory_unit.data_memory_unit.memory[1] = 8'd0;
        uut.memory_unit.data_memory_unit.memory[2] = 8'd0;
        uut.memory_unit.data_memory_unit.memory[3] = 8'd0;

        // Program: LW followed immediately by dependent ADDI
        uut.fetch_unit.instruction_memory_unit.memory[0] = 32'h00002083; // LW x1,0(x0)
        uut.fetch_unit.instruction_memory_unit.memory[1] = 32'h00108113; // ADDI x2,x1,1
        uut.fetch_unit.instruction_memory_unit.memory[2] = 32'h002081B3; // ADD x3,x1,x2

        #19;
        reset = 0;

        #200;

        $display("");
        $display("LOAD-USE HAZARD VERIFICATION");
        $display("----------------------------");
        $display("x1 = %0d (expected 42)",
            uut.decode_unit.register_file_unit.registers[1]);
        $display("x2 = %0d (expected 43)",
            uut.decode_unit.register_file_unit.registers[2]);
        $display("x3 = %0d (expected 85)",
            uut.decode_unit.register_file_unit.registers[3]);

        if (
            uut.decode_unit.register_file_unit.registers[1] == 42 &&
            uut.decode_unit.register_file_unit.registers[2] == 43 &&
            uut.decode_unit.register_file_unit.registers[3] == 85
        )
            $display("LOAD-USE HAZARD TEST: PASSED");
        else
            $display("LOAD-USE HAZARD TEST: FAILED");

        $finish;
    end

endmodule