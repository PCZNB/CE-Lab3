// Template for Northwestern - CompEng 361 - Lab2
// Groupname: Russistor
// NetIDs:    bhp1038, viz3519

// Some useful defines...please add your own
`define OPCODE_COMPUTE    7'b0110011
`define OPCODE_IMMEDIATE  7'b0010011
`define OPCODE_BRANCH     7'b1100011
`define OPCODE_LOAD       7'b0000011
`define OPCODE_STORE      7'b0100011
`define OPCODE_JUMP       7'b1101111
`define OPCODE_JUMP_REG   7'b1100111
`define OPCODE_LOAD_UPPR  7'b0110111
`define OPCODE_ADD_UPPR   7'b0010111
// Define function codes
`define FUNC_SLL  3'b001
`define FUNC_SLT  3'b010
`define FUNC_SLTU 3'b011
`define FUNC_XOR  3'b100
`define FUNC_OR   3'b110
`define FUNC_AND  3'b111
`define FUNC_LB   3'b000
`define FUNC_LH   3'b001
`define FUNC_LW   3'b010
`define FUNC_LBU  3'b100
`define FUNC_LHU  3'b101
`define FUNC_SB   3'b000
`define FUNC_SH   3'b001
`define FUNC_SW   3'b010
`define FUNC_JUMP 3'b000
`define FUNC_BEQ  3'b000
`define FUNC_BNE  3'b001
`define FUNC_BLT  3'b100
`define FUNC_BGE  3'b101
`define FUNC_BLTU 3'b111
`define FUNC_BGEU 3'b110
`define FUNC_ADD_SUB  3'b000
`define FUNC_SRL_SRA  3'b101
`define AUX_FUNC_SUB  7'b0100000
`define AUX_FUNC_SRA  7'b0100000
`define SIZE_BYTE     2'b00
`define SIZE_HWORD    2'b01
`define SIZE_WORD     2'b10

`define ZeroWord 32'h00000000 // add a new define to subsitude 32b'0
`define RstEnable 1'b1  // add a define of rstenable value 1 is right?

module SingleCycleCPU(
    output halt, // Reset signal
    input  clk,  // Clock signal
    input  rst
);

   wire [31:0] PC, InstWord;
   wire [31:0] DataAddr, DataWord;
   wire [1:0]  MemSize;
   wire [31:0] StoreData;
   reg         MemWrEn;

   wire [4:0]  Rsrc1,  Rsrc2,  Rdst;
   wire [31:0] Rdata1, Rdata2, RWrdata;
   reg         RWrEn;

   wire [31:0] NPC, PC_Plus_4;
   wire [6:0]  opcode;

   wire [6:0]  funct7;
   wire [2:0]  funct3;
   wire [11:0] IImm, BImm, SImm;
   wire [19:0] UImm, JImm;
   wire [31:0]  Imm, ext_imm,
                     ext_data;
        // Assuming these are not defined elsewhere in your provided code
 // Assuming these are not defined elsewhere in your provided code
   wire [31:0] Instword_out;
   wire [31:0] ext_data_out;
   wire [31:0] euResult_final;
   wire [31:0] euResult_out;
   wire [31:0] PC_1, PC_2, PC_3, PC_4; // PC outputs from intermediate registers
   wire [31:0] Rdata1_out, Rdata2_out; // Data outputs from ID_EX Register
   wire [31:0] StoreData_out; // Store data output from EX_MEM Register
   wire [1:0] MemSize_out; // MemSize output from EX_MEM Register
   wire [21:0] id_ex_bus_out; // Output from ID_EX Register
   wire [4:0] ex_Rdst; // Extracted from id_ex_bus_out
   wire [4:0] ex_Rdst_pass, ex_Rdst_final; // Passed through intermediate registers
   wire [31:0] ext_imm_out; // Output from ID_EX Register



   // Only support R-TYPE ADD and SUB
   assign halt = !(
           (opcode == `OPCODE_COMPUTE)
        || (opcode == `OPCODE_IMMEDIATE)
        || (opcode == `OPCODE_LOAD)
        || (opcode == `OPCODE_STORE)
        || (opcode == `OPCODE_BRANCH)
        || (opcode == `OPCODE_JUMP)
        || (opcode == `OPCODE_JUMP_REG)
        || (opcode == `OPCODE_LOAD_UPPR)
        || (opcode == `OPCODE_ADD_UPPR)
    );






    ////////////////////////////////////////////////////////////////////////////////
    //IF Stage
    InstMem IMEM(
        .Addr(PC),          .Size(`SIZE_WORD),
        .DataOut(InstWord), .CLK(clk)
    );

    Reg PC_REG(
        .Din(curPC),  .Qout(PC),
        .WEN(1'b0), .CLK(clk),
        .RST(rst)
    );

    // IntermediateRegister Instance (Between IF and ID Stage)
    IF_ID IF_ID_Register(
        .clk(clk),
        .rst(rst),
        .pc_in(PC),          // PC value from PC_REG
        .rs1_in(InstWord),   // InstWord value from the previous stage (IF)
        .pc_out(PC_1),       // PC value to ID stage
        .rs1_out(Instword_out) // Instruction word to ID stage
    ); // <-- Semicolon to end the instantiation


   //放在if阶段，但是接口没接， 可能和pc-reg功能有重叠
    
    wire PCsrc = 1'b0;
    wire currentpc; 

    PC PCBranch(
        .clk(clk),
        .rst(rst),
        .PCsrc(PCsrc),
        .newPC(PC_3),
        .PCdelay(delay),
        .prePC(PC_1),
        .curPC(currentpc)

    );
    





/////////////////////////////////////////////////////////////////////////////////////////
// ID/WB Stage
    assign opcode = Instword_out[6:0];
    assign Rdst   = Instword_out[11:7];
    assign Rsrc1  = Instword_out[19:15];
    assign Rsrc2  = Instword_out[24:20];
    assign funct3 = Instword_out[14:12];  // R-Type, I-Type, S-Type
    assign funct7 = Instword_out[31:25];  // R-Type

    assign IImm = Instword_out[31:20];
    assign UImm = Instword_out[31:12];


    wire [21:0] id_ex_bus;
    assign id_ex_bus = {funct7, funct3, Rdst, opcode}; // Concatenation

    assign SImm = {
        Instword_out[31:25],
        Instword_out[11:7]
    };

    assign BImm = {
        Instword_out[31],
        Instword_out[7],
        Instword_out[30:25],
        Instword_out[11:8]
    };

    assign JImm = {
        Instword_out[31],
        Instword_out[19:12],
        Instword_out[20],
        Instword_out[30:21]
    };

    assign Imm =
           (opcode == `OPCODE_IMMEDIATE)
        || (opcode == `OPCODE_LOAD)
        || (opcode == `OPCODE_JUMP_REG)  ? IImm
        :  (opcode == `OPCODE_BRANCH)    ? BImm
        :  (opcode == `OPCODE_STORE)     ? SImm
        :  (opcode == `OPCODE_LOAD_UPPR)
        || (opcode == `OPCODE_ADD_UPPR)  ? UImm
        :  (opcode == `OPCODE_JUMP)      ? JImm
        :  32'hX;

///
    // Bubble
    reg [7:0] prev;
    reg [4:0] prerd;
    reg keep;
    reg delay;

    Stall bubble(
        .prev(prev), .rd(prevrd), .rs1(Rsrc1),
        .rs2(  (opcode == `OPCODE_COMPUTE)
            || (opcode == `OPCODE_STORE)
            || (opcode == `OPCODE_BRANCH)
             ? Rsrc2 : 32'b0),
        .clk(clk),   .halt(halt),
        .keep(keep), .delay(delay)
    );

    reg [4:0] oldrd;
    reg [1:0] fwd1;
    reg [1:0] fwd2;
    reg prekeep;
    reg oldkeep;
    reg prewr;
    reg oldwr;

    wire [31:0] euResult;
    assign RWrdata  = (opcode == `OPCODE_LOAD)
                    ? ext_data_out : euResult_final; // remember to add conditions
    assign DataAddr = euResult_out;

    RegFile RF(
        .AddrA(Rsrc1), .DataOutA(Rdata1),
        .AddrB(Rsrc2), .DataOutB(Rdata2),
        .AddrW(ex_Rdst_final),  .DataInW(RWrdata),
            .WenW(RWrEn),  .CLK(clk)
    );///read in ID and write in WB



    Extender imm_extender(
        .data_in(Imm), // Immediate from instruction
        .ext_type(
               (opcode == `OPCODE_BRANCH)    ? 4'b0001
            :  (opcode == `OPCODE_JUMP)      ? 4'b0010
            :  (opcode == `OPCODE_LOAD_UPPR)
            || (opcode == `OPCODE_ADD_UPPR)  ? 4'b0100
            :  4'd0
        ),             // Extended immediate output
        .data_out(ext_imm)
    );

    ID_EX ID_EX_Register(
        .clk(clk),
        .rst(rst),
        .pc_in(PC_1),
        .rs1_in(Rdata1),
        .rs2_in(Rdata2),
        .rs3_in(ext_imm),
        .rs4_in(id_ex_bus),
        .pc_out(PC_2),
        .rs1_out(Rdata1_out),
        .rs2_out(Rdata2_out),
        .rs3_out(ext_imm_out),
        .rs4_out(id_ex_bus_out)
    );








    /////////////////////////////////////
    //Ex Stage

    Forward fwd(
        .rs1(Rdata1_out),
        .rs2(  (opcode == `OPCODE_COMPUTE)
            || (opcode == `OPCODE_STORE)
            || (opcode == `OPCODE_BRANCH)
             ? Rdata2_out : 32'b0),
        .rd1(id_ex_bus[11:7]),
        .rd2(InstWord[11:7]),
        .output1(prekeep && prewr),
        .output2(oldkeep && oldwr),
        .clk(clk),
        .fwd1(fwd1),
        .fwd2(fwd2)
    );


    always @ (*) begin
        MemWrEn <= (opcode != `OPCODE_STORE);
        RWrEn   <= (opcode == `OPCODE_BRANCH)
                || (opcode == `OPCODE_STORE);
    end


    wire [6:0] ex_funct7;
    wire [2:0] ex_funct3;
    wire [6:0] ex_opcode;

    assign {ex_funct7, ex_funct3, ex_Rdst, ex_opcode} = id_ex_bus_out;



    ExecutionUnit eu(
        .result(euResult),  // Output of the EU goes to the register file or data memory
        .opA(Rdata1_out),       // Operand A comes from the register file (rs1)
        .opB(Rdata2_out),       // Operand B is immediate for I-type and load and save instructions, or rs2 for R-type
        .func(ex_funct3),
        .aux_func(ex_funct7),  // Auxiliary function field from the instruction (not used for I-type)
        .opcode(ex_opcode),    // Opcode to determine the operation
        .MemSize(MemSize),

        .imm(ext_imm_out),
        .oldPC(PC_2),
        .newPC(NPC),
        .memdata(StoreData),
        .PCsrc(PCjump)

    );

    wire PCjump;

    EX_MEM EX_MEM_Register(
        .clk(clk),
        .rst(rst),
        .pc_in(NPC),
        .rs1_in(euResult),
        .rs2_in(MemSize),
        .rs3_in(StoreData),
        .rs4_in(ex_Rdst),
        .pc_out(PC_3),
        .rs1_out(euResult_out),
        .rs2_out(MemSize_out),
        .rs3_out(StoreData_out),
        .rs4_out(ex_Rdst_pass),
        .PC_jump(PCjump),
        .PC_jump_out(PCsrc)
    );


//////////////////////////////////////////////////////
    /////DM Stage
    DataMem DMEM(
        .Addr(DataAddr),    .Size(MemSize),
        .DataIn(StoreData_out), .DataOut(DataWord),
        .WEN(MemWrEn),      .CLK(clk)
    );
    Extender data_extender(
        .data_in(DataWord),        // Data read from memory
        .ext_type({1'b1, funct3}), // Type of extension for the data (sign, zero, etc.)
        .data_out(ext_data)        // Extended data output for register file
    );

    MEM_WB MEM_WB_Register(
        .clk(clk),
        .rst(rst),
        .pc_in(PC_3),
        .rs1_in(ext_data),
        .rs2_in(euResult_out),
        .rs3_in(ex_Rdst_pass),
        .pc_out(PC_4),
        .rs1_out(ext_data_out),
        .rs2_out(euResult_final),
        .rs3_out(ex_Rdst_final)
    );





    /*
    always @ (negedge clk) begin
        MemWrEn <= (opcode != `OPCODE_STORE);
    end
    */

    // Control signals for memory write operations
    /*
    always @(*) begin
        if (opcode == `OPCODE_STORE) begin
            MemWrEn = 1'b1; // Enable memory write for store operations
            // Determine the memory size and prepare StoreData for store operations
            case (funct3)
                `FUNC_SB: StoreData = {Rdata2[7:0]};  // Prepare byte to store
                `FUNC_SH: StoreData = {Rdata2[15:0]}; // Prepare halfword to store
                `FUNC_SW: StoreData = Rdata2;         // Prepare word to store
                default:  StoreData = 32'hX;          // Undefined behavior
            endcase
        end else begin
            MemWrEn   = 1'b0;  // Disable memory write for non-store operations
            StoreData = 32'hX; // Clear StoreData for non-store operations
        end
    end
    */



   // Hardwired to support R-Type instructions -- please add muxes and other control signals
   // EU instantiation for R-type (COMPUTE) operations
   // Control signals (these would be set by your control unit)







   // Control unit (not shown) would set 'euSrc' based on the instruction type
   // For example, if the opcode indicates an I-type instruction, 'euSrc' would be set to 1



   // Fetch Address Datapath
   // assign PC_Plus_4 = PC + 4;
   // assign NPC = PC_Plus_4;

