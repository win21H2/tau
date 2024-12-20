module clock (
    input wire reset,
    input wire clk_enable,
    input wire lsi_enable,
    output reg clk,
    output reg lsi_clk,
    output reg wdt_clk
);

    initial begin
        clk = 0;
        lsi_clk = 0;
        wdt_clk = 0;
    end

	// main clock (operational main clock for all services)
    always begin
        #5

        if (!reset) begin
            if (clk_enable) begin
                clk = ~clk;
            end
			else begin
                clk = clk;
            end
        end
		else begin
            clk = 0;
        end
    end

    // low-speed internal oscillator (low-power clock source for sleep mode)
    always begin
        #50
        if (lsi_enable) begin
            lsi_clk <= ~lsi_clk;
        end else begin
            lsi_clk <= lsi_clk;
        end
    end

    // watchdog timer clock (clock to detect system hangs)
    always begin
        #100
        wdt_clk <= ~wdt_clk; 
    end
endmodule