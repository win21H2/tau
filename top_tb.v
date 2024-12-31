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
    reg [31:0] ir;

    // CU
    reg [6:0] cu_op;
    reg [2:0] funct3;
    reg [6:0] funct7;
    wire [3:0] alu_op;
    wire [31:0] imm;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;

    // ALU
    reg [7:0] A;
    reg [7:0] B;
    wire [7:0] result;
    wire carry_out;

	// REGISTER FILE
	reg reg_we;
	reg [7:0] wd;
	wire [7:0] rd1;
	wire [7:0] rd2;

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
        .funct3(ir[14:12]),
        .funct7(ir[31:25]),
        .ir(ir),
        .alu_op(alu_op),
        .imm(imm),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd)
    );

    alu alu_inst (
        .A(A),
        .B(B),
        .alu_op(alu_op),
        .result(result),
        .carry_out(carry_out)
    );

    register_file reg_file_inst (
        .clk(clk),
        .reset(reset),
        .reg_we(reg_we),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2)
    );

    task write_instruction_to_flash;
        input [31:0] ir;
        input [23:0] start_addr;

        begin
            we = 1;
            re = 0;

            @(posedge clk);
            addr = start_addr;
            in = ir[7:0];

            @(posedge clk);
            addr = start_addr + 1;
            in = ir[15:8];

            @(posedge clk);
            addr = start_addr + 2;
            in = ir[23:16];

            @(posedge clk);
            addr = start_addr + 3;
            in = ir[31:24];

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

	task clr_post_inst_exec;
		begin
			cu_op = 7'bx;
			funct3 = 3'bx;
			funct7 = 7'bx;
			addr = 24'bx;
			ir = 32'bx;
			wd = 8'bx;
		end
	endtask

    initial begin
        reset = 1;
        clk_enable = 0;
        lsi_enable = 0;
        ir = 32'b0;
        A = 8'bx;
        B = 8'bx;
        reg_we = 0;
        wd = 32'bx;
		ir = 32'bx;
        #1
        reset = 0;
        clk_enable = 1;

        // ~~~ WRITE STAGE ~~~ WRITE STAGE ~~~ WRITE STAGE ~~~ WRITE STAGE ~~~
        // INSTRUCTIONS (note: offset is a decimal number offset - so 32 in decimal is address 20 in hex in the first load instruction)
        write_instruction_to_flash(32'h02000283, 24'h000000); // lb t0, 32(x0)
        write_instruction_to_flash(32'h02100303, 24'h000004); // lb t1, 33(x0)
        write_instruction_to_flash(32'h006283b3, 24'h000008); // add t2, t0, t1
        write_instruction_to_flash(32'h02700123, 24'h00000c); // sb t2, 34(x0)

        // DATA
        write_byte_to_flash(8'ha, 24'h000020);
        write_byte_to_flash(8'h5a, 24'h000021);

        // ~~~ WRITE STAGE ~~~ WRITE STAGE ~~~ WRITE STAGE ~~~ WRITE STAGE ~~~
        repeat(3) @(posedge clk);
        // ~~~ DEC/EXEC STAGE ~~~ DEC/EXEC STAGE ~~~ DEC/EXEC STAGE ~~~ DEC/EXEC STAGE ~~~

		// ~|~|~ INSTRUCTION #1 ~|~|~ INSTRUCTION #1 ~|~|~ INSTRUCTION #1 ~|~|~ INSTRUCTION #1 ~|~|~
        @(posedge clk);
        re = 1;
		we = 0;
        addr = pc_out;
        pc_control = 2'b00;

        repeat(3) @(posedge clk);
        ir[7:0] = out;

        inc_pc();

        @(posedge clk);
        addr = pc_out;

        repeat(3) @(posedge clk);
        ir[15:8] = out;

        inc_pc();

        @(posedge clk);
        addr = pc_out;

        repeat(3) @(posedge clk);
        ir[23:16] = out;

        inc_pc();

        @(posedge clk);
        addr = pc_out;

        repeat(3) @(posedge clk);
        ir[31:24] = out;

        repeat(3) @(posedge clk);
        re = 0;
        we = 0;
        pc_control = 2'b00;
        addr = 24'bx;
        in = 8'bx;

        @(posedge clk);
        cu_op = ir[6:0];
        funct3 = ir[14:12];
        funct7 = ir[31:25];
        re = 1;
		we = 0;
        @(posedge clk);
        if (cu_op == 7'b0000011 && funct3 == 3'b000) begin
            addr = imm[23:0];
            repeat(2) @(posedge clk);
            reg_we = 1;
            wd = out;
            @(posedge clk);
            reg_we = 0;
        end
        re = 0;
        we = 0;
		clr_post_inst_exec();

		// ~|~|~ INSTRUCTION #1 ~|~|~ INSTRUCTION #1 ~|~|~ INSTRUCTION #1 ~|~|~ INSTRUCTION #1 ~|~|~
		repeat(3) @(posedge clk);
		// ~|~|~ INSTRUCTION #2 ~|~|~ INSTRUCTION #2 ~|~|~ INSTRUCTION #2 ~|~|~ INSTRUCTION #2 ~|~|~

		inc_pc();
		
		@(posedge clk);
        re = 1;
		we = 0;
        addr = pc_out;
        pc_control = 2'b00;

        repeat(3) @(posedge clk);
        ir[7:0] = out;

        inc_pc();

        @(posedge clk);
        addr = pc_out;

        repeat(3) @(posedge clk);
        ir[15:8] = out;

        inc_pc();

        @(posedge clk);
        addr = pc_out;

        repeat(3) @(posedge clk);
        ir[23:16] = out;

        inc_pc();

        @(posedge clk);
        addr = pc_out;

        repeat(3) @(posedge clk);
        ir[31:24] = out;

        repeat(3) @(posedge clk);
        re = 0;
        we = 0;
        pc_control = 2'b00;
        addr = 24'bx;
        in = 8'bx;		

		@(posedge clk);
        cu_op = ir[6:0];
        funct3 = ir[14:12];
        funct7 = ir[31:25];
        re = 1;
		we = 0;
        @(posedge clk);
        if (cu_op == 7'b0000011 && funct3 == 3'b000) begin
            addr = imm[23:0];
            repeat(2) @(posedge clk);
            reg_we = 1;
            wd = out;
            @(posedge clk);
            reg_we = 0;
        end
        re = 0;
        we = 0;
		clr_post_inst_exec();

		// ~|~|~ INSTRUCTION #2 ~|~|~ INSTRUCTION #2 ~|~|~ INSTRUCTION #2 ~|~|~ INSTRUCTION #2 ~|~|~
		repeat(3) @(posedge clk);
		// ~|~|~ INSTRUCTION #3 ~|~|~ INSTRUCTION #3 ~|~|~ INSTRUCTION #3 ~|~|~ INSTRUCTION #3 ~|~|~
		
		inc_pc();

		@(posedge clk);
		re = 1;
		we = 0;
		addr = pc_out;
		pc_control = 2'b00;
		
		repeat(3) @(posedge clk);
		ir[7:0] = out;
		
		inc_pc();
		
		@(posedge clk);
		addr = pc_out;
		
		repeat(3) @(posedge clk);
		ir[15:8] = out;
		
		inc_pc();
		
		@(posedge clk);
		addr = pc_out;
		
		repeat(3) @(posedge clk);
		ir[23:16] = out;
		
		inc_pc();
		
		@(posedge clk);
		addr = pc_out;
		
		repeat(3) @(posedge clk);
		ir[31:24] = out;
		
		repeat(3) @(posedge clk);
		re = 0;
		we = 0;
		pc_control = 2'b00;
		addr = 24'bx;
		in = 8'bx;
		
		@(posedge clk);
		cu_op = ir[6:0];
		funct3 = ir[14:12];
		funct7 = ir[31:25];

		@(posedge clk);
		if (cu_op == 7'b0110011 && funct3 == 3'b000 && funct7 == 7'b0000000) begin
		    A = rd1;
		    B = rd2;
		    @(posedge clk);
		    reg_we = 1;
		    wd = result;
		    @(posedge clk);
		    reg_we = 0;
		end
		clr_post_inst_exec();

		// ~|~|~ INSTRUCTION #3 ~|~|~ INSTRUCTION #3 ~|~|~ INSTRUCTION #3 ~|~|~ INSTRUCTION #3 ~|~|~
		repeat(3) @(posedge clk);
		// ~|~|~ INSTRUCTION #4 ~|~|~ INSTRUCTION #4 ~|~|~ INSTRUCTION #4 ~|~|~ INSTRUCTION #4 ~|~|~

		inc_pc();
		
		@(posedge clk);
		re = 1;
		we = 0;
		addr = pc_out;
		pc_control = 2'b00;
		
		repeat(3) @(posedge clk);
		ir[7:0] = out;
		
		inc_pc();
		
		@(posedge clk);
		addr = pc_out;
		
		repeat(3) @(posedge clk);
		ir[15:8] = out;
		
		inc_pc();
		
		@(posedge clk);
		addr = pc_out;
		
		repeat(3) @(posedge clk);
		ir[23:16] = out;
		
		inc_pc();
		
		@(posedge clk);
		addr = pc_out;
		
		repeat(3) @(posedge clk);
		ir[31:24] = out;
		
		repeat(3) @(posedge clk);
		re = 0;
		we = 0;
		pc_control = 2'b00;
		addr = 24'bx;
		in = 8'bx;
		
		@(posedge clk);
		cu_op = ir[6:0];
		funct3 = ir[14:12];
		funct7 = ir[31:25];
		
		@(posedge clk);
		if (cu_op == 7'b0100011 && funct3 == 3'b000) begin
		    we = 1;
		    re = 0;
		    addr = imm[23:0];
		    in = rd2;
		    @(posedge clk);
		    we = 0;
		end
		clr_post_inst_exec();

		// ~|~|~ INSTRUCTION #4 ~|~|~ INSTRUCTION #4 ~|~|~ INSTRUCTION #4 ~|~|~ INSTRUCTION #4 ~|~|~

        // ~~~ DEC/EXEC STAGE ~~~ DEC/EXEC STAGE ~~~ DEC/EXEC STAGE ~~~ DEC/EXEC STAGE ~~~
        repeat(3) @(posedge clk);

        $finish;
    end
endmodule