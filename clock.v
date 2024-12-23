module clock (
    input wire reset,
    input wire clk_enable,
    input wire lsi_enable,
    output reg clk,
    output reg lsi_clk,
    output reg wdt_clk
);

    reg internal_clk_enable;

    initial begin
        clk = 0;
        lsi_clk = 0;
        wdt_clk = 0;
        internal_clk_enable = 0;
    end

    // Set internal_clk_enable high when reset is low
    always @(negedge reset) begin
        internal_clk_enable <= 1'b1;
    end

    // main clock (operational main clock for all services)
    always #5 begin
        if (!reset && internal_clk_enable && clk_enable) begin
            clk <= ~clk;
        end else begin
            clk <= 0;
        end
    end

    // low-speed internal oscillator (low-power clock source for sleep mode)
    always #50 begin
        if (lsi_enable) begin
            lsi_clk <= ~lsi_clk;
        end
    end

    // watchdog timer clock (clock to detect system hangs)
    always #100 begin
        wdt_clk <= ~wdt_clk;
    end

endmodule

