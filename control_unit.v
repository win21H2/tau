module control_unit (
    input wire [3:0] opcode,
    output reg [3:0] alu_op,
    output reg pc_load,
    output reg ir_load,
    output reg mem_read,
    output reg mem_write,
    output reg reg_write
);

    always @(*) begin
        case(opcode)
            4'b0000: begin // load
                alu_op = 4'b0000;
                pc_load = 1'b0;
                ir_load = 1'b1;
                mem_read = 1'b1;
                mem_write = 1'b0;
                reg_write = 1'b1;
            end
            4'b0001: begin // store
                alu_op = 4'b0000;
                pc_load = 1'b0;
                ir_load = 1'b1;
                mem_read = 1'b0;
                mem_write = 1'b1;
                reg_write = 1'b0;
            end

            default: begin
                alu_op = 4'b0000;
                pc_load = 1'b0;
                ir_load = 1'b1;
                mem_read = 1'b0;
                mem_write = 1'b0;
                reg_write = 1'b0;
            end
        endcase
    end
endmodule