/*
~~~ Example instruction ~~~
addi x1, x2, 10
Add constant "10" [00001010] to the contents of x2 at address [00010000 00000000 00000001] (using ALU opcode [0000])


~~~ PC (program counter) ~~~
Holds address of next instruction to execute (can either increment, jump to, or halt at an instruction)

~~~ CU (control unit) ~~~
Orchestreates all operations (such as when memory should be read/written) using an opcode

~~~ ALU (arithmetic logic unit) ~~~
Runs arithmetic or logical operations on data (using an opcode, that selects the type of operation)

~~~ MAR (memory address register) ~~~
A register that stores the address of the memory location (address) from which data is written to/read from (acts like an interface between the CPU and memory)

~~~ MBR (memory buffer register) ~~~
A temporary storage register that holds data being transferred to/from memory (acts like a buffer between the CPU and memory)

~~~ IR (instruction register) ~~~
A register that holds the current instruction being executed (holds the instruction until it's decoded and executed)


~~~ Fetch Phase ~~~
1) Address Transfer - The address for the instruction, held in the PC, is copied into the MAR
2) Memory Read Command - The CU issues a read command to the memory, instructing it to retrieve the data at the address specified by the MAR
3) Data Retrieval - The retrieved instruction is placed into the MBR
4) Instruction Transfer - Finally, the instruction from the MBR is transferred to the IR for decoding (PC is also generally incremented)

~~~ Decode Phase ~~~
1) Opcode Analysis - The CU analyzes the opcode of the instruction stored in the IR to determine what operation needs to be performed
2) Operand Identification - The instruction is broken down into its components, identifying which registers or constants are needed for execution
3) Control Signal Generation - The CU sends control signals to fetch any necessary constants from memory (i.e. loading additional operands)

~~~ Execute Phase ~~~
1) ALU Operation - Once all necessary values are available, they are sent to the ALU along with the opcode indicating what operation should be performed (e.g., addition)
2) Result Handling - Operation output is sent back to the designated register as specified by the instruction (either via direct transfer or MBR/MAR if interfacing with memory)
3) Storage of Result - If needed, results can be stored back into RAM or another memory location based on further instructions or as part of subsequent operations
*/

module top_tb;
	reg reset;
    reg clk_enable;
    reg lsi_enable;
    wire clk;
    wire lsi_clk;
    wire wdt_clk;

    reg we;
    reg re;
    reg [11:0] addr;
    reg [7:0] in;
    wire [7:0] out;

	reg [7:0] A, B;
    reg [3:0] opcode;
    wire [7:0] result;
    wire carry_out;

    clock clk_inst (
        .reset(reset),
        .clk_enable(clk_enable),
        .lsi_enable(lsi_enable),
        .clk(clk),
        .lsi_clk(lsi_clk),
        .wdt_clk(wdt_clk)
    );

    memory mem_inst (
        .clk(clk),
        .we(we),
        .re(re),
        .addr(addr),
        .in(in),
        .out(out)
    );

	alu alu_inst (
        .A(A),
        .B(B),
        .opcode(opcode),
        .result(result),
        .carry_out(carry_out)
    );

    initial begin
		// clock
        reset = 1;
        clk_enable = 0;
        lsi_enable = 0;

		// memory
		addr = 12'bz;
		in = 8'bz;
        we = 0;
        re = 0;

		// alu
		A = 8'bz;
		B = 8'bz;
		opcode = 4'bz;

        #1
		reset = 0;
        
        #10
		clk_enable = 1;

		#10

        $finish;
    end
endmodule