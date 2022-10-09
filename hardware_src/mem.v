module mem(
	input  			[31:0] 		addr,
	input  			[11:0] 		addr_vga_read,
	output 			[7:0] 		dateout_vga,
	output reg 		[31:0] 		dataout,
	output 			[9:0]		ledstruct,
	output			[7:0]		line,
	output 			[7:0]		ch,
	input  			[31:0] 		datain,
	input  						rdclk,
	input  						wrclk,
	input 						vgaclk,
	input 			[2:0] 		memop,
	input 						we_fifo,
	input 			[7:0] 		datain_fifo,
	input 			[2:0] 		count,
	input 						flash,
	input 			[47:0] 		timestruct,
	input 						we
);	
	wire [7:0] r_ptr; wire [7:0] w_ptr;	//键盘队列读写指针
	wire we_data;  	  assign we_data  = (addr[31:20] == 12'h001) && (we == 1'b1);
	wire we_video; 	  assign we_video = (addr[31:20] == 12'h002) && (we == 1'b1);
	wire we_ptr;   	  assign we_ptr   = (addr[31:20] == 12'h004) && (we == 1'b1);
	wire we_led;	  assign we_led   = (addr[31:20] == 12'h007) && (we == 1'b1);
	wire we_pos;	  assign we_pos	  = (addr[31:20] == 12'h008) && (we == 1'b1);

	wire [31:0] dataout_data;
	wire [7:0]  dataout_fifo;
	wire [7:0]  dataout_ptr;
	wire dataout_cursor;
	wire [7:0] dataout_time;
	wire [7:0] dataout_videomem;
	wire [7:0] dataout_pos;
	always @(*) begin//选择数据输出
		case (addr[31:20])
			12'h001: dataout = dataout_data;
			12'h002: dataout = {24'b0,dataout_videomem};
			12'h003: dataout = {24'b0,dataout_fifo};
			12'h004: dataout = {24'b0,dataout_ptr};
			12'h005: dataout = {31'b0,dataout_cursor};
			12'h006: dataout = {24'b0,dataout_time};
			12'h008: dataout = {24'b0,dataout_pos};
			default: dataout = 32'b0;
		endcase
	end
	
	//数据存储器
	dmem datamem(
		.addr(addr),
		.dataout(dataout_data),
		.datain(datain),
		.rdclk(rdclk),
		.wrclk(wrclk),
		.memop(memop),
		.we(we_data)
	);

	//显存
	videoram myvideomem(
		.addr_read(addr_vga_read),
		.addr(addr[11:0]),
		.rclk(~vgaclk),
		.rclk_video(~wrclk),
		.wclk(wrclk),
		.we(we_video),
		.in(datain[7:0]),
		.out(dateout_vga),
		.out_video(dataout_videomem)
	);

	//读写指针寄存器
	ptrmem ptrmem(
		.we_fifo(we_fifo),
		.count(count),
		.we_ptr(we_ptr),
		.addr(addr[0]),
		.in(datain[7:0]),
		.r_ptr(r_ptr),
		.w_ptr(w_ptr),
		.rclk(rdclk),
		.wclk(wrclk),
		.out(dataout_ptr)
	);

	//键盘队列
	fifo fifomem(
		.r_ptr(r_ptr),
		.w_ptr(w_ptr),
		.addr_read(addr[5:0]),
		.rclk(rdclk),
		.wclk(wrclk),
		.we(we_fifo),
		.in(datain_fifo),
		.out(dataout_fifo)
	);

	//FLASH寄存器
	cursor cursormem(
		.read_only_addr(addr[0]),
		.rclk(rdclk),
		.flash(flash),
		.out(dataout_cursor)
	);

	//时间寄存器
	timemem mytime(
		.read_only_addr(addr[3:0]),
		.rclk(rdclk),
		.num_0(timestruct[47:40]),
		.num_1(timestruct[39:32]),
		.num_2(timestruct[31:24]),
		.num_3(timestruct[23:16]),
		.num_4(timestruct[15:8]),
		.num_5(timestruct[7:0]),
		.out(dataout_time)
	);

	//led寄存器
	led myled(
		.addr(addr[3:0]),
		.in(datain[7:0]),
		.wclk(wrclk),
		.we(we_led),
		.ledstruct(ledstruct)
	);

	//光标位置寄存器
	pos mypos(
		.addr(addr[0]),
		.rclk(rdclk),
		.wclk(wrclk),
		.in(datain[7:0]),
		.we(we_pos),
		.out(dataout_pos),
		.line(line),
		.ch(ch)
	);

endmodule


module pos(
	input addr,
	input rclk,
	input wclk,
	input [7:0] in,
	input we,
	output reg [7:0] out,
	output [7:0] line,
	output [7:0] ch
);	
	reg [7:0] ram [1:0];
	initial begin
		ram[0] = 8'b0; ram[1] = 8'b0;
	end

	assign line = ram[0];
	assign ch = ram[1];

	always @(posedge wclk) begin
		if(we) begin
			ram[addr] <= in;
		end
	end
	always @(posedge rclk) begin
		out <= ram[addr];
	end

endmodule

