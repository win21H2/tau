module program_counter (
    input wire clk,
    input wire reset,
    input wire [1:0] pc_control, // 00: hold, 01: increment
    output reg [23:0] pc_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_out <= 24'b0;	
        end
		else begin
            case (pc_control)
                2'b00: pc_out <= pc_out; // hold
                2'b01: pc_out <= pc_out + 1; // increment
            endcase
        end
    end
endmodule