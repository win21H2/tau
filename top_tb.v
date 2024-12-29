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
    wire alu_src;
    wire reg_write;
	wire mem_read;
	wire mem_write;

    // ALU
    reg [7:0] A;
    reg [7:0] B;
    wire [7:0] result;
    wire carry_out;
    
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
        .funct3(instruction[14:12]),
        .funct7(instruction[31:25]),
        .alu_op(alu_op),
        .alu_src(alu_src),
        .reg_write(reg_write),
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

    task write_instruction_to_flash;
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

    task write_byte_to_flash;
        input [7:0] byte_data;
        input [23:0] address;
        
        begin
            we = 1;
            re = 0;

            @(posedge clk);
            addr = address;
            in = byte_data;

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
        
// ~~~ WRITE STAGE ~~~ WRITE STAGE ~~~ WRITE STAGE ~~~ WRITE STAGE ~~~

/*
INSTRUCTIONS
lb t0, 1(x0)
HEX CODE [0x00100283] @ ADDRESS STARTING 0x0000004

lb t1, 2(x0)
HEX CODE [0x00200303] @ ADDRESS STARTING 0x0000008

add t2, t0, t1
HEX CODE [0x006283b3] @ ADDRESS STARTING 0x000000c

sb t2, 3(x0)
HEX CODE [0x007001a3] @ ADDRESS STARTING 0x0000010


DATA
HEX CODE [10] @ ADDRESS 0x0000001
HEX CODE [10] @ ADDRESS 0x0000002
*/

        // INSTRUCTIONS
        write_instruction_to_flash(32'h00100283, 24'h000000); // lb t0, 1(x0)
        write_instruction_to_flash(32'h00200303, 24'h000004); // lb t1, 2(x0)
        write_instruction_to_flash(32'h006283b3, 24'h000008); // add t2, t0, t1
        write_instruction_to_flash(32'h007001a3, 24'h00000c); // sb t2, 3(x0)

        // DATA
        write_byte_to_flash(8'h10, 24'h000020);
        write_byte_to_flash(8'h14, 24'h000021);
    
// ~~~ WRITE STAGE ~~~ WRITE STAGE ~~~ WRITE STAGE ~~~ WRITE STAGE ~~~
		repeat(3) @(posedge clk);
// ~~~ DEC/EXEC STAGE ~~~ DEC/EXEC STAGE ~~~ DEC/EXEC STAGE ~~~ DEC/EXEC STAGE ~~~

		@(posedge clk);
		re = 1;
		addr = pc_out;
		pc_control = 2'b00;
	
		repeat(3) @(posedge clk);
		instruction [7:0] = out;

		inc_pc();

		// ~~~ //		

		@(posedge clk);
		addr = pc_out;
	
		repeat(3) @(posedge clk);
		instruction [15:8] = out;

		inc_pc();

		// ~~~ //

		@(posedge clk);
		addr = pc_out;
	
		repeat(3) @(posedge clk);
		instruction [23:16] = out;

		inc_pc();

		// ~~~ //

		@(posedge clk);
		addr = pc_out;
	
		repeat(3) @(posedge clk);
		instruction [31:24] = out;

		// ~~~ //
		
		repeat(3) @(posedge clk);
		re = 0;
		pc_control = 2'b00;
		addr = 24'bx;
		in = 8'bx;

		repeat(3) @(posedge clk);
		
// ~~~ DEC/EXEC STAGE ~~~ DEC/EXEC STAGE ~~~ DEC/EXEC STAGE ~~~ DEC/EXEC STAGE ~~~
    
        #10
    
        $finish;
    end
endmodule