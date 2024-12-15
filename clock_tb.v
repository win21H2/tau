/*
SYS CLOCK
*/

module clock_tb;
    reg reset;
    reg clk_enable;
    reg lsi_enable;
    
    wire clk;
    wire pll_clk;
    wire lsi_clk;
    wire wdt_clk;

    clock u0 (
        .reset(reset),
        .clk_enable(clk_enable),
        .lsi_enable(lsi_enable),
        .clk(clk),
        .pll_clk(pll_clk),
        .lsi_clk(lsi_clk),
        .wdt_clk(wdt_clk)
    );

    initial begin
        reset = 1;
        clk_enable = 0;
        lsi_enable = 0;

        #10
		reset = 0;
        
        #10
		clk_enable = 1;
        
        #20
		lsi_enable = 1;
        
        #50
		clk_enable = 0;
        
        #20
		reset = 1;
        
        #10
		reset = 0;
        
        #100
        
        $finish;
    end
endmodule