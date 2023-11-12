`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/25 22:33:32
// Design Name: 
// Module Name: ex
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

module ex(

    input wire rst,

    // from id
    input wire[`InstBus] inst_i,            // 指令内容
    input wire[`InstAddrBus] inst_addr_i,   // 指令地址
    input wire reg_we_i,                    // 是否写通用寄存器
    input wire[`RegAddrBus] reg_waddr_i,    // 写通用寄存器地址
    input wire[`RegBus] reg1_rdata_i,
    input wire[`RegBus] reg2_rdata_i,
    input wire [`RegBus] offset_i,
    
    input wire [`AluSelBus]      alusel_i,
    input wire [`AluOpBus]       aluop_i,

    // to mem

    output reg[`MemAddrBus] mem_waddr_o,    // 写内存地址
    // to regs
    output reg[`RegBus] reg_wdata_o,       // 写寄存器数据
    output reg reg_we_o,                   // 是否要写通用寄存器
    output reg[`RegAddrBus] reg_waddr_o,   // 写通用寄存器地址\
    output reg [`AluOpBus]       aluop_o,


    output reg jump_flag_o,
    output reg [`InstAddrBus] jump_addr_o
    );

    
    reg[`RegBus] logicout;
    reg[`RegBus] shiftout;
    reg[`RegBus] arithout;
       
       
       
       always @ (*) begin // Branch and Jump
    jump_addr_o  = `ZeroWord;
    jump_flag_o    = `False;
    
    if (rst != `RstEnable) begin
        case (aluop_i)
          `EX_BEQ: begin
                
                if (reg1_rdata_i == reg2_rdata_i) begin
                   jump_addr_o  = inst_addr_i + offset_i;
                    jump_flag_o     = `True;
               
            end
            end
            `EX_BNE: begin
                if (reg1_rdata_i != reg2_rdata_i) begin
                    jump_addr_o  = inst_addr_i + offset_i;
                    jump_flag_o     = `True;
                end 

            end
            `EX_BLT: begin

                if ($signed(reg1_rdata_i) < $signed(reg2_rdata_i)) begin
                    jump_addr_o  = inst_addr_i + offset_i;
                    jump_flag_o     = `True;
                end 
            end
            `EX_BGE: begin

                if ($signed(reg1_rdata_i) >= $signed(reg2_rdata_i)) begin
                    jump_addr_o  = inst_addr_i + offset_i;
                    jump_flag_o     = `True;
                
            end
            end
            `EX_BLTU: begin

                if (reg1_rdata_i < reg2_rdata_i) begin
                    jump_addr_o  = inst_addr_i + offset_i;
                    jump_flag_o     = `True;
                end
            end
            `EX_BGEU: begin
                if (reg1_rdata_i >= reg2_rdata_i) begin
                    jump_addr_o  = inst_addr_i + offset_i;
                    jump_flag_o     = `True;
                end
            end
            `EX_JAL: begin
                    jump_addr_o  = inst_addr_i + offset_i;
                    jump_flag_o  = `True;
            end
            `EX_JALR: begin
                    jump_addr_o  = inst_addr_i + offset_i+reg1_rdata_i;
                    jump_flag_o     = `True;
            end
            default: begin
            jump_addr_o  = `ZeroWord;
            jump_flag_o    = `False;
            end
        endcase
    end
end
       
       
   always @ (*) begin // Logic
    if (rst == `RstEnable) begin
        logicout = `ZeroWord;
    end else begin
        case (aluop_i)
            `EX_OR: begin
                logicout = reg1_rdata_i | reg2_rdata_i;
            end
            `EX_XOR: begin
                logicout = reg1_rdata_i ^ reg2_rdata_i;
            end
            `EX_AND: begin
                logicout = reg1_rdata_i & reg2_rdata_i;
            end
            default: begin
                logicout = `ZeroWord;
            end
        endcase
    end
end

always @ (*) begin // Shift
    if (rst == `RstEnable) begin
        shiftout = `ZeroWord;
    end else begin
        case (aluop_i)
            `EX_SLL: begin
                shiftout = reg1_rdata_i << (reg2_rdata_i[4:0]);
            end
            `EX_SRL: begin
                shiftout = reg1_rdata_i >> (reg2_rdata_i[4:0]);
            end
            `EX_SRA: begin
                shiftout = (reg1_rdata_i >> (reg2_rdata_i[4:0])) | ({32{reg1_rdata_i[31]}} << (6'd32 - {1'b0,reg2_rdata_i[4:0]}));
            end
            default: begin
                shiftout = `ZeroWord;
            end
        endcase
    end
end

always @ ( * ) begin // Arithmetic
    if(rst == `RstEnable) begin
        arithout = `ZeroWord;
    end else begin
        case(aluop_i)
            `EX_ADD: begin
                arithout = reg1_rdata_i + reg2_rdata_i;
            end
            `EX_SUB: begin
                arithout = reg1_rdata_i - reg2_rdata_i;
            end
            `EX_SLT: begin
                arithout = $signed(reg1_rdata_i) < $signed(reg2_rdata_i);
            end
            `EX_SLTU : begin
                arithout = reg1_rdata_i < reg2_rdata_i;
            end
            `EX_AUIPC: begin
                arithout =inst_i + offset_i;
              end
            default: begin
                arithout = `ZeroWord;
            end
        endcase
    end
end

always @ ( * ) begin // Load and Store
    if(rst == `RstEnable) begin
        mem_waddr_o = `ZeroWord;
      //  reg_we_o = `False;
    end else begin
        case(aluop_i)
            `EX_SH, `EX_SB, `EX_SW: begin
                mem_waddr_o = reg1_rdata_i + offset_i;
             //   reg_we_o = `False;
            end
            `EX_LW, `EX_LH, `EX_LB, `EX_LHU, `EX_LBU: begin
                mem_waddr_o = reg1_rdata_i + offset_i;
               // reg_we_o = `True;
            end
            default: begin
                mem_waddr_o = `ZeroWord;
                //reg_we_o = `False;
            end
        endcase
    end
end      
       
always @ ( * ) begin // MUX
    if ((rst == `RstEnable) || ( reg_we_i == `True &&  reg_waddr_i == `ZeroWord)) begin
        reg_waddr_o    = `ZeroWord;
        reg_we_o  = `False;
        reg_wdata_o = `ZeroWord;
        aluop_o = `MEM_NOP;
    end else begin
            reg_waddr_o    = reg_waddr_i;
            reg_we_o  = reg_we_i;
        case (alusel_i)
            `EX_RES_JAL: begin
              reg_wdata_o = inst_i + 4;
              aluop_o = `MEM_NOP;
            end
            `EX_RES_LOGIC: begin
                reg_wdata_o = logicout;
                aluop_o = `MEM_NOP;
            end
            `EX_RES_SHIFT: begin
                reg_wdata_o = shiftout;
                aluop_o = `MEM_NOP;
            end
            `EX_RES_ARITH: begin
                reg_wdata_o = arithout;
                aluop_o = `MEM_NOP;
            end
            `EX_RES_LD_ST: begin
                reg_wdata_o = reg2_rdata_i;
                aluop_o = aluop_i;
            end
            `EX_RES_NOP: begin
                reg_wdata_o =`ZeroWord;
                aluop_o = `MEM_NOP;
            end
            default: begin
                reg_wdata_o = `ZeroWord;
                aluop_o = `MEM_NOP;
            end
        endcase
    end
end      

endmodule
