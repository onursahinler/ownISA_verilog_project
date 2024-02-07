module control(in, regdest, alusrc, memtoreg, regwrite, 
	       memread, memwrite, branch, branchNotEqual, aluop1, aluop2,jump);
input [7:0] in;
output regdest, alusrc, memtoreg, regwrite, memread, memwrite, branch,branchNotEqual, aluop1, aluop2, jump;

wire rformat, lw, sw, j, beq, bne, addi;

assign rformat = ~in[7]& (~in[6])&(~in[5])&in[4]&in[3]&in[2]&in[1]&in[0]; // 00011111 = 31

assign lw = ~in[7]& (~in[6])&in[5]&(~in[4])&(~in[3])&(~in[2])&(~in[1])&(~in[0]); // 00100000 = 32
assign sw = ~in[7]& (~in[6])&in[5]&(~in[4])&(~in[3])&(~in[2])&(~in[1])&in[0]; // 00100001 = 33

assign j = ~in[7]& (~in[6])&in[5]&(~in[4])&(~in[3])&(~in[2])&in[1]&(~in[0]); // 00100010 = 34

assign beq = ~in[7]& (~in[6])&in[5]&(~in[4])&(~in[3])&(~in[2])&in[1]&in[0]; // 00100011 = 35

assign bne = ~in[7]& (~in[6])&in[5]&(~in[4])&(~in[3])&in[2]&(~in[1])&(~in[0]); // 00100100 = 36
assign addi = ~in[7]& (~in[6])&in[5]&(~in[4])&(~in[3])&in[2]&(~in[1])&in[0]; // 00100101 = 37

assign regdest = rformat;

assign alusrc = lw|sw|addi;
assign memtoreg = lw;
assign regwrite = rformat|lw|addi;
assign memread = lw;
assign memwrite = sw;
assign branch = beq;
assign branchNotEqual = bne;
assign aluop1 = rformat;
assign aluop2 = beq;
assign jump = j;

endmodule
