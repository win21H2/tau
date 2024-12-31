module register_file (
    input wire clk,
    input wire reset,
    input wire reg_we,
    input wire [4:0] rd,
    input wire [4:0] rs1,
    input wire [4:0] rs2,
    input wire [7:0] wd,
    output reg [7:0] rd1,
    output reg [7:0] rd2
);
    reg [7:0] registers [0:31];
    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 8'h00;
            end
        end
        else if (reg_we && rd != 0) begin
            registers[rd] <= wd;
            $display("Register x%0d written with value 0x%h", rd, wd);
        end
    end

    always @(*) begin
        rd1 = (rs1 == 0) ? 8'h00 : registers[rs1];
        rd2 = (rs2 == 0) ? 8'h00 : registers[rs2];
    end
endmodule