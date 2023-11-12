`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/27 20:30:15
// Design Name: 
// Module Name: inst_rom
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

module inst_rom(

	input wire                    ce,
	input wire[`InstAddrBus]	  addr,
	output reg[`InstBus]		  inst
    );
    
  reg[`InstBus]  inst_mem[`InstMemNum-1:0];

	initial begin $readmemb ( "D:/RISCV_5stages_demo1/rv32uipaddi.txt", inst_mem );
	end

	always @ (*) begin
		if (ce == `ChipDisable) begin
			inst <= `ZeroWord;
	  end else begin
		  inst <= inst_mem[addr[`InstMemNumLog2+1:2]];
		end
	end
    
    
    
endmodule
