module top_tb;
	reg reset;
    reg clk_enable;
    reg lsi_enable;
    wire clk;
    wire pll_clk;
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
        .pll_clk(pll_clk),
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


        we = 1;
		re = 0;

		addr = 12'b000000000000; in = 8'b00000010;

		#10
		addr = 12'b100000000000; in = 8'b11111111;

		#10
        we = 0;
		re = 1;

        addr = 12'b000000000000;
        #10
		A = out;
		#10

		addr = 12'b100000000000;
        #10
		B = out;
		#10

		opcode = 4'b0000;
		
		#10
		we = 1;
		re = 0;

		addr = 12'b010000000000; in = result;
		
		#10
		we = 0;
		re = 1;

		addr = 12'b010000000000;
		#10
		A = out;
		#10
		
		B = 8'b00001111;
		opcode = 4'b1000;

		#10
		we = 0;
		re = 0;

        $finish;
    end
endmodule