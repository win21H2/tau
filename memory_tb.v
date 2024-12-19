module memory_tb;
    reg clk;
    reg we;
    reg re;
    reg [11:0] addr;
    reg [7:0] in;
    wire [7:0] out;

    memory u0 (
        .clk(clk), 
        .we(we), 
        .re(re),
        .addr(addr), 
        .in(in), 
        .out(out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        we = 0;
        re = 0;
        addr = 0;
        in = 0;
        
        // WRITE
        we = 1;
        re = 0;

        addr = 12'h000; in = 8'hA1; #10
        addr = 12'h200; in = 8'hA2; #10
        addr = 12'h3FF; in = 8'hA3; #10

        addr = 12'h400; in = 8'hB1; #10
        addr = 12'h600; in = 8'hB2; #10
        addr = 12'h7FF; in = 8'hB3; #10

        addr = 12'h800; in = 8'hC1; #10
        addr = 12'hA00; in = 8'hC2; #10
        addr = 12'hBFF; in = 8'hC3; #10

        addr = 12'hC00; in = 8'hD1; #10
        addr = 12'hE00; in = 8'hD2; #10
        addr = 12'hFFF; in = 8'hD3; #10

        #100

        // READ
        we = 0;
        re = 1;
        #10

        addr = 12'h000; #10
        addr = 12'h200; #10
        addr = 12'h3FF; #10

        addr = 12'h400; #10
        addr = 12'h600; #10
        addr = 12'h7FF; #10

        addr = 12'h800; #10
        addr = 12'hA00; #10
        addr = 12'hBFF; #10

        addr = 12'hC00; #10
        addr = 12'hE00; #10
        addr = 12'hFFF; #10

        // Test read disable
        re = 0;
        #10
        addr = 12'h000; #10

        $finish;
    end
endmodule