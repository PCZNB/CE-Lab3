`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/25 20:21:55
// Design Name: 
// Module Name: if_id
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

module if_id(

	input wire	clk,
	input wire	rst,
	input wire jump_flag_i,
    input wire[`InstAddrBus]	  pc,
	input wire[`InstBus]          inst_i,
	output reg[`InstAddrBus]      inst_o,
	output reg[`InstBus]          inst_addr_o
	
);

	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			inst_o <= `ZeroWord;
			inst_addr_o <= `ZeroWord;
	  end else if(jump_flag_i  == `True)begin 
	        inst_o <= `ZeroWord;
			inst_addr_o <= `ZeroWord;
	  end else begin
		  inst_o <= inst_i;
		  inst_addr_o <= pc;
		end
	end

endmodule




