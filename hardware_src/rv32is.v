module rv32is(
	input 	clock,
	input   reset,
	output reg [31:0] imemaddr,   //指令地址
	input  [31:0] imemdataout,    //指令数据
	output 	imemclk,              //指令读取时钟
	output [31:0] dmemaddr,       //32位数据地址
	input  [31:0] dmemdataout,    //读取到的32位数据
	output [31:0] dmemdatain,     //32位写入数据内容
	output 	dmemrdclk,            //数据存储器的读取时钟，上升沿有效
	output	dmemwrclk,            //数据存储器的写入时钟，上升沿有效
	output [2:0] dmemop,          //读写方式
	output	dmemwe,               //数据存储器的写使能端，高电平有效
	output [31:0] dbgdata         
);  
    //---------------
    //------Def------
    //---------------
    wire [31:0] busW; wire [31:0] busA; wire [31:0] busB;
    wire [4:0] Ra; wire [4:0] Rb; wire [4:0] Rw;
    //----------------
    //----ClockSet----
    //----------------
    assign imemclk   = clock;
    assign dmemrdclk = ~clock;
    assign dmemwrclk = clock;
    wire WrClk = clock;
    //----------------
    //-------pc-------
    //----------------
    reg [31:0] PC; reg [31:0] NextPC;
    initial begin
        PC = 0; NextPC = 0;imemaddr = 0;
    end
    //----------------
    //-----Decode-----
    //----------------
    wire [6:0] opcode;
    wire [4:0] rd; wire [4:0] rs1; wire [4:0] rs2;
    wire [6:0]  func7; wire [2:0] func3;
    wire [31:0] immI; wire [31:0] immU; wire [31:0] immS; wire [31:0] immB; wire [31:0] immJ; 
    assign opcode = imemdataout[6:0];
    assign rd     = imemdataout[11:7];
    assign rs1    = imemdataout[19:15];
    assign rs2    = imemdataout[24:20];
    assign func7  = imemdataout[31:25];
    assign func3  = imemdataout[14:12];
    assign immI   = {{20{imemdataout[31]}},imemdataout[31:20]};
    assign immU   = {imemdataout[31:12],12'b0};
    assign immS   = {{20{imemdataout[31]}},imemdataout[31:25],imemdataout[11:7]};
    assign immB   = {{20{imemdataout[31]}},imemdataout[7],imemdataout[30:25],imemdataout[11:8],1'b0};
    assign immJ   = {{12{imemdataout[31]}},imemdataout[19:12],imemdataout[20],imemdataout[30:21],1'b0};
    wire [2:0] ExtOP;
    wire RegWr;
    wire ALUAsrc; wire [1:0] ALUBsrc; wire [3:0] ALUctr; wire [2:0] Branch;
    wire MemtoReg; wire MemWr; wire [2:0] MemOP;
    instr_ctr decode(
        .op(opcode[6:2]),
        .func3(func3),
        .func7_5(func7[5]),
        .ExtOP(ExtOP),
        .RegWr(RegWr),
        .ALUAsrc(ALUAsrc),
        .ALUBsrc(ALUBsrc),
        .ALUctr(ALUctr),
        .Branch(Branch),
        .MemtoReg(MemtoReg),
        .MemWr(MemWr),
        .MemOP(MemOP)
    );
    //-------------
    //-----ALU-----
    //-------------
    wire [31:0] dataa; wire [31:0] datab;
    wire less; wire zero;
    wire [31:0] aluresult;
    wire [31:0] imm;
    MUX_4_1 imm_mux(.I(immI),.U(immU),.S(immS),.B(immB),.J(immJ),.ExtOP(ExtOP),.y(imm));//decode_imm
    assign dataa = ALUAsrc ? PC : busA;
    assign datab = (ALUBsrc == 2'b00) ? busB : ((ALUBsrc == 2'b01) ? imm : 32'd4);
    alu myalu(
        .dataa(dataa),
        .datab(datab),
        .ALUctr(ALUctr),
        .less(less),
        .zero(zero),
        .aluresult(aluresult)
    );
    //-----------------
    //----Registers----
    //-----------------
    assign Ra = rs1;
    assign Rb = rs2; 
    assign Rw = rd;
    assign busW = (MemtoReg) ? dmemdataout : aluresult;
    regfile myregfile(
        .WrClk(WrClk),
        .Ra(Ra),
        .Rb(Rb),
        .Rw(Rw),
        .RegWr(RegWr),
        .busW(busW),
        .busA(busA),
        .busB(busB)
    );
    //-------------
    //-----Mem-----
    //-------------
    assign dmemaddr = busA + imm;
    assign dmemwe = MemWr;
    assign dmemop = MemOP;
    assign dmemdatain = busB;
    //------------------------
    //-----cpu_main_logic-----
    //------------------------
    always @(negedge clock ) begin
        if(reset == 1'b1) begin
            imemaddr <= 0;
        end
        else begin
            imemaddr <= NextPC;
        end
    end
    always @(posedge clock) begin
        if(reset == 1'b1) begin
            PC <= 0;
        end
        else begin
            PC <= NextPC;
        end
    end
    assign dbgdata = PC;
    //-----------------
    //-----NextPC------
    //-----------------
    wire PCAsrc; wire PCBsrc;
    assign PCAsrc = (Branch == 3'b001) || (Branch == 3'b010) || (Branch == 3'b100 && zero == 1) || (Branch == 3'b101 && zero == 0) || (Branch == 3'b110 && less == 1) || (Branch == 3'b111 && less == 0);
    assign PCBsrc = (Branch == 3'b010);
    always @(*) begin
        case ({PCAsrc,PCBsrc})
            2'b00: NextPC = PC + 32'd4;
            2'b10: NextPC = (PC + imm) & 32'hfffffffe;
            2'b11: NextPC = (busA + imm) & 32'hfffffffe;
            default: NextPC = 0;
        endcase
    end
endmodule

module MUX_4_1(
	input [31:0] I,
    input [31:0] U,
    input [31:0] S,
    input [31:0] B,
    input [31:0] J,
	input [2:0] ExtOP,
	output reg [31:0] y
	);
	always @ (*)
		case(ExtOP)
			3'b000:y = I;
			3'b001:y = U;
			3'b010:y = S;
			3'b011:y = B;
            3'b100:y = J;
			default:y = 32'b0;
		endcase
endmodule

module instr_ctr(
    input [4:0] op,
    input [2:0] func3,
    input func7_5,
    output [2:0] ExtOP,
    output RegWr,
    output ALUAsrc,
    output [1:0] ALUBsrc,
    output [3:0] ALUctr,
    output [2:0] Branch,
    output MemtoReg,
    output MemWr,
    output [2:0] MemOP
);
    assign ExtOP[0] = (op == 5'b11000) || (op == 5'b01101) || (op == 5'b00101);
    assign ExtOP[1] = (op == 5'b11000) || (op == 5'b01000);
    assign ExtOP[2] = (op == 5'b11011);
    assign RegWr = (op != 5'b11000) && (op != 5'b01000);
    assign ALUAsrc = (op == 5'b00101) || (op == 5'b11011) || (op == 5'b11001 && func3 == 3'b000);
    assign ALUBsrc[0] = (op == 5'b00100) || (op == 5'b01101) || (op == 5'b00101) || (op == 5'b00000) || (op == 5'b01000);
    assign ALUBsrc[1] = (op == 5'b11011) || (op == 5'b11001 && func3 == 3'b000);
    assign ALUctr[0] = (op == 5'b01101) || (op == 5'b00100 && (func3 == 3'b111 || func3 == 3'b001 || func3 == 3'b101)) || (op == 5'b01100 && (func3 == 3'b001 || func3 == 3'b101 || func3 == 3'b111));
    assign ALUctr[1] = (op == 5'b01101) || (op == 5'b00100 && (func3 == 3'b010 || func3 == 3'b011 || func3 == 3'b110 || func3 == 3'b111)) || (op == 5'b01100 && (func3 == 3'b010 || func3 == 3'b011 || func3 == 3'b110 || func3 == 3'b111)) || (op == 5'b11000);
    assign ALUctr[2] = (op == 5'b00100 && (func3 == 3'b100 || func3 == 3'b110 || func3 == 3'b111 || func3 == 3'b101)) || (op == 5'b01100 && (func3 == 3'b100 || func3 == 3'b110 || func3 == 3'b111 || func3 == 3'b101));
    assign ALUctr[3] = (op == 5'b00100 && ((func3 == 3'b101 && func7_5 == 1'b1)|| func3 == 3'b011)) || (op == 5'b01100 && ((func3 == 3'b000 && func7_5 == 1'b1)||(func3 == 3'b101 && func7_5 == 1'b1) || func3 == 3'b011)) || (op == 5'b11000 && (func3 == 3'b110 || func3 == 3'b111));
    assign Branch[0] = (op == 5'b11011) || (op == 5'b11000 && (func3 == 3'b001 || func3 == 3'b101 || func3 == 3'b111));
    assign Branch[1] = (op == 5'b11001) || (op == 5'b11000 && (func3 == 3'b100 || func3 == 3'b101 || func3 == 3'b110 || func3 == 3'b111));
    assign Branch[2] = (op == 5'b11000);
    assign MemtoReg = (op == 5'b00000);
    assign MemWr = (op == 5'b01000);
    assign MemOP = func3;
endmodule

module regfile(//寄存器
    input WrClk,
    input [4:0] Ra,
    input [4:0] Rb,
    input [4:0] Rw,
    input RegWr,
    input [31:0] busW,
    output [31:0] busA,
    output [31:0] busB
);
    integer i;
    reg [31:0] regs [31:0];
    initial begin
        for(i = 0; i < 32; i = i + 1)
            regs[i] = 32'b0;
    end
    always @(posedge WrClk) begin
        if(RegWr && Rw != 5'b0) begin
            regs[Rw] <= busW;
        end 
    end
    assign busA = regs[Ra];
    assign busB = regs[Rb];
endmodule

module alu(//ALU
    input [31:0] dataa,
    input [31:0] datab,
    input [3:0] ALUctr,
    output less,
    output zero,
    output reg [31:0] aluresult
);
    wire [31:0] F_m;
    wire zero_m;
    wire of_m;
    adder_subber_32 FA(//加法器
		.A(dataa),
		.B(datab),
		.addsub((ALUctr[3] || (ALUctr[0] ^ ALUctr[1]))),
		.F(F_m),
		.zero(zero_m),
		.of(of_m)
	);

    wire [31:0] result_barrel;
    wire [1:0] flag_barrel;
    barrel FB(//桶形移位器
        .indata(dataa),
        .shamt(datab[4:0]),
        .al(flag_barrel[1]),
        .lr(flag_barrel[0]),
        .outdata(result_barrel)
    );
    assign zero = zero_m;
    assign less = (ALUctr == 4'b1010) ? (dataa < datab) : (of_m ^ F_m[31]);
    assign flag_barrel = (ALUctr == 4'b1101) ? 2'b10 : ((ALUctr == 4'b1001 || ALUctr == 4'b0001) ? 2'b11 : 2'b00);
    always @(*) begin
		casex(ALUctr)
            4'b0000:aluresult = F_m;
            4'b1000:aluresult = F_m;
            4'bx001:aluresult = result_barrel;//左移
            4'b0010:aluresult = of_m ^ F_m[31];
            4'b1010:aluresult = (dataa < datab);
            4'bx011:aluresult = datab;
            4'bx100:aluresult = dataa ^ datab;
            4'b0101:aluresult = result_barrel;//逻辑右移               
            4'b1101:aluresult = result_barrel;//算术右移
            4'bx110:aluresult = dataa | datab;
            4'bx111:aluresult = dataa & datab;
			default:aluresult = 0;
		endcase
	end
endmodule

module barrel(
    input [31:0] indata, 
    input [4:0] shamt,
	input al,
	input lr,
    output reg [31:0] outdata
);
    reg [31:0] temp;
    always @ (indata or shamt or lr or al) begin
    case({lr,al})
        2'b00: begin
            temp = shamt[0] ? {1'b0, indata[31:1]} : indata;
            temp = shamt[1] ? {2'b0, temp[31:2]} : temp;
            temp = shamt[2] ? {4'b0, temp[31:4]} : temp;
            temp = shamt[3] ? {8'b0, temp[31:8]} : temp;
            temp = shamt[4] ? {16'b0, temp[31:16]} : temp;
            end
        2'b01: begin
            temp = shamt[0] ? {{indata[31]}, indata[31:1]} : indata;
            temp = shamt[1] ? {{2{temp[31]}}, temp[31:2]} : temp;
            temp = shamt[2] ? {{4{temp[31]}}, temp[31:4]} : temp;
            temp = shamt[3] ? {{8{temp[31]}}, temp[31:8]} : temp;
            temp = shamt[4] ? {{16{temp[31]}}, temp[31:16]} : temp;
            end
        2'b10, 2'b11: begin
            temp = shamt[0] ? {{indata[30:0]}, 1'b0} : indata;
            temp = shamt[1] ? {{temp[29:0]}, 2'b0} : temp;
            temp = shamt[2] ? {{temp[27:0]}, 4'b0} : temp;
            temp = shamt[3] ? {{temp[23:0]}, 8'b0} : temp;
            temp = shamt[4] ? {{temp[15:0]}, 16'b0} : temp;
            end
    endcase
    outdata = temp;
    end
endmodule
																																				
module adder_subber_32(
	input  [31:0] A,
	input  [31:0] B,
	input  addsub,
	output [31:0] F,
	output cf,
	output zero,
	output of
	);
	wire [31:0] B_temp;
	assign B_temp = {32{addsub}} ^ B;
	assign {cf, F} = (A + B_temp + addsub) ^ {addsub, {32{1'b0}}};
	assign of = (A[31] == B_temp[31]) && (F[31] != A[31]); 
	assign zero = ~(|F);
endmodule
