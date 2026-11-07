
module immediate_generator (
    input  wire [31:0] instruction,
    input  wire [1:0]  imm_type,

    output reg  [31:0] immediate
);

    // Immediate format selection
    localparam IMM_I = 2'b00;
    localparam IMM_S = 2'b01;
    localparam IMM_B = 2'b10;
    localparam IMM_J = 2'b11;

    always @(*) begin

        case (imm_type)

            // I-type: ADDI, LW
            IMM_I: begin
                immediate = {
                    {20{instruction[31]}},
                    instruction[31:20]
                };
            end

            // S-type: SW
            IMM_S: begin
                immediate = {
                    {20{instruction[31]}},
                    instruction[31:25],
                    instruction[11:7]
                };
            end

            // B-type: BEQ, BNE
            IMM_B: begin
                immediate = {
                    {19{instruction[31]}},
                    instruction[31],
                    instruction[7],
                    instruction[30:25],
                    instruction[11:8],
                    1'b0
                };
            end

            // J-type: JAL
            IMM_J: begin
                immediate = {
                    {11{instruction[31]}},
                    instruction[31],
                    instruction[19:12],
                    instruction[20],
                    instruction[30:21],
                    1'b0
                };
            end

            default: immediate = 32'b0;

        endcase

    end

endmodule
