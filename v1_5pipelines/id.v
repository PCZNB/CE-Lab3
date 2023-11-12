`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/25 20:45:51
// Design Name: 
// Module Name: id
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

module id(
	input wire rst,
	
	// from if_id
    input wire[`InstBus] inst_i,             
    input wire[`InstAddrBus] inst_addr_i,    

    // from regs
    input wire[`RegBus] reg1_rdata_i,        
    input wire[`RegBus] reg2_rdata_i,       
    
     // to regs
    output reg[`RegAddrBus] reg1_raddr_o,   
    output reg[`RegAddrBus] reg2_raddr_o,  
    output reg re1_o,   
    output reg re2_o,
    
// to ex
    output reg[`MemAddrBus] reg1_rdata_o,
    output reg[`MemAddrBus] reg2_rdata_o,
    output reg[`InstBus] inst_o,             // 指令内容
    output reg[`InstAddrBus] inst_addr_o,    // 指令地址
    output reg reg_we_o,                     // 写通用寄存器标志
    output reg[`RegAddrBus] reg_waddr_o,     // 写通用寄存器地址	
    
    output reg[`RegBus]      offset_o,         // 用于store
    output reg [`AluSelBus]      alusel_o,
    output reg [`AluOpBus]       aluop_o,
// from ex
    input wire [`RegAddrBus] ex_wd_i,
    input wire ex_wreg_i ,
    input wire [`RegBus] ex_wdata_i,
// from mem
    input wire [`RegAddrBus] mem_wd_i,
    input wire mem_wreg_i ,
    input wire [`RegBus] mem_wdata_i
    );
    
    wire[6:0] opcode = inst_i[6:0];
    wire[2:0] funct3 = inst_i[14:12];
    wire[6:0] funct7 = inst_i[31:25];
    wire[4:0] rd = inst_i[11:7];
    wire[4:0] rs1 = inst_i[19:15];
    wire[4:0] rs2 = inst_i[24:20];
   
always @ (*) begin
if(rst == `RstEnable) begin
            inst_o <=  `ZeroWord;
            inst_addr_o <=  `ZeroWord;
			reg1_raddr_o <=  `ZeroWord;
			reg2_raddr_o <=  `ZeroWord;
			re1_o <=  1'b0;
			re2_o <=  1'b0;
            reg_waddr_o <= `ZeroWord;
			reg_we_o <= 1'b0;
			offset_o <= `ZeroWord;
			aluop_o =      `EX_NOP;
            alusel_o =     `EX_RES_NOP;
end else begin
        inst_o = inst_i;
        inst_addr_o = inst_addr_i;  
