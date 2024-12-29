/*
INST:
	addi x4, x5, 10 (add const of 10 to x5 and store to x4)

HEX:
     0x00a28213

BINARY:
     0000 0000 1010 0010 1000 0010 0001 0011

DECODE:  
     31       20 19       15 14       12 11      7 6           0
         imm         rs1         000         rd       0010011
*/

module top_tb;
    // CLK
    reg reset;
    reg clk_enable;
    reg lsi_enable;
    wire clk;
    wire lsi_clk;
    wire wdt_clk;

    // FLASH
    reg we;
    reg re;
    reg [23:0] addr;
    reg [7:0] in;
    wire [7:0] out;

    // PC
    reg [1:0] pc_control;
    wire [23:0] pc_out;
    reg [31:0] instruction; // EXTERNAL

    // CU
    reg [6:0] cu_op;
    wire [3:0] alu_op;
    wire mem_read;
    wire mem_write;

    // ALU
    reg [7:0] A;
    reg [7:0] B;
    wire [7:0] result;
    wire carry_out;

    // MBR
    reg [7:0] MBR;

	// REGISTERS
	reg [11:0] imm;
	reg [4:0] rs1;
	reg [4:0] rd;
    
    clock clk_inst (
        .reset(reset),
        .clk_enable(clk_enable),
        .lsi_enable(lsi_enable),
        .clk(clk),
        .lsi_clk(lsi_clk),
        .wdt_clk(wdt_clk)
    );

    flash flash_inst (
        .clk(clk),
        .we(we),
        .re(re),
        .addr(addr),
        .in(in),
        .out(out)
    );
 
    program_counter pc_inst (
        .clk(clk),
        .reset(reset),
        .pc_control(pc_control),
        .pc_out(pc_out)
    );

    control_unit cu_inst (
        .cu_op(cu_op),
        .alu_op(alu_op),
        .mem_read(mem_read),
        .mem_write(mem_write)
    );

    alu alu_inst (
        .A(A),
        .B(B),
        .alu_op(alu_op),
        .result(result),
        .carry_out(carry_out)
    );

    task write_to_flash;
        input [31:0] instruction;
        input [23:0] start_addr;

        begin
            we = 1;
            re = 0;

            @(posedge clk);
            addr = start_addr;
            in = instruction[7:0];

            @(posedge clk);
            addr = start_addr + 1;
            in = instruction[15:8];

            @(posedge clk);
            addr = start_addr + 2;
            in = instruction[23:16];

            @(posedge clk);
            addr = start_addr + 3;
            in = instruction[31:24];

            @(posedge clk);
            we = 0;
			re = 0;
            addr = 24'bx;
            in = 8'bx;
        end
    endtask

	task inc_pc;
		begin
			@(posedge clk);
	    	pc_control = 2'b01;
	    	@(posedge clk);
	    	pc_control = 2'b00;
		end
	endtask
	
	initial begin
	    reset = 1;
	    clk_enable = 0;
	    lsi_enable = 0;
	    instruction = 32'b0;
	    A = 8'bx;
	    B = 8'bx;
	    #1
	    reset = 0;
	    clk_enable = 1;
	    
	    // WRITE INSTRUCTION/DATA STAGE
	    // INSTRUCTION
	    write_to_flash(32'h00a28213, 24'h000000);
	
	    // DATA
	    @(posedge clk);
	    we = 1;
	    re = 0;
	
	    @(posedge clk);
	    addr = 24'h000005;
	    in = 8'b00010000;
	
	    @(posedge clk);
	    we = 0;
	    re = 0;
	    addr = 24'bx;
	    in = 8'bx;
	
	    // READ INSTRUCTION STAGE
	    @(posedge clk);
	    re = 1;
	    addr = pc_out;
	    pc_control = 2'b00;
	
	    repeat(3) @(posedge clk);
	    MBR = out;
	    instruction[7:0] = MBR;
	
	    inc_pc();
	
	    // ---- //
	
	    @(posedge clk);
	    addr = pc_out;
	
	    repeat(3) @(posedge clk);
	    MBR = out; 
	    instruction[15:8] = MBR;
	
	    inc_pc();
	
	    // ---- //
	
	    @(posedge clk);
	    addr = pc_out;
	
	    repeat(3) @(posedge clk);
	    MBR = out;
	    instruction[23:16] = MBR;
	
	    inc_pc();
	
	    // ---- //
	
	    @(posedge clk);
	    addr = pc_out;
	
	    repeat(3) @(posedge clk);
	    MBR = out;
	    instruction[31:24] = MBR;
	
	    @(posedge clk);
	    re = 0;
	    pc_control = 2'b00;
	
	    @(posedge clk);
	    addr = 24'bx;
	    in = 8'bx;
	
	    imm = instruction [31:20];
	    rs1 = instruction [19:15];
	    rd = instruction [11:7];
	
	    @(posedge clk);
	    re = 1;
	    addr = {19'b0, rs1};
	
	    repeat(3) @(posedge clk);
	    MBR = out;
	    re = 0;
	
	    @(posedge clk);
	    A = MBR;
	    B = imm [7:0];
	
	    @(posedge clk);
	    cu_op = instruction [6:0];
	
		@(posedge clk);
		we = 1;
		re = 0;
		addr = {11'b0, rd};
		in = result;

		@(posedge clk);
		we = 0;
		re = 0;

		#10
	
	    $finish;
	end
endmodule