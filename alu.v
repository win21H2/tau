/*
ALU REFERENCE

ARITHMETIC
[OP 0000] - ADD
[OP 0001] - SUB
[OP 0010] - INC
[OP 0100] - DEC

LOGIC
[OP 1000] - AND
[OP 1001] - OR
[OP 1010] - NOT
[OP 1100] - XOR

SHIFTS
[OP 1110] - SL
[OP 0111] - SR

NO OPERATION
[OP 0110] - NO OPERATION
*/

module alu (
    input [7:0] A, B,
    input [3:0] opcode,
    output reg [7:0] result,
    output reg carry_out
);

    always @(*) begin
        carry_out = 1'b0;

        case(opcode)
            4'b0000: {carry_out, result} = A + B;
            4'b0001: {carry_out, result} = A - B;
			4'b0010: result = A + 1;
            4'b0100: result = A - 1;

            4'b1000: result = A & B;
            4'b1001: result = A | B;
            4'b1010: result = ~A;
            4'b1100: result = A ^ B;

            4'b1110: result = A << 1;
            4'b0111: result = A >> 1;
            
            default: result = 8'bz;
        endcase
    end
endmodule