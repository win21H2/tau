module inst_reg (
    input wire clk,
    input wire reset,
    input wire ir_load,
    input wire [15:0] instruction_in,
    output reg [15:0] instruction_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            instruction_out <= 16'b0;
		end
        else if (ir_load) begin
            instruction_out <= instruction_in;
		end
    end
endmodule