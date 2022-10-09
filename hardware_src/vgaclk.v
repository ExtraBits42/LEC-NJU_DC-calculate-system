module vgaclk(
	input clkin,
	input rst,
	input clken,
	output reg clkout
);
	parameter countlimit = 1; // 自动计算计数次数
	reg[31:0] clkcount = 0;
	always @ (posedge clkin) begin
		if(rst) begin
			clkcount=0;
			clkout=1'b0;
		end
		else begin
			if(clken) begin
				clkcount=clkcount+1;
				if(clkcount>=countlimit) begin
					clkcount=32'd0;
					clkout=~clkout;
				end
				else
					clkout=clkout;
			end
			else begin
				clkcount=clkcount;
				clkout=clkout;
			end
		end
	end
endmodule

module clk_50mhz_4hz(
	input clk_m,
	output reg clk
);
	reg [63:0] sum;
    initial begin
        sum <= 0;
        clk <= 0;
    end
	always @(posedge clk_m) begin
        sum <= sum + 1;
        if(sum == 9249999)begin
            sum <= 0;
            clk = ~clk;
        end
    end
endmodule

module cpuclk(
	input clkin,
	input rst,
	input clken,
	output reg clkout
);
	parameter countlimit = 2; // 自动计算计数次数
	reg[31:0] clkcount = 0;
	always @ (posedge clkin) begin
		if(rst) begin
			clkcount=0;
			clkout=1'b0;
		end
		else begin
			if(clken) begin
				clkcount=clkcount+1;
				if(clkcount>=countlimit) begin
					clkcount=32'd0;
					clkout=~clkout;
				end
				else
					clkout=clkout;
			end
			else begin
				clkcount=clkcount;
				clkout=clkout;
			end
		end
	end
endmodule

module set(
	input [3:0] pre,
	output reg [6:0] bcd
);
    always @(*) begin
		case (pre)
			4'b0000:bcd <= 7'h40;
			4'b0001:bcd <= 7'h79;
			4'b0010:bcd <= 7'h24;
			4'b0011:bcd <= 7'h30;
			4'b0100:bcd <= 7'h19;
			4'b0101:bcd <= 7'h12;
			4'b0110:bcd <= 7'h02;
			4'b0111:bcd <= 7'h78;
			4'b1000:bcd <= 7'h00;
			4'b1001:bcd <= 7'h10;
			4'b1010:bcd <= 7'h08;
			4'b1011:bcd <= 7'h03;
			4'b1100:bcd <= 7'h46;
			4'b1101:bcd <= 7'h21;
			4'b1110:bcd <= 7'h06;
			4'b1111:bcd <= 7'h0e;
			default:bcd <= 7'h7f;
		endcase
    end 
endmodule