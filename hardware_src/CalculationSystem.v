 module CalculationSystem(
	input 		          		CLOCK_50,
	output		     [9:0]		LEDR,
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,
	input 		     [9:0]		SW,
	output		          		VGA_BLANK_N,
	output		     [7:0]		VGA_B,
	output		          		VGA_CLK,
	output		     [7:0]		VGA_G,
	output		          		VGA_HS,
	output		     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS,
	inout 		          		PS2_CLK,
	inout 		          		PS2_DAT
);
	//**********************************
	//******DEFINITION AND ASSIGN*******
	//**********************************

	//Start of pos
	wire [7:0] line;
	wire [7:0] ch;
	//End of pos

	//Start of cpu
	wire reset;
	wire cpuclk;															 
	cpuclk cpu_clk(.clkin(CLOCK_50),.rst(1'b0),.clken(1'b1),.clkout(cpuclk));
	assign reset = SW[0];
	wire [31:0] imemaddr;   											//指令地址
	wire [31:0] imemdataout;    										//指令数据
	wire 		imemclk;           										//指令读取时钟
	wire [31:0] dmemaddr;       										//32位数据地址
	wire [31:0] dmemdataout;    										//读取到的32位数据
	wire [31:0] dmemdatain;     										//32位写入数据内容
	wire 		dmemrdclk;            									//数据存储器的读取时钟，上升沿有效
	wire 		dmemwrclk;            									//数据存储器的写入时钟，上升沿有效
	wire [2:0] 	dmemop;          										//读写方式
	wire 		dmemwe;               									//数据存储器的写使能端，高电平有效
	wire [31:0] dbgdata;
	//End of cpu

	//Start of keyboard
	wire we_fifo;
	wire [7:0] datain_fifo;
	wire [2:0] count;
	wire clk_flash;														//光标闪烁
	clk_50mhz_4hz f_flash(.clk_m(CLOCK_50),.clk(clk_flash));
	//End of keyboard

	//Start of vga
	wire 		vga_clk;
	wire [7:0] 	dateout_vga;	   										//读取的ascii码
	wire [6:0] 	x_pos;
	wire [4:0]  y_pos; 
	wire [4:0] 	x_num;
	wire [4:0]  y_num; 
	wire [11:0] str_bit;												//获取一行12bit的01序列
	wire [11:0] addr_vga_read; 											//读取显存地址
	assign 		addr_vga_read = {y_pos,x_pos};
	reg 		vga_color;
	assign 		VGA_B = (vga_color == 1) ? 8'h00 : ({{color_point[3:0]}, {4{1'b0}}})/*8'h0*/;
	assign 		VGA_G = (vga_color == 1) ? 8'hff : ({{color_point[3:0]}, {4{1'b0}}})/*8'h0*/;
	assign 		VGA_R = (vga_color == 1) ? 8'h00 : ({{color_point[3:0]}, {4{1'b0}}})/*8'h0*/;
	assign 		VGA_SYNC_N = 1'b0;
	assign 		VGA_CLK = vga_clk;

	vgaclk f1(.clkin(CLOCK_50),.rst(1'b0),.clken(1'b1),.clkout(vga_clk));		
	wire flag_cursor;
	assign flag_cursor = (x_pos == ch && y_pos == line && x_num == 1);
	always @(posedge CLOCK_50) begin
		vga_color <= str_bit[x_num];									//在12bit的数据中获取所需数据
		if(flag_cursor) begin
			vga_color <= clk_flash;
		end
	end
	//End of vga
	
	//Start of background
	wire[18:0] color_address; wire[3:0] color_point;
	wire[9:0] color_h_addr; wire[9:0] color_v_addr;
	assign color_address = {{color_h_addr[9:0]}, {color_v_addr[8:0]}};
	vga_color_ctrl color_ctrl(vga_clk, 1'b0, color_h_addr, color_v_addr);
	test background_test(color_address, vga_clk, color_point);
	//End of background

	//Start of time
	wire [47:0] timestruct;
	set f_0(.pre(timestruct[47:40]),.bcd(HEX0));
	set f_1(.pre(timestruct[39:32]),.bcd(HEX1));
	set f_2(.pre(timestruct[31:24]),.bcd(HEX2));
	set f_3(.pre(timestruct[23:16]),.bcd(HEX3));
	set f_4(.pre(timestruct[15:8]) ,.bcd(HEX4));
	set f_5(.pre(timestruct[7:0])  ,.bcd(HEX5));
	//End of time

	//Start of led
	wire [9:0] ledstruct;
	assign LEDR = ledstruct;
	//End of led

	//***************************
	//*****Module Definition*****
	//***************************
	
	//系统时间模块
	mytime MYTIME(
		.clk_m(CLOCK_50),
		.timestruct(timestruct)
	);
	
	//键盘
	KeyBoard keyboard(
		.clk(~vga_clk),
		.ps2_clk(PS2_CLK),
		.ps2_data(PS2_DAT),
		.we_write(we_fifo),
		.count(count),
		.ascii_key(datain_fifo)
	);
	
	//VGA控制器
	vga_ctrl f2(
		.pclk(vga_clk),
		.reset(1'b0),
		.x_pos(x_pos),
		.y_pos(y_pos),
		.x_num(x_num),
		.y_num(y_num),
		.hsync(VGA_HS),
		.vsync(VGA_VS),
		.valid(VGA_BLANK_N)
	);

	//字模
	code_str f4(
		.address({dateout_vga,y_num[3:0]}),
		.clock(CLOCK_50),
		.data(12'b0),
		.wren(1'b0),
		.q(str_bit)
	);

	//CPU
	rv32is mycpu(
		.clock(CLOCK_50),
		.reset(reset),
		.imemaddr(imemaddr),
		.imemdataout(imemdataout),
		.imemclk(imemclk),
		.dmemaddr(dmemaddr),
		.dmemdataout(dmemdataout),
		.dmemdatain(dmemdatain),
		.dmemrdclk(dmemrdclk),
		.dmemwrclk(dmemwrclk),
		.dmemop(dmemop),
		.dmemwe(dmemwe),
		.dbgdata(dbgdata)
	);

	//数据存储器、外设的映射内存
	mem mymem(
		.addr(dmemaddr),
		.addr_vga_read(addr_vga_read),
		.dateout_vga(dateout_vga),
		.dataout(dmemdataout),
		.datain(dmemdatain),
		.vgaclk(vga_clk),
		.rdclk(dmemrdclk),
		.wrclk(dmemwrclk),
		.memop(dmemop),
		.we_fifo(we_fifo),
		.datain_fifo(datain_fifo),
		.we(dmemwe),
		.count(count),
		.timestruct(timestruct),
		.flash(clk_flash),
		.ledstruct(ledstruct),
		.line(line),
		.ch(ch)
	);

	//指令寄存器
	instrmem myinstrmem(
		.address(imemaddr[17:2]),
		.clock(imemclk),
		.data(32'b0),
		.wren(1'b0),
		.q(imemdataout)
	);
endmodule
