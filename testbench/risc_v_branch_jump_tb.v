`timescale 1ns/1ps

module risc_v_branch_jump_tb;

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

        // Branch and jump test program
        uut.fetch_unit.instruction_memory_unit.memory[0] = 32'h00500093; // ADDI x1,x0,5
        uut.fetch_unit.instruction_memory_unit.memory[1] = 32'h00500113; // ADDI x2,x0,5
        uut.fetch_unit.instruction_memory_unit.memory[2] = 32'h00208463; // BEQ x1,x2,+8
        uut.fetch_unit.instruction_memory_unit.memory[3] = 32'h06300193; // Skipped
        uut.fetch_unit.instruction_memory_unit.memory[4] = 32'h00209463; // BNE x1,x2,+8
        uut.fetch_unit.instruction_memory_unit.memory[5] = 32'h00700213; // ADDI x4,x0,7
        uut.fetch_unit.instruction_memory_unit.memory[6] = 32'h008002EF; // JAL x5,+8
        uut.fetch_unit.instruction_memory_unit.memory[7] = 32'h06300313; // Skipped
        uut.fetch_unit.instruction_memory_unit.memory[8] = 32'h00B00393; // ADDI x7,x0,11

        #19;
        reset = 0;

        #300;

        $display("BRANCH AND JUMP VERIFICATION");
        $display("-----------------------------");

        $display("x1 = %0d", uut.decode_unit.register_file_unit.registers[1]);
        $display("x2 = %0d", uut.decode_unit.register_file_unit.registers[2]);
        $display("x3 = %0d", uut.decode_unit.register_file_unit.registers[3]);
        $display("x4 = %0d", uut.decode_unit.register_file_unit.registers[4]);
        $display("x5 = %0d", uut.decode_unit.register_file_unit.registers[5]);
        $display("x6 = %0d", uut.decode_unit.register_file_unit.registers[6]);
        $display("x7 = %0d", uut.decode_unit.register_file_unit.registers[7]);

        if (
            uut.decode_unit.register_file_unit.registers[1] == 5 &&
            uut.decode_unit.register_file_unit.registers[2] == 5 &&
            uut.decode_unit.register_file_unit.registers[3] == 0 &&
            uut.decode_unit.register_file_unit.registers[4] == 7 &&
            uut.decode_unit.register_file_unit.registers[5] == 28 &&
            uut.decode_unit.register_file_unit.registers[6] == 0 &&
            uut.decode_unit.register_file_unit.registers[7] == 11
        )
            $display("BRANCH AND JUMP TEST: PASSED");
        else
            $display("BRANCH AND JUMP TEST: FAILED");

        $finish;
    end

endmodule