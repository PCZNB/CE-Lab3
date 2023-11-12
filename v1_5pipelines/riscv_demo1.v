`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/26 21:08:51
// Design Name: 
// Module Name: riscv_demo1
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

module riscv_demo1(
	input wire				      clk,
	input wire					  rst,
    input wire[`RegBus]           rom_data_i,
	output wire[`RegBus]          rom_addr_o,
	output wire                   rom_ce_o,
	output wire[`RegBus]reg_wdata_o_WBREG,
	
	input wire[`MemAddrBus] mem_waddr_i,
	input wire[`RegBus]     ram_r_data_i,
     output wire              ram_we_o,
     output wire              ram_req_o,
     output wire[`RegBus]     ram_addr_o,
     output wire[`RegBus]     ram_wdata_o,
     output wire[1:0]         ram_state_o
    );
// **********************************************Variable************************************************
// IF/ID , ID
	wire[`InstAddrBus] pc;
	wire[`InstAddrBus] inst_addr_o_IFID;
	wire[`InstBus] inst_o_IFID;

// ID -> ID/EX

    wire[`InstBus] inst_o_IDEX;           
    wire[`InstAddrBus] inst_addr_o_IDEX;   
    wire reg_we_o_IDEX;                   
    wire[`RegAddrBus] reg_waddr_o_IDEX;    
    wire[`RegBus] reg1_rdata_o_IDEX;       
    wire[`RegBus] reg2_rdata_o_IDEX; 
    
    wire [`RegBus]  offset_o_IDEX;
    wire [`AluSelBus]      alusel_o_IDEX;
    wire [`AluOpBus]       aluop_o_IDEX;
// ID/EX -> EX
    wire[`InstBus] inst_o_EXEX;           
    wire[`InstAddrBus] inst_addr_o_EXEX;                  
    wire[`RegAddrBus] reg_waddr_o_EXEX;    
    wire reg_we_o_EXEX; 
    wire[`RegBus] reg1_rdata_o_EXEX;       
    wire[`RegBus] reg2_rdata_o_EXEX; 
    
    wire [`RegBus]     offset_o_EXEX;
    wire [`AluSelBus]      alusel_o_EXEX;
    wire [`AluOpBus]       aluop_o_EXEX;

//EX  JUMP
   wire jump_flag;
   wire [`InstAddrBus]jump_addr;

// EX -> EX/MEM
   	wire reg_we_o_EXMEM;
	wire[`RegBus] reg_wdata_o_EXMEM;
	wire[`RegAddrBus] reg_waddr_o_EXMEM;
	
	wire [`AluOpBus]  aluop_o_EXMEM;
	wire [`MemAddrBus]mem_waddr_o_EXMEM;


//EX/MEM -> MEM 
    wire reg_we_o_MEMMEM;
	wire[`RegBus] reg_wdata_o_MEMMEM;
	wire[`RegAddrBus] reg_waddr_o_MEMMEM;
	wire [`AluOpBus]  aluop_o_MEMMEM;
	wire [`MemAddrBus]mem_waddr_o_MEMMEM;
     
// MEM -> MEM/WB
    wire reg_we_o_MEMWB;
	wire[`RegBus] reg_wdata_o_MEMWB;
	wire[`RegAddrBus] reg_waddr_o_MEMWB;
	
