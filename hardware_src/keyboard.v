module KeyBoard(
	input clk,
	input ps2_clk,
	input ps2_data,
	output reg we_write,//写入使能端
	output reg [6:0] x_cursor,
	output reg [4:0] y_cursor,
	output reg [7:0] cur_key,
	output reg [2:0] count,
	output [7:0] ascii_key,
	output reg flag_shift,
	output reg flag_ctrl,
	output reg flag_caps,
	output reg flag_numlk
);
	wire [7:0] keydata;
    wire ready;
    wire nextdata_n;
	wire overflow;
	assign nextdata_n = ~ready;
	reg [7:0] pre_p;
    reg [7:0] pre;
    reg [7:0] ptr;
	reg sta;
	initial begin
        pre = 0; pre_p = 0; ptr = 0; sta = 1;
        cur_key = 0; count = 0;
		flag_shift = 0; flag_ctrl = 0;
		flag_caps = 0; flag_numlk = 0;
		x_cursor = 0; y_cursor = 0;//给光标位置初始化
		we_write = 0;
    end
	ps2_keyboard f0 (
		.clk(clk),
		.clrn(1'b1),
		.ps2_clk(ps2_clk),
		.ps2_data(ps2_data),
		.nextdata_n(nextdata_n),
		.data(keydata),
		.ready(ready),
		.overflow(overflow)
	);
	ScancodeToAscii f1 (
		.scancode(cur_key),
		.flag_caps(flag_caps),
		.flag_shift(flag_shift),
		.flag_numlk(flag_numlk),
		.ascii(ascii_key)
	);
	//扫描码记录逻辑
	always @(posedge clk) begin
		//记录最近的三个扫描码
        if(ready) begin
            pre_p = pre;
            pre = ptr;
            ptr = keydata;
			cur_key = ptr;
			//flag_shift输出逻辑
			if(ptr == 8'h12) begin
				flag_shift = 1'b1;
			end
			if(ptr == 8'h12 && pre == 8'hf0 ) begin
				flag_shift = 1'b0;
			end
			//flag_ctrl输出逻辑
			if(ptr == 8'h14) begin
				flag_ctrl = 1'b1;
			end
			if(ptr == 8'h14 && pre == 8'hf0) begin
				flag_ctrl = 1'b0;
			end
			//flag_caps输出逻辑
			if(ptr == 8'h58 && pre != 8'hf0) begin
				flag_caps = (flag_caps == 1'b1) ? 1'b0 : 1'b1;
			end
			//flag_numlk输出逻辑
			if(ptr == 8'h77 && pre != 8'hf0) begin
				flag_numlk = (flag_numlk == 1'b1) ? 1'b0 : 1'b1;
			end

			if((ptr != 8'hf0 && pre != 8'hf0) &&
			   (ptr != 8'h12 && ptr != 8'h14 && ptr != 8'h58 && ptr != 8'h77) && 
			   (ptr != 8'he0 && pre != 8'he0)) begin
				we_write = 1;
			end
			else begin
				we_write = 0;
			end
			//计数逻辑
			if((pre != ptr || pre_p == 8'hf0) && ptr != 8'hf0 && ( pre != 8'hf0 || sta == 1'b1) &&
			   (ptr != 8'h12 && ptr != 8'h14 && ptr != 8'h58 && ptr != 8'h77)) begin
				count = count + 1'b1;
				pre_p = pre;
				sta = 1'b0;
			end
        end
	end
endmodule

module ps2_keyboard(
	input clk,
	input clrn,
	input ps2_clk,
	input ps2_data,
	input nextdata_n,
	output [7:0] data,
	output reg ready,
	output reg overflow // fifo overflow
	);
	// internal signal, for test
	reg [9:0] buffer; // ps2_data bits
	reg [7:0] fifo[7:0]; // data fifo
	reg [2:0] w_ptr,r_ptr; // fifo write and read pointers
	reg [3:0] count; // count ps2_data bits
	reg [2:0] ps2_clk_sync; 
	wire sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];
	assign data = fifo[r_ptr]; //always set output data
	// detect falling edge of ps2_clk
	always @(posedge clk) begin
		ps2_clk_sync <= {ps2_clk_sync[1:0],ps2_clk};
	end
	always @(posedge clk) begin
		if (clrn == 0) begin // reset
		count <= 0; w_ptr <= 0; r_ptr <= 0; overflow <= 0; ready<= 0;
		end
		else begin
			if ( ready ) begin // read to output next data
				if(nextdata_n == 1'b0) begin//read next data
					r_ptr <= r_ptr + 3'b1;
					if(w_ptr==(r_ptr+1'b1)) //empty
						ready <= 1'b0;
				end
			end
			if (sampling) begin
				if (count == 4'd10) begin
					if ((buffer[0] == 0) && (ps2_data) &&(^buffer[9:1])) begin 
						fifo[w_ptr] <= buffer[8:1]; // kbd scan code
						w_ptr <= w_ptr+3'b1;
						ready <= 1'b1;
						overflow <= overflow | (r_ptr == (w_ptr + 3'b1));
					end
					count <= 0; // for next
				end 
				else begin
					buffer[count] <= ps2_data; // store ps2_data
					count <= count + 3'b1;
				end
			end
		end
	end
endmodule

module ScancodeToAscii(
	input [7:0] scancode,
	input flag_caps,
	input flag_shift,
	input flag_numlk,
	output reg [7:0] ascii
);
	wire flag_uppercase_letter = ((flag_caps && flag_shift == 0) || (flag_shift && flag_caps == 0));
	wire flag_num_lock = ((flag_shift && flag_numlk == 0) || (flag_numlk && flag_shift == 0));
	always @(scancode or flag_uppercase_letter or flag_num_lock or flag_shift) begin
		case (scancode)
		//26个字母的大小写
		8'h1c: if (flag_uppercase_letter) ascii = 8'h41; else ascii = 8'h61;
		8'h32: if (flag_uppercase_letter) ascii = 8'h42; else ascii = 8'h62;
		8'h21: if (flag_uppercase_letter) ascii = 8'h43; else ascii = 8'h63;
		8'h23: if (flag_uppercase_letter) ascii = 8'h44; else ascii = 8'h64;
		8'h24: if (flag_uppercase_letter) ascii = 8'h45; else ascii = 8'h65;
		8'h2b: if (flag_uppercase_letter) ascii = 8'h46; else ascii = 8'h66;
		8'h34: if (flag_uppercase_letter) ascii = 8'h47; else ascii = 8'h67;
		8'h33: if (flag_uppercase_letter) ascii = 8'h48; else ascii = 8'h68;
		8'h43: if (flag_uppercase_letter) ascii = 8'h49; else ascii = 8'h69;
		8'h3b: if (flag_uppercase_letter) ascii = 8'h4a; else ascii = 8'h6a;
		8'h42: if (flag_uppercase_letter) ascii = 8'h4b; else ascii = 8'h6b;
		8'h4b: if (flag_uppercase_letter) ascii = 8'h4c; else ascii = 8'h6c;
		8'h3a: if (flag_uppercase_letter) ascii = 8'h4d; else ascii = 8'h6d;
		8'h31: if (flag_uppercase_letter) ascii = 8'h4e; else ascii = 8'h6e;
		8'h44: if (flag_uppercase_letter) ascii = 8'h4f; else ascii = 8'h6f;
		8'h4d: if (flag_uppercase_letter) ascii = 8'h50; else ascii = 8'h70;
		8'h15: if (flag_uppercase_letter) ascii = 8'h51; else ascii = 8'h71;
		8'h2d: if (flag_uppercase_letter) ascii = 8'h52; else ascii = 8'h72;
		8'h1b: if (flag_uppercase_letter) ascii = 8'h53; else ascii = 8'h73;
		8'h2c: if (flag_uppercase_letter) ascii = 8'h54; else ascii = 8'h74;
		8'h3c: if (flag_uppercase_letter) ascii = 8'h55; else ascii = 8'h75;
		8'h2a: if (flag_uppercase_letter) ascii = 8'h56; else ascii = 8'h76;
		8'h1d: if (flag_uppercase_letter) ascii = 8'h57; else ascii = 8'h77;
		8'h22: if (flag_uppercase_letter) ascii = 8'h58; else ascii = 8'h78;
		8'h35: if (flag_uppercase_letter) ascii = 8'h59; else ascii = 8'h79;
		8'h1a: if (flag_uppercase_letter) ascii = 8'h5a; else ascii = 8'h7a;
		//空格
		8'h29: ascii = 8'h20;
		//回车
		8'h5a: ascii = 8'h0a;//特殊
		//删除
		8'h66: ascii = 8'h08;
		//数字键
		8'h16: if(flag_shift) ascii = 8'h21; else ascii = 8'h31;
		8'h1e: if(flag_shift) ascii = 8'h40; else ascii = 8'h32;
		8'h26: if(flag_shift) ascii = 8'h23; else ascii = 8'h33;
		8'h25: if(flag_shift) ascii = 8'h24; else ascii = 8'h34;
		8'h2e: if(flag_shift) ascii = 8'h25; else ascii = 8'h35;
		8'h36: if(flag_shift) ascii = 8'h5e; else ascii = 8'h36;
		8'h3d: if(flag_shift) ascii = 8'h26; else ascii = 8'h37;
		8'h3e: if(flag_shift) ascii = 8'h2a; else ascii = 8'h38;
		8'h46: if(flag_shift) ascii = 8'h28; else ascii = 8'h39;
		8'h45: if(flag_shift) ascii = 8'h29; else ascii = 8'h30;
		//符号键
		8'h41: if(flag_shift) ascii = 8'h3c; else ascii = 8'h2c;
		8'h49: if(flag_shift) ascii = 8'h3e; else ascii = 8'h2e;
		8'h4a: if(flag_shift) ascii = 8'h3f; else ascii = 8'h2f;
		8'h4c: if(flag_shift) ascii = 8'h3a; else ascii = 8'h3b;
		8'h52: if(flag_shift) ascii = 8'h22; else ascii = 8'h27;
		8'h54: if(flag_shift) ascii = 8'h7b; else ascii = 8'h5b;
		8'h5b: if(flag_shift) ascii = 8'h7d; else ascii = 8'h5d;
		8'h4e: if(flag_shift) ascii = 8'h5f; else ascii = 8'h2d;
		8'h55: if(flag_shift) ascii = 8'h2b; else ascii = 8'h3d;
		8'h5d: if(flag_shift) ascii = 8'h7c; else ascii = 8'h5c;
		8'h0e: if(flag_shift) ascii = 8'h7e; else ascii = 8'h60;
		//小键盘
		8'h70: if(flag_num_lock) ascii = 8'h2d; else ascii = 8'h30;
		8'h69: if(flag_num_lock) ascii = 8'h23; else ascii = 8'h31;
		8'h72: if(flag_num_lock) ascii = 8'hf2; else ascii = 8'h32;
		8'h7a: if(flag_num_lock) ascii = 8'h22; else ascii = 8'h33;
		8'h6b: if(flag_num_lock) ascii = 8'hf4; else ascii = 8'h34;
		8'h73: if(flag_num_lock) ascii = 8'h00; else ascii = 8'h35;
		8'h74: if(flag_num_lock) ascii = 8'hf6; else ascii = 8'h36;
		8'h6c: if(flag_num_lock) ascii = 8'h24; else ascii = 8'h37;
		8'h75: if(flag_num_lock) ascii = 8'hf8; else ascii = 8'h38;
		8'h7d: if(flag_num_lock) ascii = 8'h21; else ascii = 8'h39;
		default: ascii = 8'h00;
		endcase
	end
endmodule