endmodule // SingleCycleCPU


module Forward(
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd1,
    input [4:0] rd2,
    input output1,
    input output2,
    input clk,

    output reg [1:0] fwd1,
    output reg [1:0] fwd2
);

initial begin
    fwd1 <= 0;
    fwd2 <= 0;
end

always @(posedge clk) begin
    if (output1) begin
        if (rd1 == rs1) begin
            fwd1 <= fwd1 | 2'b01;
        end

        if (rd1 == rs2) begin
            fwd1 <= fwd1 | 2'b10;
        end
    end

    if (output2) begin
        if (rd2 == rs1) begin
            fwd2 <= fwd2 | 2'b01;
        end

        if (rd2 == rs2) begin
            fwd2 <= fwd2 | 2'b10;
        end
    end
end

endmodule


module Stall(
    input [7:0] prev,
    input [4:0] rd,
    input [4:0] rs1,
    input [4:0] rs2,
    input clk,
    input halt,
    output reg keep,
    output reg delay
);

reg temp;

initial begin
    keep  <= 0;
    delay <= 0;
end

always @(negedge clk) begin
    keep <= temp;
end

always @(opcode or halt) begin
    if (halt) begin
        temp  <= 0;
        delay <= 0;
    end
    else begin
        if (prev == `OPCODE_LOAD) begin
            if (rs1 == rd) begin
                keep  <= 1;
                delay <= 1;
            end
            else if (rs2 == rd) begin
                keep  <= 1;
                delay <= 1;
            end
            else begin
                keep  <= 1;
                delay <= 0;
            end
        end
        else begin
            temp  <= 1;
            delay <= 0;
        end
    end
end

endmodule


module ExecutionUnit(
    input [31:0] oldPC,
    input [31:0] imm,
    input [31:0] opA,         // Operand A (rs1)
    input [31:0] opB,         // Operand B (rs2 or immediate)
    input [2:0]  func,        // Function code (part of the instruction)
    input [6:0]  aux_func,    // Auxiliary function code (part of the instruction)
    input [6:0]  opcode,      // Opcode (part of the instruction)

    output reg [31:0] newPC,
    output reg [31:0] result, // output to RWrdata
    output reg [31:0] memdata,
    output reg MemWrEn,       // Memory Write Enable signal
    output reg [1:0] MemSize,  // Memory Size signal
    output reg PCsrc // 
);

// Intermediate signals
reg [31:0] loadStoreAddr;
reg [7:0]  loaded_byte;
reg [15:0] loaded_half;
reg [31:0] loaded_word;

// EU computation
always @(*) begin
    result    = 32'hX;
    MemWrEn   = 1'b1;
    MemSize   = 2'b10; // Default to word size



    case (opcode)
        `OPCODE_COMPUTE: begin // R-type instructions
            PCsrc = 1'b0;
            case (func)
                `FUNC_ADD_SUB: result = (aux_func == `AUX_FUNC_SUB)
                                      ? (opA - opB)
                                      : (opA + opB);
                `FUNC_SLL:     result = opA << opB;
                `FUNC_SLT:     result = ($signed(opA) < $signed(opB))
                                      ? 32'd1 : 32'd0;
                `FUNC_SLTU:    result = (opA < opB) ? 32'd1 : 32'd0;
                `FUNC_XOR:     result = opA ^ opB;
                `FUNC_SRL_SRA: result = (aux_func == `AUX_FUNC_SRA)
                                      ? ($signed(opA) >>> opB[4:0])
                                      : (opA >> opB[4:0]);
                `FUNC_OR:      result = opA | opB;
                `FUNC_AND:     result = opA & opB;
                default:       result = 32'hX; // Invalid operation
            endcase
        end

        `OPCODE_IMMEDIATE: begin // I-type instructions
            // Assuming 'immediate' is the immediate value extracted from the I-type instruction
            PCsrc = 1'b0;

            case (func)
                `FUNC_ADD_SUB: result = opA + imm;
                `FUNC_SLL:     result = opA << imm[4:0];
                `FUNC_SLT:     result = ($signed(opA) < imm)
                                      ? 32'd1 : 32'd0;
                `FUNC_SLTU:    result = (opA < imm)
                                      ? 32'd1 : 32'd0;
                `FUNC_XOR:     result = opA ^ imm;
                `FUNC_SRL_SRA: result = (imm[11:5] == `AUX_FUNC_SRA)
                                      ? ($signed(opA) >>> imm[4:0])
                                      : (opA >> imm[4:0]);
                `FUNC_OR:      result = opA | imm;
                `FUNC_AND:     result = opA & imm;
                default:       result = 32'hX; // Invalid operation
            endcase
        end

        `OPCODE_LOAD, `OPCODE_STORE: begin // Load and Store instructions
            result = opA   + imm;          // Calculate the address
            newPC  = oldPC + 4;
            PCsrc = 1'b0;

            // Determine the memory size for load/store operations
            case (func)
                `FUNC_LB, `FUNC_SB: MemSize = 2'b00; // Byte
                `FUNC_LH, `FUNC_SH: MemSize = 2'b01; // Halfword
                `FUNC_LW, `FUNC_SW: MemSize = 2'b10; // Word
                default:            MemSize = 2'b10; // Default to word size
            endcase

            if (opcode == `OPCODE_STORE) begin
                MemWrEn = 1'b1; // Enable memory write for store operations
                // Determine the memory size and prepare StoreData for store operations
                case (func)
                    `FUNC_SB: memdata = {opB[7:0]};  // Prepare byte to store
                    `FUNC_SH: memdata = {opB[15:0]}; // Prepare halfword to store
                    `FUNC_SW: memdata = opB;         // Prepare word to store
                    default:  memdata = 32'hX;       // Undefined behavior
                endcase
            end else begin
                MemWrEn = 1'b0;  // Disable memory write for non-store operations
                memdata = 32'hX; // Clear StoreData for non-store operations
            end
        end

        `OPCODE_BRANCH: begin
            result = 32'hX;
            case (func)
                `FUNC_BEQ: begin newPC = (opA == opB) ? oldPC + imm : oldPC + 4; 
                            PCsrc = (opA == opB) ? 1'b1 : 1'b0;
                end
                `FUNC_BNE:  begin newPC = (opA != opB) ? oldPC + imm : oldPC + 4;
                            PCsrc = (opA != opB) ? 1'b1 : 1'b0;
                end
                `FUNC_BLT:  begin newPC = (opA >= opB) ? oldPC + imm : oldPC + 4; 
                            PCsrc = (opA >= opB) ? 1'b1 : 1'b0;
                end
                `FUNC_BGE:  begin newPC = (opA  < opB) ? oldPC + imm : oldPC + 4; 
                            PCsrc = (opA < opB) ? 1'b1 : 1'b0;
                            end
                `FUNC_BLTU: begin newPC = ($signed(opA) >= $signed(opB)) ? oldPC + imm : oldPC + 4; 
                            PCsrc = ($signed(opA) >= $signed(opB)) ? 1'b1 : 1'b0;
                            end
                `FUNC_BGEU: begin newPC = ($signed(opA)  < $signed(opB)) ? oldPC + imm : oldPC + 4; 
                            PCsrc = ($signed(opA)  < $signed(opB)) ? 1'b1 : 1'b0;
                end
                default:    newPC = 32'hX;
            endcase
        end
             

        `OPCODE_JUMP:      begin
            PCsrc = 1'b1;
            result = oldPC + 4;
            newPC  = oldPC + imm;
        end

        `OPCODE_JUMP_REG:  begin
            PCsrc = 1'b1;
            result = oldPC + 4;
            newPC  = opA   + imm;
        end

        `OPCODE_LOAD_UPPR: begin
            result = imm;
            PCsrc = 1'b0;
        end

        `OPCODE_ADD_UPPR:  begin
            result = oldPC + imm;
            PCsrc = 1'b0;
        end

        // I-type instructions can be added here if needed
        default: result = 32'hX; // Default for unrecognized opcode
    endcase
end

endmodule


module Extender(
    input      [31:0] data_in,  // Input data (immediate or memory data)
    input      [3:0]  ext_type, // Extension type (00 for I-type, 01 for LB, 10 for LH, etc.)
    output reg [31:0] data_out  // Extended 32-bit output
);

    always @(*) begin
        case (ext_type)
            4'b0000: data_out = {{20{data_in[11]}}, data_in[11:0]}; // Sign-extension for I-type immediate
            4'b1000: data_out = {{24{data_in[7]}},  data_in[ 7:0]}; // Sign-extension for LB
            4'b1001: data_out = {{16{data_in[15]}}, data_in[15:0]}; // Sign-extension for LH
            4'b1010: data_out = data_in;                            //   No extension for LW
            4'b1100: data_out = {24'b0, data_in[ 7:0]};             // Zero-extension for LBU
            4'b1101: data_out = {16'b0, data_in[15:0]};             // Zero-extension for LHU
            // Add more cases if needed for other instruction types
            4'b0001: data_out = {{19{data_in[11]}}, data_in[11:0],  1'b0}; // B-type
            4'b0010: data_out = {{11{data_in[19]}}, data_in[19:0],  1'b0}; // J-type
            4'b0100: data_out = {                   data_in[19:0], 12'd0}; // U-type
            default: data_out = 32'hX; // Invalid operation
        endcase
    end

endmodule

module IF_ID(
    input wire clk,
    input wire rst, // Reset signal
    input wire PCsrc,
    input wire keep,
    input wire [31:0] pc_in, // PC value from previous stage
    input wire [31:0] rs1_in, // rs1 value from previous stage  //add wire to all input
    output reg [31:0] pc_out, // PC value to next stage
    output reg [31:0] rs1_out // rs1 value to next stage
);

    // Logic to update the register values on the clock edge
    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            pc_out <= `ZeroWord;
            rs1_out <= `ZeroWord;
        end else if(PCsrc)begin //跳转发生就清零，复制一下上面的部分，改一下控制信号就行了，记得把PCsrc指令接过来
	        pc_out <= `ZeroWord;
			rs1_out <= `ZeroWord;
        end else begin
            pc_out <= pc_in;
            rs1_out <= rs1_in;
        end
    end
endmodule

    /*always @(posedge clk or posedge rst) begin
        if (rst) {
            pc_out <= `ZeroWord; // Non-blocking for sequential logic
            rs1_out <= `ZeroWord; // Non-blocking for sequential logic
        } else {
            pc_out <= pc_in; // Non-blocking for sequential logic
            rs1_out <= rs1_in; // Non-blocking for sequential logic
        }
    end
endmodule*/




module ID_EX(
    input clk,
    input rst, // Reset signal
    input [31:0] pc_in, // PC value from previous stage
    input [31:0] rs1_in, // rs1 value from previous stage
    input [31:0] rs2_in, // rs2 value from previous stage
    input [31:0] rs3_in, // Immediate value from previous stage
    input [21:0] rs4_in, //bus
    input keep,
    output reg [31:0] pc_out, // PC value to next stage
    output reg [31:0] rs1_out, // rs1 value to next stage
    output reg [31:0] rs2_out, // rs2 value to next stage
    output reg [31:0] rs3_out, // Immediate value to next stage
    output reg [21:0] rs4_out
);

    // Logic to update the register values on the clock edge

always @(posedge clk) begin
        if (rst == `RstEnable) begin
            pc_out <= `ZeroWord;
            rs1_out <= `ZeroWord;
            rs2_out <= `ZeroWord;
            rs3_out <= `ZeroWord;
            rs4_out <= `ZeroWord;
            end else if(PCsrc)begin //跳转发生就清零，复制一下上面的部分，改一下控制信号就行了，记得把PCsrc指令接过来
	        pc_out <= `ZeroWord;
			rs1_out <= `ZeroWord;
            rs2_out <= `ZeroWord;
            rs3_out <= `ZeroWord;
            rs4_out <= `ZeroWord;
        end else begin
             pc_out <= pc_in;
            rs1_out <= rs1_in;
            rs2_out <= rs2_in;
            rs3_out <= rs3_in;
            rs4_out <= rs4_in;
        end
    end

   /* always @(posedge clk or posedge rst) begin
        if (rst) {
            // Initialize the output registers to a known state
            pc_out = 32'b0;
            rs1_out = 32'b0;
            rs2_out = 32'b0;
            rs3_out = 32'b0;
            rs4_out = 32'b0;
        } else {
            // Pass the values to the next stage
            pc_out = pc_in;
            rs1_out = rs1_in;
            rs2_out = rs2_in;
            rs3_out = rs3_in;
            rs4_out = rs4_in;
            
        }
    end */

