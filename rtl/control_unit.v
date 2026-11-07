
module control_unit (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,

    output reg        reg_write,
    output reg        mem_read,
    output reg        mem_write,
    output reg        mem_to_reg,
    output reg        alu_src,
    output reg        branch,
    output reg        jump,
    output reg [3:0]  alu_control,
    output reg [1:0]  imm_type
);

    // ALU operation codes
    localparam ALU_ADD = 4'b0000;
    localparam ALU_SUB = 4'b0001;
    localparam ALU_AND = 4'b0010;
    localparam ALU_OR  = 4'b0011;
    localparam ALU_XOR = 4'b0100;

    // Immediate format codes
    localparam IMM_I = 2'b00;
    localparam IMM_S = 2'b01;
    localparam IMM_B = 2'b10;
    localparam IMM_J = 2'b11;

    // RISC-V opcodes
    localparam OP_RTYPE  = 7'b0110011;
    localparam OP_ITYPE  = 7'b0010011;
    localparam OP_LOAD   = 7'b0000011;
    localparam OP_STORE  = 7'b0100011;
    localparam OP_BRANCH = 7'b1100011;
    localparam OP_JAL    = 7'b1101111;

    always @(*) begin

        // Safe default values
        reg_write  = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        alu_src    = 1'b0;
        branch     = 1'b0;
        jump       = 1'b0;
        alu_control = ALU_ADD;
        imm_type    = IMM_I;

        case (opcode)

            // R-type instructions
            OP_RTYPE: begin
                reg_write = 1'b1;

                case (funct3)

                    3'b000: begin
                        if (funct7 == 7'b0100000)
                            alu_control = ALU_SUB;
                        else if (funct7 == 7'b0000000)
                            alu_control = ALU_ADD;
                    end

                    3'b111: alu_control = ALU_AND;
                    3'b110: alu_control = ALU_OR;
                    3'b100: alu_control = ALU_XOR;

                    default: reg_write = 1'b0;

                endcase
            end

            // ADDI
            OP_ITYPE: begin
                if (funct3 == 3'b000) begin
                    reg_write = 1'b1;
                    alu_src = 1'b1;
                    alu_control = ALU_ADD;
                    imm_type = IMM_I;
                end
            end

            // LW
            OP_LOAD: begin
                if (funct3 == 3'b010) begin
                    reg_write = 1'b1;
                    mem_read = 1'b1;
                    mem_to_reg = 1'b1;
                    alu_src = 1'b1;
                    alu_control = ALU_ADD;
                    imm_type = IMM_I;
                end
            end

            // SW
            OP_STORE: begin
                if (funct3 == 3'b010) begin
                    mem_write = 1'b1;
                    alu_src = 1'b1;
                    alu_control = ALU_ADD;
                    imm_type = IMM_S;
                end
            end

            // BEQ and BNE
            OP_BRANCH: begin
                if (funct3 == 3'b000 || funct3 == 3'b001) begin
                    branch = 1'b1;
                    alu_control = ALU_SUB;
                    imm_type = IMM_B;
                end
            end

            // JAL
            OP_JAL: begin
                reg_write = 1'b1;
                jump = 1'b1;
                imm_type = IMM_J;
            end

            default: begin
                // Unsupported instruction: keep safe defaults
            end

        endcase

    end

endmodule
