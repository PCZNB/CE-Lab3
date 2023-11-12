`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/27 23:18:44
// Design Name: 
// Module Name: riscv_demo1_soc
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
module riscv_demo1_soc(
input wire clk,
input wire rst,
output wire [`RegBus] reg_wdata_o_WBREG
    );
  wire[`InstAddrBus] inst_addr;
  wire[`InstBus] inst;
  wire rom_ce;
  wire[`MemAddrBus] mem_waddr_i;
  wire[`RegBus]     ram_r_data_i;
  wire              ram_we_o;
  wire              ram_req_o;
  wire[`RegBus]     ram_addr_o;
  wire[`RegBus]     ram_wdata_o;
  wire[1:0]         ram_state_o;
 
riscv_demo1 riscv_demo1_0 (
        .clk(clk),
		.rst(rst),
		.rom_addr_o(inst_addr),
		.rom_data_i(inst),
		.rom_ce_o(rom_ce),
		.reg_wdata_o_WBREG(reg_wdata_o_WBREG),
		.mem_waddr_i(mem_waddr_i),
		.ram_r_data_i(ram_r_data_i),
		.ram_we_o(ram_we_o),
		.ram_req_o(ram_req_o),
		.ram_addr_o(ram_addr_o),
		.ram_state_o(ram_state_o),
		.ram_wdata_o(ram_wdata_o)
     );
     
 	inst_rom inst_rom0(
		.addr(inst_addr),
		.inst(inst),
		.ce(rom_ce)	
	);
    ram ram0(
		.clk(clk),
		.rst(rst),
		.ram_req_i(ram_req_o),
		.ram_we_i(ram_we_o),
		.ram_state_i(ram_state_o),
		.ram_addr_i(ram_addr_o),
		.ram_wdata_i(ram_wdata_o),
		.ram_r_data_o( ram_r_data_i)
	);
    
    
endmodule
