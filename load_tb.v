module load_tb;
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
	reg [15:0] branch_addr;
	reg [15:0] jump_addr;
	wire [15:0] pc_out;
	reg [31:0] instruction;

	// CU
	reg [3:0] opcode;
	wire [3:0] alu_op;
	wire pc_load;
	wire ir_load;
	wire mem_read;
	wire mem_write;
	wire reg_write;
	
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
		.branch_addr(branch_addr),
		.jump_addr(jump_addr),
		.pc_out(pc_out)
	);

	control_unit cu_inst (
		.opcode(opcode),
		.alu_op(alu_op),
		.pc_load(pc_load),
		.ir_load(ir_load),
		.mem_read(mem_read),
		.mem_write(mem_write),
		.reg_write(reg_write)
	);

	initial begin
        reset = 1;
        clk_enable = 0;
        lsi_enable = 0;
		we = 0;
		re = 0;
		#1
		reset = 0;
		clk_enable = 1;

		// 00: hold, 01: increment, 10: branch, 11: jump (PC)
		
		// WRITE INST TO FLASH
	    @(posedge clk);
	    we = 1;
	    re = 0;
	    addr = 24'h000000;
	    in = 8'h93;
	    
	    @(posedge clk);
	    addr = 24'h000001;
	    in = 8'h00;
	    
	    @(posedge clk);
	    addr = 24'h000002;
	    in = 8'hA1;
	    
	    @(posedge clk);
	    addr = 24'h000003;
	    in = 8'h00;
	    
	    @(posedge clk);
	    we = 0;
	    re = 0;
		addr = 24'bx;
		in = 8'bx;
		// WRITE INST TO FLASH

		#50
		pc_control = 2'b01;

		@(posedge clk);
		re = 1;
		addr = 24'h000000;
		instruction = {instruction[23:0], out};
		
		@(posedge clk);
		re = 1;
		addr = 24'h000001;
		instruction = {instruction[23:0], out};

		@(posedge clk);
		re = 1;
		addr = 24'h000002;
		instruction = {instruction[23:0], out};
			@(posedge clk);
		re = 1;
		addr = 24'h000003;
		instruction = {instruction[23:0], out}; // figure out how to get readouts per clock cycle (right now, data out from mem is buffered to the next clock cycle)

	$finish;
end
endmodule