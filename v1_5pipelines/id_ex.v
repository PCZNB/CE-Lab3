`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/25 22:34:41
// Design Name: 
// Module Name: id_ex
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

// 将译码结果向执行模块传递
module id_ex(

    input wire clk,
    input wire rst,
    
    input wire jump_flag_i,
    
    input wire[`InstBus] inst_i,            // 指令内容
    input wire[`InstAddrBus] inst_addr_i,   // 指令地址
    input wire reg_we_i,                    // 写通用寄存器标志
    input wire[`RegAddrBus] reg_waddr_i,    // 写通用寄存器地址
    input wire[`RegBus] reg1_rdata_i,       // 通用寄存器1读数据
    input wire[`RegBus] reg2_rdata_i,       // 通用寄存器2读数据
    input wire [`RegBus] offset_i,
    
    input wire [`AluSelBus]      alusel_i,
    input wire [`AluOpBus]       aluop_i,

    output reg[`InstBus] inst_o,            
    output reg[`InstAddrBus] inst_addr_o,   
    output reg reg_we_o,                   
    output reg[`RegAddrBus] reg_waddr_o,    
    output reg[`RegBus] reg1_rdata_o,       
    output reg[`RegBus] reg2_rdata_o, 
    output reg[`RegBus] offset_o,
    output reg [`AluSelBus]      alusel_o,
    output reg [`AluOpBus]       aluop_o
    
    );

always @ (posedge clk) begin
	if ((rst == `RstEnable)) begin
			inst_o <= `ZeroWord;
			inst_addr_o <= `ZeroWord;
			reg_waddr_o <= `ZeroWord;
			reg1_rdata_o <= `ZeroWord;
			reg2_rdata_o <= `ZeroWord;
			reg_we_o <= 1'b0;
			offset_o <= `ZeroWord;
			alusel_o <= `EX_NOP;
			aluop_o <=  `EX_RES_NOP;
    end
	else if(jump_flag_i == `True) begin
	        inst_o <= `ZeroWord;
			inst_addr_o <= `ZeroWord;
			reg_waddr_o <= `ZeroWord;
			reg1_rdata_o <= `ZeroWord;
			reg2_rdata_o <= `ZeroWord;
			reg_we_o <= 1'b0;
			offset_o <= `ZeroWord;
			alusel_o <= `EX_NOP;
			aluop_o <=  `EX_RES_NOP;
	  end 
	  else begin
			inst_o <= inst_i;
			inst_addr_o <= inst_addr_i;
			reg_waddr_o <= reg_waddr_i;
			reg1_rdata_o <= reg1_rdata_i;
			reg2_rdata_o <= reg2_rdata_i;
			reg_we_o<= reg_we_i;
			offset_o <= offset_i;
			alusel_o <= alusel_i;
			aluop_o <=  aluop_i;
		end
	end
endmodule
