
module fetch_stage (

    input wire clk,
    input wire reset,

    // Stall and flush controls
    input wire stall,
    input wire flush,

    // Branch and jump redirection
    input wire [31:0] redirect_pc,
    input wire redirect,

    // Fetch outputs
    output wire [31:0] pc_out,
    output wire [31:0] pc_plus4_out,
    output wire [31:0] instruction_out

);

    wire [31:0] current_pc;
    wire [31:0] fetched_instruction;
    wire [31:0] sequential_pc;
    wire [31:0] selected_next_pc;

    // Calculate sequential address
    assign sequential_pc = current_pc + 32'd4;

    // Select sequential address or branch/jump target
    assign selected_next_pc =
        redirect ? redirect_pc : sequential_pc;

    // Program Counter
    program_counter pc_unit (
        .clk(clk),
        .reset(reset),
        .enable(!stall),
        .next_pc(selected_next_pc),
        .pc(current_pc)
    );

    // Instruction Memory
    instruction_memory instruction_memory_unit (
        .address(current_pc),
        .instruction(fetched_instruction)
    );

    // IF/ID Pipeline Register
    if_id_register if_id_unit (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .flush(flush || redirect),
        .pc_in(current_pc),
        .pc_plus4_in(sequential_pc),
        .instruction_in(fetched_instruction),
        .pc_out(pc_out),
        .pc_plus4_out(pc_plus4_out),
        .instruction_out(instruction_out)
    );

endmodule
