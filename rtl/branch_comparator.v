
module branch_comparator (
    input wire [31:0] operand_a,
    input wire [31:0] operand_b,
    input wire [2:0] funct3,

    output reg branch_taken
);

    always @(*) begin

        branch_taken = 1'b0;

        case (funct3)

            // BEQ: Branch if equal
            3'b000:
                branch_taken = (operand_a == operand_b);

            // BNE: Branch if not equal
            3'b001:
                branch_taken = (operand_a != operand_b);

            default:
                branch_taken = 1'b0;

        endcase

    end

endmodule
