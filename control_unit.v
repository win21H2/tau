module control_unit (
    input wire [6:0] cu_op,
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    output reg [3:0] alu_op,
    output reg alu_src,
    output reg reg_write,
    output reg mem_read,
    output reg mem_write
);

    always @(*) begin
        case(cu_op)
            7'b0110011: begin // R-type
                case({funct7, funct3})
                    10'b0000000_000: alu_op = 4'b0000; // ADD
                    10'b0100000_000: alu_op = 4'b0001; // SUB
                    10'b0000000_100: alu_op = 4'b1100; // XOR
                    10'b0000000_110: alu_op = 4'b1001; // OR
                    10'b0000000_111: alu_op = 4'b1000; // AND
                    default: alu_op = 4'b0110; // NO OPERATION
                endcase
                alu_src = 1'b0;
                reg_write = 1'b1;
                mem_read = 1'b0;
                mem_write = 1'b0;
            end
            7'b0010011: begin // I-type (Immediate)
                case(funct3)
                    3'b000: alu_op = 4'b0000; // ADDI
                    3'b100: alu_op = 4'b1100; // XORI
                    3'b110: alu_op = 4'b1001; // ORI
                    3'b111: alu_op = 4'b1000; // ANDI
                    default: alu_op = 4'b0110; // NO OPERATION
                endcase
                alu_src = 1'b1;
                reg_write = 1'b1;
                mem_read = 1'b0;
                mem_write = 1'b0;
            end
            7'b0000011: begin // I-type (Load)
                case(funct3)
                    3'b000: alu_op = 4'b0110; // LB
                    3'b001: alu_op = 4'b0110; // LH
                    3'b010: alu_op = 4'b0110; // LW
                    3'b100: alu_op = 4'b0110; // LBU
                    3'b101: alu_op = 4'b0110; // LHU
                    default: alu_op = 4'b0110; // NO OPERATION
                endcase
                alu_src = 1'b1;
                reg_write = 1'b1;
                mem_read = 1'b1;
                mem_write = 1'b0;
            end
            7'b0100011: begin // S-type (Store)
                case(funct3)
                    3'b000: alu_op = 4'b0110; // SB
                    3'b001: alu_op = 4'b0110; // SH
                    3'b010: alu_op = 4'b0110; // SW
                    default: alu_op = 4'b0110; // NO OPERATION
                endcase
                alu_src = 1'b1;
                reg_write = 1'b0;
                mem_read = 1'b0;
                mem_write = 1'b1;
            end
            default: begin
                alu_op = 4'b0110; // NO OPERATION
                alu_src = 1'b0;
                reg_write = 1'b0;
                mem_read = 1'b0;
                mem_write = 1'b0;
            end
        endcase
    end
endmodule