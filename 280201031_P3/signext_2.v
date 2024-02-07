module signext_2(out1,in1);
input [23:0] in1;
output [31:0] out1;
assign 	 out1 = {{ 8 {in1[23]}}, in1};
endmodule
