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
		lsi_enable = 1;

		#100

        $finish;
    end
endmodule