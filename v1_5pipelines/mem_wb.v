`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/26 21:05:50
// Design Name: 
// Module Name: mem_wb
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

module mem_wb(
    input wire clk,
    input wire rst,
    input wire[`RegBus] reg_wdata_i,       // 写寄存器数据
    input wire reg_we_i,                   // 是否要写通用寄存器
    output wire[`RegAddrBus] reg_waddr_i,   // 写通用寄存器地址
    
    output reg[`RegBus] reg_wdata_o,       // 写寄存器数据
    output reg reg_we_o,                   // 是否要写通用寄存器
    output reg[`RegAddrBus] reg_waddr_o   // 写通用寄存器地址
    );
       	always @ (posedge clk) begin
		if(rst == `RstEnable) begin
			reg_wdata_o <= `ZeroWord;	
			reg_we_o	<=`WriteDisable;
			reg_waddr_o <= `NOPRegAddr;

		end else begin	
			reg_wdata_o <= reg_wdata_i;	
			reg_we_o	<=reg_we_i;
			reg_waddr_o <= reg_waddr_i;
		end    
	end      
    
endmodule
