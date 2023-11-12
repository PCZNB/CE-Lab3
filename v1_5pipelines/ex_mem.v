`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/26 20:49:19
// Design Name: 
// Module Name: ex_mem
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
module ex_mem(
    input wire clk,
    input wire rst,
    input wire[`MemAddrBus] mem_waddr_i,    
    input wire[`RegBus] reg_wdata_i,      
    input wire reg_we_i,                   
    input wire [`AluOpBus]   aluop_i,
    input wire[`RegAddrBus] reg_waddr_i,  
    
    output reg[`MemAddrBus] mem_waddr_o,    
    output reg[`RegBus] reg_wdata_o,       
    output reg reg_we_o,                   
    output reg[`RegAddrBus] reg_waddr_o,   
    output reg [`AluOpBus]       aluop_o
    );
    	always @ (posedge clk) begin
		if(rst == `RstEnable) begin
		 	mem_waddr_o <= `NOPRegAddr;
			reg_wdata_o <= `ZeroWord;	
			reg_we_o	<=`WriteDisable;
			reg_waddr_o <= `NOPRegAddr;
			aluop_o <= `MEM_NOP;

		end else begin
		 	mem_waddr_o <= mem_waddr_i;
			reg_wdata_o <= reg_wdata_i;	
			reg_we_o	<=reg_we_i;
			reg_waddr_o <= reg_waddr_i;
			aluop_o <= aluop_i;
		end    
	end      
    
endmodule
