`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/25 20:12:10
// Design Name: 
// Module Name: pc_reg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "defines.v"

module pc_reg(
input wire clk,
input wire rst,
input wire jump_flag_i,
input wire [`InstAddrBus] jump_addr_i,
output reg [`InstAddrBus] pc,
output reg ce
   );
   
 always@ (posedge clk) begin
   if(rst == `RstEnable) begin
       pc <= 32'h00000000;
   end else if(jump_flag_i == `True) begin
       pc <= jump_addr_i;
   end else begin 
   pc <= pc + 4'h4; end
   end
   
   	always @ (*) begin
		if (rst == `RstEnable) begin
			ce <= `ChipDisable;
		end else begin
			ce <= `ChipEnable;
		end
   
 end
 

endmodule
