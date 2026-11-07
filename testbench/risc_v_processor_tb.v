
`timescale 1ns/1ps

module risc_v_processor_tb;

    reg clk;
    reg reset;

    risc_v_processor uut (
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("waveforms/risc_v_processor.vcd");
        $dumpvars(0, risc_v_processor_tb);

        clk = 0;
        reset = 1;

        #20;
        reset = 0;

        // Allow the pipeline to complete execution
        #200;

        $display("");
        $display("================================");
        $display("RISC-V PROCESSOR VERIFICATION");
        $display("================================");

        $display("Register x1 = %0d",
            uut.decode_unit.register_file_unit.registers[1]);

        $display("Register x2 = %0d",
            uut.decode_unit.register_file_unit.registers[2]);

        $display("Register x3 = %0d",
            uut.decode_unit.register_file_unit.registers[3]);

        $display("Register x4 = %0d",
            uut.decode_unit.register_file_unit.registers[4]);

        $display("--------------------------------");

        if (
            uut.decode_unit.register_file_unit.registers[1] == 10 &&
            uut.decode_unit.register_file_unit.registers[2] == 20 &&
            uut.decode_unit.register_file_unit.registers[3] == 30 &&
            uut.decode_unit.register_file_unit.registers[4] == 30
        )
            $display("PROCESSOR TEST: PASSED");
        else
            $display("PROCESSOR TEST: FAILED");

        $display("================================");

        $finish;
    end

endmodule
