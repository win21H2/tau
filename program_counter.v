module program_counter (
    input wire clk,
    input wire reset,
    input wire [1:0] pc_control, // 00: hold, 01: increment, 10: branch, 11: jump
    input wire [15:0] branch_address,
    input wire [15:0] jump_address,
    output reg [15:0] pc_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_out <= 16'b0;
        end
		else begin
            case (pc_control)
                2'b00: pc_out <= pc_out; // hold
                2'b01: pc_out <= pc_out + 1; // increment
                2'b10: pc_out <= branch_address; // branch
                2'b11: pc_out <= jump_address; // jump
            endcase
        end
    end
endmodule