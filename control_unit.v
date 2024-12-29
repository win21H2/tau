/*
CU REFERENCE

INSERTION/REMOVAL
[OP 0000] - LOAD
[OP 1111] - STORE
*/

module control_unit (
    input wire [6:0] cu_op,
    output reg [3:0] alu_op,
    output reg mem_read,
    output reg mem_write
);

    always @(*) begin
        case(cu_op)
            7'b0000000: begin // load
                alu_op = 4'bx;
                mem_read = 1'b1;
                mem_write = 1'b0;
            end
            7'b0010011: begin // addi
                alu_op = 4'b0000;
                mem_read = 1'b0;
                mem_write = 1'b0;
            end
            7'b1111111: begin // store
                alu_op = 4'bx;
                mem_read = 1'b0;
                mem_write = 1'b1;
            end
            default: begin
                alu_op = 4'bx;
                mem_read = 1'bx;
                mem_write = 1'bx;
            end
        endcase
    end
endmodule