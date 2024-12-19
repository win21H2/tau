module top_tb;
    reg reset;
    reg clk_enable;
    reg lsi_enable;

    reg we;
    reg re;
    reg [11:0] addr;
    reg [7:0] in;
    wire [7:0] out;
    wire clk;

    clock clk_inst (
        .reset(reset),
        .clk_enable(clk_enable),
        .lsi_enable(lsi_enable),
        .clk(clk)
    );

    memory mem_inst (
        .clk(clk),
        .we(we),
        .re(re),
        .addr(addr),
        .in(in),
        .out(out)
    );

    initial begin
        reset = 1;
        clk_enable = 0;
        lsi_enable = 0;
        we = 0;
        re = 0;
        addr = 12'b000000000000;
        in = 8'b00000000;

        #10
		reset = 0;
        
        #10
		clk_enable = 1;

		// WRITE
        we = 1; re = 0; addr = 12'b000000000000; in = 8'hAA; // AA to mem0[0]
        #10

        addr = 12'b000000000001; in = 8'hBB; // BB to mem0[1]
        #10

        addr = 12'b010000000000; in = 8'hCC; // CC to mem1[0]
        #10

        addr = 12'b100000000001; in = 8'hDD; // DD to mem2[1]
        #10

        addr = 12'b110000000010; in = 8'hEE; // EE to mem3[2]
        #10

        we = 0;
		re = 1;

		// READ
        addr = 12'b000000000000; // mem0[0]
        #10
        
        addr = 12'b000000000001; // mem0[1]
        #10

        addr = 12'b010000000000; // mem1[0]
        #10

        addr = 12'b100000000001; // mem2[1]
        #10

        addr = 12'b110000000010; // mem3[2]
        #10

        $finish;
    end
endmodule