module register_file (
    input wire clk,
    input wire we, // write enable
    input wire [4:0] rs1,
    input wire [4:0] rs2,
    input wire [4:0] rd,
    input wire [31:0] wd, // write data
    output wire [31:0] rd1, // read data 1
    output wire [31:0] rd2  // read data 2
);

    reg [31:0] regfile [31:0];

    // Read ports
    assign rd1 = regfile[rs1];
    assign rd2 = regfile[rs2];

    // Write port
    always @(posedge clk) begin
        if (we) begin
            regfile[rd] <= wd;
        end
    end

endmodule