// WB -> REG
    wire reg_we_o_WBREG;
	//wire[`RegAddrBus] reg_wdata_o_WBREG;
	wire[`RegAddrBus] reg_waddr_o_WBREG;
	
// ID -> Regfile
    wire[`RegBus] reg1_data;
    wire[`RegBus] reg2_data;
    wire[`RegAddrBus] reg1_addr;
    wire[`RegAddrBus] reg2_addr;
    wire re1_o;
    wire re2_o;
  
// **********************************Instantiation**************************************************
// pc_reg
	pc_reg pc_reg0(
		.clk(clk),
		.rst(rst),
		.pc(pc),
		.ce(rom_ce_o),
		.jump_flag_i(jump_flag),
		.jump_addr_i(jump_addr)
     );

  assign rom_addr_o = pc;
  
//IF/ID  
    if_id if_id0(
		.clk(clk),
		.rst(rst),
		.pc(pc),
		.inst_i(rom_data_i),
		.inst_o(inst_o_IFID),
		.inst_addr_o(inst_addr_o_IFID),
		.jump_flag_i(jump_flag)      	
	);

//ID
    id id0(
		.rst(rst),
		.inst_i(inst_o_IFID),
		.inst_addr_i(inst_addr_o_IFID),
		.reg1_rdata_i(reg1_data),
		.reg2_rdata_i(reg2_data),
		.reg1_raddr_o(reg1_addr),
		.reg2_raddr_o(reg2_addr),
		.reg1_rdata_o(reg1_rdata_o_IDEX),
		.reg2_rdata_o(reg2_rdata_o_IDEX),
		.inst_o(inst_o_IDEX),
		.inst_addr_o(inst_addr_o_IDEX),
		.reg_we_o(reg_we_o_IDEX),
		.reg_waddr_o(reg_waddr_o_IDEX),
		.offset_o(offset_o_IDEX),
		.alusel_o(alusel_o_IDEX),
		.aluop_o(aluop_o_IDEX),
		.re1_o (re1_o),
		.re2_o (re2_o),
		.ex_wd_i (reg_waddr_o_EXMEM),
		.ex_wreg_i(reg_we_o_EXMEM),
		.ex_wdata_i(reg_wdata_o_EXMEM),
		.mem_wd_i (reg_waddr_o_MEMWB),
		.mem_wreg_i (reg_we_o_MEMWB),
		.mem_wdata_i(reg_wdata_o_MEMWB)
		);

//Regfile
regfile regfile0(
		.clk (clk),
		.rst (rst),
		.we_i	(reg_we_o_WBREG),
		.waddr_i (reg_waddr_o_WBREG),
		.wdata_i (reg_wdata_o_WBREG),
		.raddr1_i (reg1_addr),
		.rdata1_o (reg1_data),
		.raddr2_i (reg2_addr),
		.rdata2_o (reg2_data),
		.re1_i (re1_o),
		.re2_i (re2_o)
	);

//ID/EX
id_ex id_ex0(
		.rst(rst),
		.clk (clk),
		.inst_i(inst_o_IDEX),
		.inst_addr_i(inst_addr_o_IDEX),
		.reg_we_i( reg_we_o_IDEX),
		.reg_waddr_i( reg_waddr_o_IDEX),
		.reg1_rdata_i(reg1_rdata_o_IDEX),
		.reg2_rdata_i(reg2_rdata_o_IDEX),
		.reg1_rdata_o(reg1_rdata_o_EXEX),
		.reg2_rdata_o(reg2_rdata_o_EXEX),
		.inst_o(inst_o_EXEX),
		.inst_addr_o(inst_addr_o_EXEX),
		.reg_we_o(reg_we_o_EXEX),
		.reg_waddr_o(reg_waddr_o_EXEX),
		.offset_i(offset_o_IDEX),
		.alusel_i(alusel_o_IDEX),
		.aluop_i(aluop_o_IDEX),
		.offset_o(offset_o_EXEX),
		.alusel_o(alusel_o_EXEX),
		.aluop_o(aluop_o_EXEX),
		.jump_flag_i(jump_flag)
		);

//EX
ex ex0( 
        .rst(rst),
        .inst_i(inst_o_EXEX),
		.inst_addr_i(inst_addr_o_EXEX),
		.reg_we_i( reg_we_o_EXEX),
		.reg_waddr_i( reg_waddr_o_EXEX),
		.reg1_rdata_i(reg1_rdata_o_EXEX),
		.reg2_rdata_i(reg2_rdata_o_EXEX),
		.reg_wdata_o (reg_wdata_o_EXMEM),
		.reg_we_o (reg_we_o_EXMEM),
		.reg_waddr_o(reg_waddr_o_EXMEM),
		.offset_i(offset_o_EXEX),
		.alusel_i(alusel_o_EXEX),
		.aluop_i(aluop_o_EXEX),
		.aluop_o(aluop_o_EXMEM),
		.mem_waddr_o(mem_waddr_o_EXMEM),
		.jump_flag_o(jump_flag),
		.jump_addr_o(jump_addr)
	  );

//EX/MEM
ex_mem ex_mem0 ( 
		.rst(rst),
		.clk (clk),
		.reg_we_i( reg_we_o_EXMEM),
		.reg_waddr_i( reg_waddr_o_EXMEM),
        .reg_wdata_i (reg_wdata_o_EXMEM),
		.reg_wdata_o (reg_wdata_o_MEMMEM),
		.reg_we_o (reg_we_o_MEMMEM),
		.reg_waddr_o(reg_waddr_o_MEMMEM),
		.aluop_i(aluop_o_EXMEM),
		.aluop_o(aluop_o_MEMMEM),
		.mem_waddr_i(mem_waddr_o_EXMEM),
		.mem_waddr_o(mem_waddr_o_MEMMEM)
	  );
	  
//MEM
mem mem0 (
        .rst(rst),
        .reg_wdata_i (reg_wdata_o_MEMMEM),
		.reg_we_i(reg_we_o_MEMMEM),
		.reg_waddr_i( reg_waddr_o_MEMMEM),
		.reg_wdata_o (reg_wdata_o_MEMWB),
		.reg_we_o (reg_we_o_MEMWB),
		.reg_waddr_o(reg_waddr_o_MEMWB),
		.mem_waddr_i(mem_waddr_o_MEMMEM),
		.aluop_i(aluop_o_MEMMEM),
		.ram_r_data_i(ram_r_data_i),
		.ram_we_o(ram_we_o),
		.ram_req_o(ram_req_o),
		.ram_addr_o(ram_addr_o),
		.ram_wdata_o(ram_wdata_o),
		.ram_state_o(ram_state_o)
       );
// MEM/WB
mem_wb mem_wb0(
        .rst(rst),
        .clk (clk),
        .reg_wdata_i (reg_wdata_o_MEMWB),
		.reg_we_i(reg_we_o_MEMWB),
		.reg_waddr_i( reg_waddr_o_MEMWB),
		.reg_wdata_o (reg_wdata_o_WBREG),
		.reg_we_o (reg_we_o_WBREG),
		.reg_waddr_o(reg_waddr_o_WBREG)
       );
    
    
    
endmodule
