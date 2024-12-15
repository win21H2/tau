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
*/

module alu_tb();
    reg [7:0] A, B;
    reg [3:0] opcode;
    wire [7:0] result;
    wire carry_out;

    alu u0 (
        .A(A),
        .B(B),
        .opcode(opcode),
        .result(result),
        .carry_out(carry_out)
    );

    initial begin
        A = 0;
        B = 0;
        opcode = 0;
        #10
        
        A = 8'b10101010;
        B = 8'b11001100;

        opcode = 4'b0000;
		#10   
		opcode = 4'b0001;
		#10   
		opcode = 4'b0010;
		#10        
		opcode = 4'b0100;
		#10
        
		opcode = 4'b1000;
		#10
		opcode = 4'b1001;
		#10
		opcode = 4'b1010;
		#10
		opcode = 4'b1100;
		#10
        
		opcode = 4'b1110;
		#10
		opcode = 4'b0111;
		#10

		// CARRY ADD
        A = 8'b11111111;
        B = 8'b00000001;
        opcode = 4'b0000;
		#10

		// CARRY SUB
        A = 8'b00000000;
        B = 8'b00000001;
        opcode = 4'b0001;
		#10

        $finish;
    end
endmodule