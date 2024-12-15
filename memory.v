/*
Structure

mem0[0] - 8 bits
mem0[1] - 8 bits
mem0[2] - 8 bits
...
mem0[1023] - 8 bits
*/

module memory (
    input wire clk, // clock signal
    input wire we, // write enable signal
    input wire [11:0] addr, // 12-bit address input (10-bit address pointer and 2-bit block selector)
    input wire [7:0] in, // 8-bit input data
    output reg [7:0] out // 8-bit output data
);
    reg [7:0] mem0 [0:1023]; // 8-bit wide memory with 1024 locations in mem0
    reg [7:0] mem1 [0:1023]; // 8-bit wide memory with 1024 locations in mem1
    reg [7:0] mem2 [0:1023]; // 8-bit wide memory with 1024 locations in mem2
    reg [7:0] mem3 [0:1023]; // 8-bit wide memory with 1024 locations in mem3
    
    always @(posedge clk) begin
		// WRITE
        if (we) begin     
            case (addr[11:10]) // sel mem block based on 2 MSBs of address
                2'b00: mem0[addr[9:0]] <= in;
                2'b01: mem1[addr[9:0]] <= in;
                2'b10: mem2[addr[9:0]] <= in;
                2'b11: mem3[addr[9:0]] <= in;
            endcase
        end

        // READ
        case (addr[11:10])
            2'b00: out <= mem0[addr[9:0]];
            2'b01: out <= mem1[addr[9:0]];
            2'b10: out <= mem2[addr[9:0]];
            2'b11: out <= mem3[addr[9:0]];
        endcase
    end
endmodule