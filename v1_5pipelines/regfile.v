`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/25 20:28:52
// Design Name: 
// Module Name: regfile
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

module regfile(


    input wire	clk,
    input wire	rst,
    
    // write port
    input wire we_i,                      
    input wire[`RegAddrBus] waddr_i,      
    input wire[`RegBus] wdata_i,          
   
    // read port 1
    input wire[`RegAddrBus] raddr1_i,
    input wire re1_i,
    output reg[`RegBus] rdata1_o,
    
    // read port 2
    input wire[`RegAddrBus] raddr2_i,
    input wire re2_i,
    output reg[`RegBus] rdata2_o
    );
    	reg[`RegBus]  regs[0:`RegNum-1];
integer i;
	always @ (posedge clk) begin
	if(rst == `RstEnable) begin
       for(i=0;i<`RegNum;i=i+1)
       regs[i]= `ZeroWord;
    end
		if (rst == `RstDisable) begin
			if((we_i == `WriteEnable) && (waddr_i != `RegNumLog2'h0)) begin
				regs[waddr_i] <= wdata_i;
			end
			else regs[waddr_i] <= `ZeroWord;
		end
	end
	
    // 读寄存器1
always @ (*) begin
    if(rst == `RstEnable) begin
       rdata1_o = `ZeroWord;
    end 
    else if (raddr1_i == `RegNumLog2'h0) begin
            rdata1_o = `ZeroWord;
        // 如果读地址等于写地址，并且正在写操作，则直接返回写数据
    end 
    else if (raddr1_i == waddr_i && we_i == `WriteEnable&& re1_i == `ReadEnable) begin
            rdata1_o = wdata_i;
    end 
    else if (re1_i == `ReadEnable) begin
            rdata1_o = regs[raddr1_i];
    end 
    else begin
            rdata1_o =  `ZeroWord;
    end
end

    // 读寄存器2
always @ (*) begin
    if(rst == `RstEnable) begin
       rdata2_o = `ZeroWord;
    end 
    else if (raddr2_i == `RegNumLog2'h0) begin
            rdata2_o = `ZeroWord;
        // 如果读地址等于写地址，并且正在写操作，则直接返回写数据
    end 
    else if (raddr2_i == waddr_i && we_i == `WriteEnable && re2_i == `ReadEnable) begin
            rdata2_o = wdata_i;
    end 
    else if (re2_i == `ReadEnable) begin
            rdata2_o = regs[raddr2_i];
    end 
    else begin
            rdata2_o =  `ZeroWord;
    end
end

    
endmodule
