`timescale 1ns / 1ps
//全局
`define AluOpBus 4:0
`define AluSelBus 2:0
`define AluOpBus 4:0
`define AluSelBus 2:0
`define True 1'b1
`define False 1'b0

`define RstEnable 1'b1
`define RstDisable 1'b0
`define ZeroWord 32'h00000000
`define ZeroReg 5'h0
`define WriteEnable 1'b1
`define WriteDisable 1'b0
`define ReadEnable 1'b1
`define ReadDisable 1'b0
`define InstValid 1'b0
`define InstInvalid 1'b1
`define Stop 1'b1
`define NoStop 1'b0
`define Branch 1'b1
`define NotBranch 1'b0
`define InterruptAssert 1'b1
`define InterruptNotAssert 1'b0
`define TrapAssert 1'b1
`define TrapNotAssert 1'b0
`define True_v 1'b1
`define False_v 1'b0
`define ChipEnable 1'b1
`define ChipDisable 1'b0

// I type inst
`define INST_TYPE_I 7'b0010011
`define INST_ADDI   3'b000
`define INST_SLTI   3'b010
`define INST_SLTIU  3'b011
`define INST_XORI   3'b100
`define INST_ORI    3'b110
`define INST_ANDI   3'b111
`define INST_SLLI   3'b001
`define INST_SRI    3'b101

// L type inst
`define INST_TYPE_L 7'b0000011
`define INST_LB     3'b000
`define INST_LH     3'b001
`define INST_LW     3'b010
`define INST_LBU    3'b100
`define INST_LHU    3'b101

// S type inst
`define INST_TYPE_S 7'b0100011
`define INST_SB     3'b000
`define INST_SH     3'b001
`define INST_SW     3'b010

// R and M type inst
`define INST_TYPE_R 7'b0110011
// R type inst
`define INST_ADD_SUB 3'b000
`define INST_SLL    3'b001
`define INST_SLT    3'b010
`define INST_SLTU   3'b011
`define INST_XOR    3'b100
`define INST_SR     3'b101
`define INST_OR     3'b110
`define INST_AND    3'b111
// M type inst
`define INST_MUL    3'b000
`define INST_MULH   3'b001
`define INST_MULHSU 3'b010
`define INST_MULHU  3'b011
`define INST_DIV    3'b100
`define INST_DIVU   3'b101
`define INST_REM    3'b110
`define INST_REMU   3'b111

// J type inst
`define INST_JAL    7'b1101111
`define INST_JALR   7'b1100111

`define INST_LUI    7'b0110111
`define INST_AUIPC  7'b0010111
`define INST_NOP    32'h00000001
`define INST_NOP_OP 7'b0000001
`define INST_MRET   32'h30200073
`define INST_RET    32'h00008067

`define INST_FENCE  7'b0001111
`define INST_ECALL  32'h73
`define INST_EBREAK 32'h00100073

// J type inst
`define INST_TYPE_B 7'b1100011
`define INST_BEQ    3'b000
`define INST_BNE    3'b001
`define INST_BLT    3'b100
`define INST_BGE    3'b101
`define INST_BLTU   3'b110
`define INST_BGEU   3'b111




//指令存储器inst_rom
`define InstAddrBus 31:0
`define InstBus 31:0
`define InstMemNum 1024
`define InstMemNumLog2 10
`define RomNum 1024  // rom depth(how many words)
`define MemNum 1024  // memory depth(how many words)
`define MemNumLog2 10
`define MemBus 31:0
`define MemAddrBus 31:0


//通用寄存器regfile
`define RegAddrBus 4:0
`define RegBus 31:0
`define RegWidth 32
`define DoubleRegWidth 64
`define DoubleRegBus 63:0
`define RegNum 32
`define RegNumLog2 5
`define NOPRegAddr 5'b00000

//alu_op 
`define EX_NOP   5'h0
`define EX_ADD   5'h1
`define EX_SUB   5'h2
`define EX_SLT   5'h3
`define EX_SLTU  5'h4
`define EX_XOR   5'h5
`define EX_OR    5'h6
`define EX_AND   5'h7
`define EX_SLL   5'h8
`define EX_SRL   5'h9
`define EX_SRA   5'ha
`define EX_AUIPC 5'hb

`define EX_JAL   5'hc
`define EX_JALR  5'hd
`define EX_BEQ   5'he
`define EX_BNE   5'hf
`define EX_BLT   5'h10
`define EX_BGE   5'h11
`define EX_BLTU  5'h12
`define EX_BGEU  5'h13

`define EX_LB    5'h14
`define EX_LH    5'h15
`define EX_LW    5'h16
`define EX_LBU   5'h17
`define EX_LHU   5'h18

`define EX_SB    5'h19
`define EX_SH    5'h1a
`define EX_SW    5'h1b

`define MEM_NOP   5'h0

//alu_sel
`define EX_RES_NOP      3'b000
`define EX_RES_LOGIC    3'b001
`define EX_RES_SHIFT    3'b010
`define EX_RES_ARITH    3'b011
`define EX_RES_JAL      3'b100
`define EX_RES_LD_ST    3'b101
`define EX_RES_NOP      3'b000
