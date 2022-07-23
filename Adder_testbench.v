`timescale 1ns / 1ps
module MiniP1_Pipelined_tb;
reg [15:0] Input_A10;
reg [15:0] Input_B10;
reg clk_10;
reg reset_10;
wire [15:0] Result_10;
AdderDesign(Input_A10,Input_B10,clk_10,reset_10, Result_10);
always #5 clk_10=(~clk_10);
initial begin
#20;
clk_10 = 0;
#20;
reset_10 = 1;
#20;
reset_10 = 0;
Input_A10 = 16'h5620;//98
Input_B10 = 16'h5948;//169
#20
Input_A10 = 16'h5630;//99
Input_B10 = 16'hD590;//-89
#20
Input_A10 = 16'hD1A0;//-45
Input_B10 = 16'h54F0;//79
#20
Input_A10 = 16'hDC6C;//-283
Input_B10 = 16'hD420;//-66
#20
Input_A10 = 16'h0000;//0
Input_B10 = 16'h0000;//0
#20
Input_A10 = 16'h0000;//0
Input_B10 = 16'hD750;//-117
#20
Input_A10 = 16'hD6E2;//-110.125
Input_B10 = 16'h563E;//99.875
#20
Input_A10 = 16'h56EE;//110.875
Input_B10 = 16'h5632;//99.125
#20 $finish;
end
initial begin
$monitor("Input 1: %b, Input 2: %b, Sum: %b", Input_A10, Input_B10,
Result_10);
$dumpfile("MiniP1_Pipelined.vcd");
$dumpvars();
end
endmodule
