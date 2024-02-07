module processor;

reg clk;

reg [31:0] pc;

reg [7:0] datmem[0:63], mem[0:31];

wire [31:0] dataa,datab;

wire [3:0] out1;
wire [31:0] out2,out3,out4,out6; 

wire [31:0] sum, extad, adder1out, adder2out, sextad, readdata,jump_address;

wire [7:0] inst31_24;
wire [23:0] inst23_0;
wire [3:0] inst23_20, inst19_16, inst15_12;
wire [5:0] inst11_6;

wire [4:0] inst25_21, inst20_16, inst15_11;
wire [15:0] inst15_0;
wire [31:0] instruc,dpack;
wire [2:0] gout;

wire [31:0] jump_ext; // burayi aklinda tut

wire cout,zout,nout,pcsrc,regdest,alusrc,memtoreg,regwrite,memread,
memwrite,branch,branchNotEqual,aluop1,aluop0,jump;

reg [31:0] registerfile [0:31];
integer i;

// datamemory connections
always @(posedge clk)
begin
	if(memwrite)
	begin 
		datmem[sum[4:0]+3] <= datab[7:0];
		datmem[sum[4:0]+2] <= datab[15:8];
		datmem[sum[4:0]+1] <= datab[23:16];
		datmem[sum[4:0]] <= datab[31:24];
	end
end

//instruction memory
assign instruc = {mem[pc[4:0]],
		  mem[pc[4:0]+1],
                  mem[pc[4:0]+2],
 		  mem[pc[4:0]+3]};

assign inst31_24 = instruc[31:24];
assign inst23_0 = instruc[23:0];
assign inst23_20 = instruc[23:20];
assign inst19_16 = instruc[19:16];
assign inst15_12 = instruc[15:12];
assign inst11_6 = instruc[11:6];
assign inst5_0 = instruc[5:0];
assign inst15_11 = instruc[15:11];
assign inst15_0 = instruc[15:0];


// registers
assign dataa = registerfile[inst23_20];
assign datab = registerfile[inst19_16];

//multiplexers
assign dpack={datmem[sum[5:0]],
	      datmem[sum[5:0]+1],
	      datmem[sum[5:0]+2],
              datmem[sum[5:0]+3]};

//j instructions jump_address calculation
signext_2 signext2(jump_ext,inst23_0);
assign jump_address = jump_ext;

//module mult2_to_1_4(out, i0,i1,s0)
mult2_to_1_4  mult1(out1, instruc[19:16],instruc[15:12],regdest);
mult2_to_1_32 mult2(out2, datab, extad, alusrc);
mult2_to_1_32 mult3(out3, sum, dpack, memtoreg);
mult2_to_1_32 mult4(out4, adder1out,adder2out,pcsrc);
mult2_to_1_32 mult6(out6, out4,jump_address,jump);

always @(posedge clk)
begin
	registerfile[out1]= regwrite ? out3 : registerfile[out1];
end


// load pc
always @(posedge clk)
pc = out6;

// alu, adder and control logic connections

alu32 alu1(sum, dataa, out2, zout, gout);
adder add1(pc,32'h4,adder1out);
adder add2(adder1out,sextad,adder2out);
/*
control(in, in2, regdest, alusrc, memtoreg, regwrite, memread, memwrite, branch,branchNotEqual, aluop1, aluop2, jump);
*/
control cont(instruc[31:24],regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,branchNotEqual,
aluop1,aluop0,jump);

signext sext(instruc[15:0],extad);

alucont acont(aluop1,aluop0,instruc[3],instruc[2], instruc[1], instruc[0],gout);

shift shift2(sextad,extad);

assign pcsrc = (branch && zout) || (branchNotEqual && (~zout));

//initialize datamemory,instruction memory and registers
initial
begin
	$readmemh("C:/intelFPGA/18.1/initDM.dat",datmem);
	$readmemh("C:/intelFPGA/18.1/initIM.dat",mem);
	$readmemh("C:/intelFPGA/18.1/initReg.dat",registerfile);

	for(i=0; i<31; i=i+1)
	$display("Instruction Memory[%0d]= %h  ",i,mem[i],"Data Memory[%0d]= %h   ",i,datmem[i],
	"Register[%0d]= %h",i,registerfile[i]);
end

initial
begin
	pc=0;
	#400 $finish;
end

initial
begin
	clk=0;
forever #20  clk=~clk;
end

initial 
begin
	$monitor($time,"PC %h",pc,"  SUM %h",sum,"   INST %h",instruc[31:0],
	"   REGISTER %h %h %h %h ",registerfile[4],registerfile[5], registerfile[6],registerfile[1] );
end

endmodule
