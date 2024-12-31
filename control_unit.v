module control_unit (
    input wire [6:0] cu_op,
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    input wire [31:0] ir,
    output reg [3:0] alu_op,
    output reg [31:0] imm,
    output reg [4:0] rs1,
    output reg [4:0] rs2,
    output reg [4:0] rd
);

    always @(*) begin

        case(cu_op)
            7'b0110011: begin // R-type
                rs1 = ir[19:15];
                rs2 = ir[24:20];
                rd = ir[11:7];
                case({funct7, funct3})
                    10'b0000000_000: alu_op = 4'b0000; // ADD
                    10'b0100000_000: alu_op = 4'b0001; // SUB
                    10'b0000000_100: alu_op = 4'b1100; // XOR
                    10'b0000000_110: alu_op = 4'b1001; // OR
                    10'b0000000_111: alu_op = 4'b1000; // AND
                    default: alu_op = 4'b0110; // NO OPERATION
                endcase
            end
            7'b0010011: begin // I-type (Immediate)
                rs1 = ir[19:15];
                rs2 = 5'bx;
                imm = {{20{ir[31]}}, ir[31:20]}; // Sign-extend immediate
                rd = ir[11:7];
                case(funct3)
                    3'b000: alu_op = 4'b0000; // ADDI
                    3'b100: alu_op = 4'b1100; // XORI
                    3'b110: alu_op = 4'b1001; // ORI
                    3'b111: alu_op = 4'b1000; // ANDI
                    default: alu_op = 4'b0110; // NO OPERATION
                endcase
            end
            7'b0000011: begin // I-type (Load)
                rs1 = ir[19:15];
                rs2 = 5'bx;
                imm = {{20{ir[31]}}, ir[31:20]}; // Sign-extend immediate
                rd = ir[11:7];
                case(funct3)
                    3'b000: alu_op = 4'b0110; // LB
                    3'b001: alu_op = 4'b0110; // LH
                    3'b010: alu_op = 4'b0110; // LW
                    3'b100: alu_op = 4'b0110; // LBU
                    3'b101: alu_op = 4'b0110; // LHU
                    default: alu_op = 4'b0110; // NO OPERATION
                endcase
            end
            7'b0100011: begin // S-type (Store)
                rs1 = ir[19:15];
                rs2 = ir[24:20];
                imm = {{20{ir[31]}}, ir[31:25], ir[11:7]}; // Sign-extend immediate
                case(funct3)
                    3'b000: alu_op = 4'b0110; // SB
                    3'b001: alu_op = 4'b0110; // SH
                    3'b010: alu_op = 4'b0110; // SW
                    default: alu_op = 4'b0110; // NO OPERATION
                endcase
            end
            default: begin
                alu_op = 4'bx;
                rs1 = 5'bx;
                rs2 = 5'bx;
                imm = 32'bx;
                rd = 5'bx;
            end
        endcase
    end

endmodule