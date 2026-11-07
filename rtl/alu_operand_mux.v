
module alu_operand_mux (
    input wire [31:0] forwarded_register_data,
    input wire [31:0] immediate,
    input wire alu_src,

    output reg [31:0] alu_operand
);

    always @(*) begin
        if (alu_src)
            alu_operand = immediate;
        else
            alu_operand = forwarded_register_data;
    end

endmodule