endmodule

module EX_MEM(
    input clk,
    input rst, // Reset signal
    input [31:0] pc_in, // PC value from previous stage
    input [31:0] rs1_in, // rs1 value from previous stage
    input [1:0] rs2_in, // memorysize
    input [31:0] rs3_in, // Immediate value from previous stage
    input [4:0] rs4_in,
    input PC_jump,
    output reg [31:0] pc_out, // PC value to next stage
    output reg [31:0] rs1_out, // rs1 value to next stage
    output reg [1:0] rs2_out, // rs2 value to next stage
    output reg [31:0] rs3_out, // Immediate value to next stage
    output reg [4:0] rs4_out,
    output reg PC_jump_out

);

    // Logic to update the register values on the clock edge
    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            pc_out <= `ZeroWord;
            rs1_out <= `ZeroWord;
            rs2_out <= `ZeroWord;
            rs3_out <= `ZeroWord;
            rs4_out <= `ZeroWord;
            PC_jump_out <= 1'b0;

        end else begin
             pc_out <= pc_in;
            rs1_out <= rs1_in;
            rs2_out <= rs2_in;
            rs3_out <= rs3_in;
            rs4_out <= rs4_in;
            PC_jump_out <= PC_jump ;
        end
    end


    /*always @(posedge clk or posedge rst) begin
        if (rst) {
            // Initialize the output registers to a known state
            pc_out = 32'b0;
            rs1_out = 32'b0;
            rs2_out = 32'b0;
            rs3_out = 32'b0;
            rs4_out = 32'b0;
        } else {
            // Pass the values to the next stage
            pc_out = pc_in;
            rs1_out = rs1_in;
            rs2_out = rs2_in;
            rs3_out = rs3_in;
            rs4_out = rs4_in;
            
        }
    end*/
    

endmodule

module MEM_WB(
    input clk,
    input rst, // Reset signal
    input [31:0] pc_in, // PC value from previous stage
    input [31:0] rs1_in, // rs1 value from previous stage
    input [31:0] rs2_in, // rs2 value from previous stage
    input [4:0] rs3_in, // rdst

    output reg [31:0] pc_out, // PC value to next stage
    output reg [31:0] rs1_out, // rs1 value to next stage
    output reg [31:0] rs2_out, // rs2 value to next stage
    output reg [4:0] rs3_out // Immediate value to next stage
);

    // Logic to update the register values on the clock edge
    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            pc_out <= `ZeroWord;
            rs1_out <= `ZeroWord;
            rs2_out <= `ZeroWord;
            rs3_out <= `ZeroWord;
            PC_jump <= 0;
        end else begin
            pc_out <= pc_in;
            rs1_out <= rs1_in;
            rs2_out <= rs2_in;
            rs3_out <= rs3_in;
        end
    end

endmodule

module PC(
    input clk,               //时钟
    input rst,             //是否重置地址。1-初始化PC，否则接受新地址
    input PCsrc,             //数据选择器输入 ex_mem 中间reg
    input [31:0] newPC,  //ALU计算结果 ex_mem 中间reg
    input PCdelay, // bubble 来的信号
    input [31:0] prePC,  //前一个指令的地址，从if_id
    output reg[31:0] curPC  //当前指令的地址
);

    initial begin
        curPC <= -4; //初始值为-4
    end

    //复制的，没看出来有啥用
    reg [31:0] tmp;
    always @(tmp)  begin
        curPC <= tmp;
    end

    //检测时钟上升沿计算新指令地址 
    always@(posedge clk)
    // #20000 begin
    begin
        if (rst | PCdelay) begin
            if (Reset) begin
                tmp <= 0;
            end
            else tmp = prePC; //保持pc不变一个周期
        end
        else begin
            case(PCsrc)   //仿真时
                1'b0:   tmp <= curPC + 4;
                1'b1:   tmp <= newPC;//ex_mem传回来的新地址
            endcase
        end
    end

endmodule


    /*always @(posedge clk or posedge rst) begin
        if (rst) {
            // Initialize the output registers to a known state
            pc_out = 32'b0;
            rs1_out = 32'b0;
            rs2_out = 32'b0;
            rs3_out = 32'b0;
            rs4_out = 32'b0;
        } else {
            // Pass the values to the next stage
            pc_out = pc_in;
            rs1_out = rs1_in;
            rs2_out = rs2_in;
            rs3_out = rs3_in;
            rs4_out = rs4_in;
            
        }
    end*/
