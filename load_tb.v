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
    wire [23:0] pc_out;
    reg [31:0] instruction; // EXTERNAL

    // CU
    reg [3:0] opcode;
    wire [3:0] alu_op;
    wire pc_load;
    wire ir_load;
    wire mem_read;
    wire mem_write;
    wire reg_write;

    // MBR and MAR
    reg [7:0] MBR;
    reg [23:0] MAR;
    
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
        .opcode(opcode),
        .alu_op(alu_op),
        .pc_load(pc_load),
        .ir_load(ir_load),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .reg_write(reg_write)
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
            addr = 24'bx;
            in = 8'bx;
        end
    endtask

    initial begin
        reset = 1;
        clk_enable = 0;
        lsi_enable = 0;
        we = 0;
        re = 0;
        instruction = 32'b0;
        #1
        reset = 0;
        clk_enable = 1;
        
		write_to_flash(32'h01008113, 24'h000000);
		// write_to_flash(32'h02008113, 24'h000003);
		/* INST:
			addi x1, x2, 10
		*/
		/* HEX:
			0x00a10093
		*/
		/* BINARY:
			0000 0000 1010 0001 0000 0000 1001 0011
		*/
		/* DECODE:  
			31       20 19       15 14       12 11      7 6           0
    			imm         rs1         000         rd       0010011

			0000 0000 1010 | 0001 0 | 000 | 0000 1 | 001 0011
		*/

        // READ INST #1 FROM FLASH [LITTLE ENDIAN]
        @(posedge clk);
        re = 1;
        addr = pc_out;
        pc_control = 2'b00;

        repeat(3) @(posedge clk);
        MBR = out;
        instruction [7:0] = MBR;

        @(posedge clk);
        pc_control = 2'b01;
        @(posedge clk);
        pc_control = 2'b00;

		// ---- //

        @(posedge clk);
        addr = pc_out;

        repeat(3) @(posedge clk);
        MBR = out;
        instruction [15:8] = MBR;

        @(posedge clk);
        pc_control = 2'b01;
        @(posedge clk);
        pc_control = 2'b00;

		// ---- //

        @(posedge clk);
        addr = pc_out;

        repeat(3) @(posedge clk);
        MBR = out;
        instruction [23:16] = MBR;

        @(posedge clk);
        pc_control = 2'b01;
        @(posedge clk);
        pc_control = 2'b00;

		// ---- //

        @(posedge clk);
        addr = pc_out;

        repeat(3) @(posedge clk);
        MBR = out;
        instruction [31:24] = MBR;

        @(posedge clk);
        re = 0;
        pc_control = 2'b00;

		@(posedge clk);
        addr = 24'bx;
        in = 8'bx;

        $finish;
    end
endmodule