module vga_ctrl(
	input pclk, //25MHz 时钟
	input reset, // 置位
	output reg [6:0] x_pos,
	output reg [4:0] y_pos,
	output reg [4:0] x_num,
	output reg [4:0] y_num,
	output hsync, // 行同步和列同步信号
	output vsync,
	output valid // 消隐信号
);
	//640x480 分辨率下的VGA 参数设置
	parameter h_frontporch = 96;
	parameter h_active = 144;
	parameter h_backporch = 774;//
	parameter h_total = 800;
	parameter v_frontporch = 2;
	parameter v_active = 35;
	parameter v_backporch = 515;
	parameter v_total = 525;
	// 像素计数值
	reg [9:0] x_cnt;
	reg [9:0] y_cnt;
	initial begin
		x_cnt = 0; 
		y_cnt = 0;
	end
	wire h_valid;
	wire v_valid;
	always @(posedge reset or posedge pclk) begin // 行像素计数
		if (reset == 1'b1)
			x_cnt <= 1;
		else begin
			if (x_cnt == h_total)
			x_cnt <= 1;
			else
			x_cnt <= x_cnt + 10'd1;
		end
	end
	always @(posedge pclk) begin				  // 列像素计数
		if (reset == 1'b1)
			y_cnt <= 1;
		else begin
			if (y_cnt == v_total & x_cnt == h_total)
				y_cnt <= 1;
			else if (x_cnt == h_total)
				y_cnt <= y_cnt + 10'd1;
		end
	end
	// 生成同步信号
	assign hsync = (x_cnt > h_frontporch);
	assign vsync = (y_cnt > v_frontporch);
	// 生成消隐信号
	assign h_valid = (x_cnt > h_active) & (x_cnt <= h_backporch);
	assign v_valid = (y_cnt > v_active) & (y_cnt <= v_backporch);
	assign valid = h_valid & v_valid;
	initial begin
		x_pos = 0; x_num = 0;
		y_pos = 0; y_num = 0;
	end
	always @(posedge pclk) begin
		if(h_valid) begin
			if(x_num == 8) begin
				x_num <= 0;
				if(x_pos == 69) begin
					x_pos <= 0;
				end
				else begin
					x_pos <= x_pos + 1; 
				end
			end
			else begin
				x_num <= x_num + 1;
			end
		end
	end
	always @(posedge pclk) begin
		if(v_valid) begin
			if((x_cnt == h_total) && y_num == 15) begin
				y_num <= 0;
				if(y_pos == 29) begin
					y_pos <= 0;
				end
				else begin
					y_pos <= y_pos + 1;
				end
			end
			else if(x_cnt == h_total) begin
				y_num <= y_num + 1;
			end
		end
	end
endmodule