case (opcode)
            `INST_TYPE_I: begin
                case (funct3)
                    `INST_ADDI: begin
                        reg_we_o = `WriteEnable;
                        reg_waddr_o  = rd;
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = `ZeroWord;
                        re1_o <=  1'b1;
			            re2_o <=  1'b0;
                        offset_o <= {{20{inst_i[31]}}, inst_i[31:20]};
                        aluop_o =      `EX_ADD;
                        alusel_o =     `EX_RES_ARITH;
                    end
                     `INST_SLTI: begin
                        reg_we_o = `WriteEnable;
                        reg_waddr_o  = rd;
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = `ZeroWord;
                        re1_o <=  1'b1;
			            re2_o <=  1'b0;
                        offset_o <= {{20{inst_i[31]}}, inst_i[31:20]};
                         aluop_o =      `EX_SLT;
                        alusel_o =     `EX_RES_ARITH;
                    end
                     `INST_SLTIU: begin
                        reg_we_o = `WriteEnable;
                        reg_waddr_o  = rd;
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = `ZeroWord;
                        re1_o <=  1'b1;
			            re2_o <=  1'b0;
                        offset_o <= {{20{inst_i[31]}}, inst_i[31:20]};
                        aluop_o =      `EX_SLTU;
                        alusel_o =     `EX_RES_ARITH;
                    end
                    `INST_XORI: begin
                        reg_we_o = `WriteEnable;
                        reg_waddr_o  = rd;
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = `ZeroWord;
                        re1_o <=  1'b1;
			            re2_o <=  1'b0;
                        offset_o <= {{20{inst_i[31]}}, inst_i[31:20]};
                        aluop_o =      `EX_XOR;
                        alusel_o =     `EX_RES_LOGIC;
                    end
                    `INST_ORI: begin
                        reg_we_o = `WriteEnable;
                        reg_waddr_o  = rd;
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = `ZeroWord;
                        re1_o <=  1'b1;
			            re2_o <=  1'b0;
                        offset_o <= {{20{inst_i[31]}}, inst_i[31:20]};
                        aluop_o =      `EX_OR;
                        alusel_o =     `EX_RES_LOGIC;
                    end
                     `INST_ANDI: begin
                        reg_we_o = `WriteEnable;
                        reg_waddr_o  = rd;
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = `ZeroWord;
                        re1_o <=  1'b1;
			            re2_o <=  1'b0;
                        offset_o <= {{20{inst_i[31]}}, inst_i[31:20]};
                        aluop_o =      `EX_AND;
                        alusel_o =     `EX_RES_LOGIC;
                    end
                    `INST_SLLI: begin
                        reg_we_o = `WriteEnable;
                        reg_waddr_o  = rd;
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = `ZeroWord;
                        re1_o <=  1'b1;
			            re2_o <=  1'b0;
                        offset_o <= {{20{inst_i[31]}}, inst_i[31:20]};
                        aluop_o =      `EX_SLL;
                        alusel_o =     `EX_RES_SHIFT;
                    end
                  `INST_SRI: begin
                  case(inst_i[30])
                  1'b1: begin //SRAI
                        reg_waddr_o  = rd;
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = `ZeroWord;
                        re1_o <=  1'b1;
			            re2_o <=  1'b0;
                        offset_o <= {{20{inst_i[31]}}, inst_i[31:20]};
                        aluop_o = `EX_SRA;
                        alusel_o =     `EX_RES_SHIFT;
                        end
                  1'b0 :begin //SRLI
                        reg_waddr_o  = rd;
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = `ZeroWord;
                        re1_o <=  1'b1;
			            re2_o <=  1'b0;
                        offset_o <= {{20{inst_i[31]}}, inst_i[31:20]};
                        aluop_o = `EX_SRL;
                        alusel_o =     `EX_RES_SHIFT;
                        end
                  default:begin
                        reg_we_o = `WriteDisable;
                        reg_waddr_o = `ZeroWord;
                        reg1_raddr_o = `ZeroWord;
                        reg2_raddr_o = `ZeroWord;
                        re1_o <=  1'b1;
			            re2_o <=  1'b0;
                        offset_o <= `ZeroWord;
                        aluop_o =      `EX_NOP;
                        alusel_o =     `EX_RES_NOP;
                        end      
                     endcase
                   end              
                    default: begin
                        reg_we_o = `WriteDisable;
                        reg_waddr_o = `ZeroWord;
                        reg1_raddr_o = `ZeroWord;
                        reg2_raddr_o = `ZeroWord;
                        re1_o <=  1'b1;
			            re2_o <=  1'b0;
                        offset_o <= `ZeroWord;
                        aluop_o =      `EX_NOP;
                        alusel_o =     `EX_RES_NOP;
                    end
                    endcase
            end
       `INST_TYPE_R: begin
                case (funct3)
                    `INST_ADD_SUB: begin
                        reg_we_o = `WriteEnable;
                        reg_waddr_o  = rd;
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = rs2;
                        re1_o <=  1'b1;
			            re2_o <=  1'b1;
                        offset_o <= `ZeroWord;
                        alusel_o =  `EX_RES_ARITH;
                        case(inst_i[30])
                         1'b1: aluop_o =      `EX_SUB;
                         1'B0: aluop_o =      `EX_ADD;
                        endcase        
                    end
                     `INST_SLT: begin
                        reg_we_o = `WriteEnable;
                        reg_waddr_o  = rd;
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = rs2;
                        re1_o <=  1'b1;
			            re2_o <=  1'b1;
                        offset_o <= `ZeroWord;
                        aluop_o =      `EX_SLT;
                        alusel_o =     `EX_RES_ARITH;
                    end
                     `INST_SLTU: begin
                        reg_we_o = `WriteEnable;
                        reg_waddr_o  = rd;
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = rs2;
                        re1_o <=  1'b1;
			            re2_o <=  1'b1;
                        offset_o <= `ZeroWord;
                        aluop_o =      `EX_SLTU;
                        alusel_o =     `EX_RES_ARITH;
                    end
                    `INST_XOR: begin
                        reg_we_o = `WriteEnable;
                        reg_waddr_o  = rd;
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = rs2;
                        re1_o <=  1'b1;
			            re2_o <=  1'b1;
                        offset_o <= `ZeroWord;
                        aluop_o =      `EX_XOR;
                        alusel_o =     `EX_RES_LOGIC;
                    end
                    `INST_OR: begin
                        reg_we_o = `WriteEnable;
                        reg_waddr_o  = rd;
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = rs2;
                        re1_o <=  1'b1;
			            re2_o <=  1'b1;
                        offset_o <= `ZeroWord;
                        aluop_o =      `EX_OR;
                        alusel_o =     `EX_RES_LOGIC;
                    end
                     `INST_AND: begin
                        reg_we_o = `WriteEnable;
                        reg_waddr_o  = rd;
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = rs2;
                        re1_o <=  1'b1;
			            re2_o <=  1'b1;
                        offset_o <= `ZeroWord;
                        aluop_o =      `EX_AND;
                        alusel_o =     `EX_RES_LOGIC;
                    end
                    `INST_SLL: begin
                        reg_we_o = `WriteEnable;
                        reg_waddr_o  = rd;
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = rs2;
                        re1_o <=  1'b1;
			            re2_o <=  1'b1;
                        offset_o <= `ZeroWord;
                        aluop_o =      `EX_SLL;
                        alusel_o =     `EX_RES_SHIFT;
                    end
                  `INST_SR: begin
                  case(inst_i[30])
                  1'b1: begin //SRAI
                        reg_waddr_o  = rd;
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = rs2;
                        re1_o <=  1'b1;
			            re2_o <=  1'b1;
                        offset_o <= `ZeroWord;
                        aluop_o = `EX_SRA;
                        alusel_o =     `EX_RES_SHIFT;
                        end
                  1'b0 :begin //SRLI
                        reg_waddr_o  = rd;
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = rs2;
                        re1_o <=  1'b1;
			            re2_o <=  1'b1;
                        offset_o <= `ZeroWord;
                        aluop_o = `EX_SRL;
                        alusel_o =     `EX_RES_SHIFT;
                        end
                  default:begin
                        reg_we_o = `WriteDisable;
                        reg_waddr_o = `ZeroWord;
                        reg1_raddr_o = `ZeroWord;
                        reg2_raddr_o = `ZeroWord;
                        re1_o <=  1'b0;
			            re2_o <=  1'b0;
                        offset_o <= `ZeroWord;
                        aluop_o =      `EX_NOP;
                        alusel_o =     `EX_RES_NOP;
                        end      
                     endcase
                   end              
                    default: begin
                        reg_we_o = `WriteDisable;
                        reg_waddr_o = `ZeroWord;
                        reg1_raddr_o = `ZeroWord;
                        reg2_raddr_o = `ZeroWord;
                        offset_o <= `ZeroWord;
                        aluop_o =      `EX_NOP;
                        alusel_o =     `EX_RES_NOP;
                    end
                    endcase
            end
              `INST_TYPE_L: begin
                case (funct3)
                    `INST_LB: begin
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = `ZeroWord;
                        reg_we_o = `WriteEnable;
                        reg_waddr_o = rd;
                        re1_o <=  1'b1;
			            re2_o <=  1'b0;
                        offset_o <= {{20{inst_i[31]}}, inst_i[31:20]};
                        aluop_o =      `EX_LB;
                        alusel_o =     `EX_RES_LD_ST;
                    end
                     `INST_LH: begin
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = `ZeroWord;
                        reg_we_o = `WriteEnable;
                        reg_waddr_o = rd;
                        re1_o <=  1'b1;
			            re2_o <=  1'b0;
                        offset_o <=  {{20{inst_i[31]}}, inst_i[31:20]};
                        aluop_o =      `EX_LH;
                        alusel_o =     `EX_RES_LD_ST;
                    end
                    `INST_LW: begin
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = `ZeroWord;
                        reg_we_o = `WriteEnable;
                        reg_waddr_o = rd;
                        re1_o <=  1'b1;
			            re2_o <=  1'b0;
                        offset_o <={{20{inst_i[31]}}, inst_i[31:20]};
                        aluop_o =      `EX_LW;
                        alusel_o =     `EX_RES_LD_ST;
                    end
                    `INST_LBU: begin
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = `ZeroWord;
                        reg_we_o = `WriteEnable;
                        reg_waddr_o = rd;
                        re1_o <=  1'b1;
			            re2_o <=  1'b0;
                        offset_o <= {{20{inst_i[31]}}, inst_i[31:20]};
                        aluop_o =      `EX_LBU;
                        alusel_o =     `EX_RES_LD_ST;
                    end
                     `INST_LHU: begin
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = `ZeroWord;
                        reg_we_o = `WriteEnable;
                        reg_waddr_o = rd;
                        re1_o <=  1'b1;
			            re2_o <=  1'b0;
                        offset_o <= {{20{inst_i[31]}}, inst_i[31:20]};
                        aluop_o =      `EX_LHU;
                        alusel_o =     `EX_RES_LD_ST;
                    end
                    default: begin
                        reg1_raddr_o = `ZeroWord;
                        reg2_raddr_o = `ZeroWord;
                        reg_we_o = `WriteDisable;
                        reg_waddr_o = `ZeroWord;
                        re1_o <=  1'b0;
			            re2_o <=  1'b0;
                        offset_o <= `ZeroWord;
                        aluop_o =      `EX_NOP;
                        alusel_o =     `EX_RES_NOP;
                    end
                endcase
            end
            `INST_TYPE_S: begin
                case (funct3)
                    `INST_SB: begin
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = rs2;
                        reg_we_o = `WriteDisable;
                        reg_waddr_o =` ZeroWord;
                        re1_o <=  1'b1;
			            re2_o <=  1'b1;
                        offset_o <= {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
                        aluop_o =      `EX_SB;
                        alusel_o =     `EX_RES_LD_ST;
                    end
                    
                    `INST_SW: begin
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = rs2;
                        reg_we_o = `WriteDisable;
                        reg_waddr_o =` ZeroWord;
                        re1_o <=  1'b1;
			            re2_o <=  1'b1;
                        offset_o <= {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
                        aluop_o =      `EX_SW;
                        alusel_o =     `EX_RES_LD_ST;
                    end
                    
                     `INST_SH: begin
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = rs2;
                        reg_we_o = `WriteDisable;
                        reg_waddr_o =` ZeroWord;
                        re1_o <=  1'b1;
			            re2_o <=  1'b1;
                        offset_o <= {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
                        aluop_o =      `EX_SH;
                        alusel_o =     `EX_RES_LD_ST;
                    end
                    default: begin
                        reg1_raddr_o =`ZeroWord;
                        reg2_raddr_o = `ZeroWord;
                        reg_we_o = `WriteDisable;
                        reg_waddr_o = `ZeroWord;
                        re1_o <=  1'b1;
			            re2_o <=  1'b1;
                        offset_o <= `ZeroWord;
                        aluop_o =      `EX_NOP;
                        alusel_o =     `EX_RES_NOP;
                    end
                endcase
            end
        `INST_TYPE_B: begin    
         case (funct3)
                    `INST_BEQ: begin
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = rs2;
                        reg_we_o = `WriteDisable;
                        reg_waddr_o = `ZeroReg;
                        re1_o <=  1'b1;
			            re2_o <=  1'b1;
                        offset_o <= {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                        aluop_o =      `EX_BEQ;
                        alusel_o =     `EX_RES_NOP;
                    end
                    `INST_BNE: begin
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = rs2;
                        reg_we_o = `WriteDisable;
                        reg_waddr_o = `ZeroReg;
                        re1_o <=  1'b1;
			            re2_o <=  1'b1;
                        offset_o <= {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                        aluop_o =      `EX_BNE;
                        alusel_o =     `EX_RES_NOP;
                    end
                   `INST_BLT: begin
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = rs2;
                        reg_we_o = `WriteDisable;
                        reg_waddr_o = `ZeroReg;
                        re1_o <=  1'b1;
			            re2_o <=  1'b1;
                        offset_o <= {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                        aluop_o =      `EX_BLT;
                        alusel_o =     `EX_RES_NOP;
                    end
                    `INST_BGE: begin
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = rs2;
                        reg_we_o = `WriteDisable;
                        reg_waddr_o = `ZeroReg;
                        re1_o <=  1'b1;
			            re2_o <=  1'b1;
                        offset_o <= {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                        aluop_o =      `EX_BGE;
                        alusel_o =     `EX_RES_NOP;
                    end
                    `INST_BLTU: begin
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = rs2;
                        reg_we_o = `WriteDisable;
                        reg_waddr_o = `ZeroReg;
                        re1_o <=  1'b1;
			            re2_o <=  1'b1;
                        offset_o <= {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                        aluop_o =      `EX_BLTU;
                        alusel_o =     `EX_RES_NOP;
                    end
                    `INST_BGEU: begin
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = rs2;
                        reg_we_o = `WriteDisable;
                        reg_waddr_o = `ZeroReg;
                        re1_o <=  1'b1;
			            re2_o <=  1'b1;
                        offset_o <= {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                        aluop_o =      `EX_BGEU;
                        alusel_o =     `EX_RES_NOP;
                    end
                    default: begin
                        reg1_raddr_o =`ZeroWord;
                        reg2_raddr_o = `ZeroWord;
                        reg_we_o = `WriteDisable;
                        reg_waddr_o = `ZeroWord;
                        re1_o <=  1'b0;
			            re2_o <=  1'b0;
                        offset_o <= `ZeroWord;
                        aluop_o =      `EX_NOP;
                        alusel_o =     `EX_RES_NOP;
                    end
                endcase
            end
        `INST_JAL: begin
                reg_we_o = `WriteEnable;
                reg_waddr_o = rd;
                reg1_raddr_o = `ZeroReg;
                reg2_raddr_o = `ZeroReg;
                re1_o <=  1'b0;
			    re2_o <=  1'b0;
                offset_o = {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
                aluop_o =      `EX_JAL;
                alusel_o =     `EX_RES_JAL;
            end
         `INST_JALR: begin
                reg_we_o = `WriteEnable;
                reg1_raddr_o = rs1;
                reg2_raddr_o = `ZeroReg;
                re1_o <=  1'b1;
			    re2_o <=  1'b0;
                reg_waddr_o = rd;
                offset_o = {{20{inst_i[31]}}, inst_i[31:20]};
                aluop_o =      `EX_JALR;
                alusel_o =     `EX_RES_JAL;
            end
          `INST_LUI: begin
                reg_we_o = `WriteEnable;
                reg_waddr_o = rd;
                re1_o <=  1'b0;
			    re2_o <=  1'b0;
                offset_o = `ZeroWord;
                aluop_o =     `EX_OR;
                alusel_o =    `EX_RES_LOGIC;
            end
          `INST_AUIPC: begin
                reg_we_o = `WriteEnable;
                reg_waddr_o = rd;
                reg1_raddr_o = `ZeroReg;
                reg2_raddr_o = `ZeroReg;
                re1_o <=  1'b0;
			    re2_o <=  1'b0;
                offset_o =  {inst_i[31:12], 12'b0};
                aluop_o =     `EX_AUIPC;
                alusel_o =    `EX_RES_ARITH;
            end
            
                 default: begin
                reg_we_o = `WriteDisable;
                reg_waddr_o = `ZeroWord;
                reg1_raddr_o = `ZeroWord;
                reg2_raddr_o = `ZeroWord;
                re1_o <=  1'b0;
			    re2_o <=  1'b0;
                aluop_o =      `EX_NOP;
                alusel_o =     `EX_RES_NOP;
            end
        endcase
    end
end

always @ (*) begin
		if(rst == `RstEnable) begin
			reg1_rdata_o <= `ZeroWord;		
		end else if((re1_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg1_raddr_o)) begin
			reg1_rdata_o <= ex_wdata_i; 
		end else if((re1_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg1_raddr_o)) begin
			reg1_rdata_o <= mem_wdata_i; 			
	    end else if(re1_o == 1'b1) begin
            reg1_rdata_o <= reg1_rdata_i;
	   end else if(re1_o == 1'b0) begin
	  	reg1_rdata_o <= offset_o;
	  end else begin
	    reg1_rdata_o <= `ZeroWord;
	  end
end

always @ (*) begin
		if(rst == `RstEnable) begin
			reg2_rdata_o <= `ZeroWord;		
		end else if((re2_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg2_raddr_o)) begin
			reg2_rdata_o <= ex_wdata_i; 
		end else if((re2_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg2_raddr_o)) begin
			reg2_rdata_o <= mem_wdata_i; 			
	    end else if(re2_o == 1'b1) begin
            reg2_rdata_o <= reg2_rdata_i;
	   end else if(re2_o == 1'b0) begin
	  	   reg2_rdata_o <= offset_o;
	  end else begin
	    reg2_rdata_o <= `ZeroWord;
	  end
end
endmodule
