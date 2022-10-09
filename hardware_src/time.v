module mytime(
	input clk_m,
	output [47:0] timestruct
);
	reg [7:0] num_0,num_1,num_2,num_3,num_4,num_5;
	initial begin
		num_0 = 0; num_1 = 0; num_2 = 0;
		num_3 = 0; num_4 = 0; num_5 = 0;
	end
	assign timestruct = {num_0,num_1,num_2,num_3,num_4,num_5};
	//设置1hz时钟信号
	wire clk;
	clk_50mhz_1hz f_clk(.clk_m(clk_m),.clk(clk));
	//时钟进位逻辑
	always @(posedge clk) begin
		num_0 = num_0 + 1;
		num_1 = (num_0 == 10) ? (num_1 + 1) : num_1;
		num_2 = (num_1 == 6) ? (num_2 + 1) : num_2;
		num_3 = (num_2 == 10) ? (num_3 + 1) : num_3;
		num_4 = (num_3 == 6) ? (num_4 + 1) : num_4;
		num_5 = (num_4 == 10) ? (num_5 + 1) : num_5;
		num_0 = (num_0 == 10) ? 0 : num_0;
		num_1 = (num_1 == 6) ? 0 : num_1;
		num_2 = (num_2 == 10) ? 0 : num_2;
		num_3 = (num_3 == 6) ? 0 : num_3;
		num_4 = (num_4 == 10) ? 0 : num_4;
		{num_5,num_4} = (num_5 == 2 && num_4 == 4) ? 2'b00 : {num_5,num_4};
	end
endmodule


module clk_50mhz_1hz(
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
        if(sum == 24999999)begin
            sum <= 0;
            clk = ~clk;
        end
    end
endmodule