module videoram(
	input [11:0] addr_read,
	input [11:0] addr,
	input rclk,
	input rclk_video,
	input wclk,
	input we,
	input [7:0] in,				//获取的ascii码
	output reg [7:0] out,		//供给vga显示模块
	output reg [7:0] out_video	//供给cpu数据
);
	reg [7:0] ram [32*70-1:0];
	integer i;
	initial begin
	for(i = 0; i < 2240; i = i + 1)
		ram[i] = 8'b0;
	end
	
	always @(posedge wclk) begin
		if(we) begin
			ram[addr] <= in;//写数据
		end
	end
	always @(posedge rclk_video) begin
		out_video <= ram[addr];
	end
	always @(posedge rclk) begin//供给vga显示器
		out <= ram[addr_read];
	end
endmodule

module led(
	input [3:0] addr,
	input [7:0] in,
	input wclk,
	input we,
	output [9:0] ledstruct
);	
	reg [7:0] ram [9:0];
	integer i;
	initial begin
	for(i = 0; i < 10; i = i + 1)
		ram[i] = 0;
	end
	assign ledstruct = {ram[9][0],ram[8][0],ram[7][0],ram[6][0],ram[5][0],ram[4][0],ram[3][0],ram[2][0],ram[1][0],ram[0][0]};

	always @(posedge wclk) begin
		if(we) begin
			ram[addr] <= in;
		end
	end
endmodule

module timemem (
	input [3:0] read_only_addr,
	input rclk,
	input [7:0] num_0,
	input [7:0] num_1,
	input [7:0] num_2,
	input [7:0] num_3,
	input [7:0] num_4,
	input [7:0] num_5,
	output reg [7:0] out
);
	reg [7:0] ram [5:0];
	integer i;
	initial begin
	for(i = 0; i < 6; i = i + 1)
		ram[i] = 0;
	end

	always @(posedge rclk) begin
		out <= ram[read_only_addr];
		ram[0] <= num_0;
		ram[1] <= num_1;
		ram[2] <= num_2;
		ram[3] <= num_3;
		ram[4] <= num_4;
		ram[5] <= num_5;
	end
endmodule

module cursor(
	input read_only_addr,
	input rclk,
	input flash,
	output reg out
);
	reg [7:0] ram [1:0];
	initial begin
		ram[0] = 0;
		ram[1] = 0;
	end
	always @(posedge rclk) begin
		out <= ram[read_only_addr][0];
		ram[0] <= flash;
	end
endmodule

module ptrmem(
	input we_fifo,
	input we_ptr,
	input [2:0] count,
	input addr,
	input [7:0] in,
	input rclk,
	input wclk,
	output [7:0] r_ptr,
	output [7:0] w_ptr,
	output reg [7:0] out
);
	reg [7:0] ram [1:0];
	integer i;
	initial begin
	for(i = 0; i < 2; i = i + 1)
		ram[i] = 0;
	end

	assign r_ptr = ram[0];
	assign w_ptr = ram[1];
	always @(posedge wclk) begin
		if(we_ptr) begin
			ram[addr] <= in;
		end
		if(we_fifo) begin
			ram[1] <= count;
		end
	end
	always @(posedge rclk) begin
		out <= ram[addr];
	end
endmodule

module fifo(
	input [7:0] r_ptr,
	input [7:0] w_ptr,
	input [5:0] addr_read,
	input rclk,
	input wclk,
	input we,
	input [7:0] in,//ascii码
	output reg [7:0] out
);
	reg [7:0] ram [7:0];
	integer i;
	initial begin
	for(i = 0; i < 8; i = i + 1)
		ram[i] = 0;
	end

	always @(posedge wclk) begin
		if(we && (w_ptr + 1 != r_ptr)) begin
			ram[w_ptr] <= in;
		end
	end
	always @(posedge rclk) begin
		out <= ram[addr_read];
	end
endmodule


module vga_color_ctrl(
input pclk, //25MHz时钟
input reset,
output [9:0] h_addr, // 提 供 给 上 层 模 块 的 当 前 扫 描 像 素 点 坐 标
output [9:0] v_addr
);
    //640x480 分辨 率 下的 VGA参数设置
    parameter h_frontporch = 96;
    parameter h_active = 144;
    parameter h_backporch = 784;
    parameter h_total = 800;
    parameter v_frontporch = 2;
    parameter v_active = 35;
    parameter v_backporch = 515;
    parameter v_total = 525;
    // 像素 计 数值
    reg [9:0] x_cnt;
    reg [9:0] y_cnt;
    wire h_valid;
    wire v_valid;

    always @(posedge reset or posedge pclk) // 行像 素 计数
        if (reset == 1'b1)
            x_cnt <= 1;
        else
        begin
            if (x_cnt == h_total)
                x_cnt <= 1;
            else
                x_cnt <= x_cnt + 10'd1;
    end
    
    always @(posedge pclk) // 列像 素 计数
        if (reset == 1'b1)
            y_cnt <= 1;
        else
        begin
            if (y_cnt == v_total & x_cnt == h_total)
                y_cnt <= 1;
            else if (x_cnt == h_total)
                y_cnt <= y_cnt + 10'd1;
    end
    // 生 成 消 隐 信 号
    assign h_valid = (x_cnt > h_active) & (x_cnt <= h_backporch);
    assign v_valid = (y_cnt > v_active) & (y_cnt <= v_backporch);
    assign valid = h_valid & v_valid;
    // 计 算 当 前 有 效 像 素 坐 标
    assign h_addr = h_valid ? (x_cnt - 10'd145) : {10{1'b0}};
    assign v_addr = v_valid ? (y_cnt - 10'd36) : {10{1'b0}};
endmodule
