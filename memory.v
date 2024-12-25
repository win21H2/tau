/*
Structure

mem0[0] - 8 bits
mem0[1] - 8 bits
mem0[2] - 8 bits
...
mem0[1023] - 8 bits
*/

module memory (
    input wire clk,
    input wire we,
    input wire re,
    input wire [11:0] addr, // 12-bit address input (10-bit address pointer and 2-bit block selector at MSBs)
    input wire [7:0] in,
    output reg [7:0] out
);
    reg [7:0] mem0 [0:1023];
    reg [7:0] mem1 [0:1023];
    reg [7:0] mem2 [0:1023];
    reg [7:0] mem3 [0:1023];

    always @(posedge clk) begin
        // WRITE
        if (we) begin     
            case (addr[11:10]) // select mem block based on 2 MSBs of address
                2'b00: mem0[addr[9:0]] <= in;
                2'b01: mem1[addr[9:0]] <= in;
                2'b10: mem2[addr[9:0]] <= in;
                2'b11: mem3[addr[9:0]] <= in;
            endcase
        end

        // READ
        if (re) begin
            case (addr[11:10])
                2'b00: out <= mem0[addr[9:0]];
                2'b01: out <= mem1[addr[9:0]];
                2'b10: out <= mem2[addr[9:0]];
                2'b11: out <= mem3[addr[9:0]];
            endcase
        end
    end
endmodule