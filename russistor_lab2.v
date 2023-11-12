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

   // System State (everything is neg assert)
   InstMem IMEM(
        .Addr(PC),          .Size(`SIZE_WORD),
        .DataOut(InstWord), .CLK(clk)
   );

   DataMem DMEM(
        .Addr(DataAddr),    .Size(MemSize),
        .DataIn(StoreData), .DataOut(DataWord),
        .WEN(MemWrEn),      .CLK(clk)
   );

   RegFile RF(
        .AddrA(Rsrc1), .DataOutA(Rdata1),
	.AddrB(Rsrc2), .DataOutB(Rdata2),
	.AddrW(Rdst),  .DataInW(RWrdata),
        .WenW(RWrEn),  .CLK(clk)
   );

   Reg PC_REG(
        .Din(NPC),  .Qout(PC),
        .WEN(1'b0), .CLK(clk),
        .RST(rst)
   );


    // Instruction Decode
    assign opcode = InstWord[6:0];
    assign Rdst   = InstWord[11:7];
    assign Rsrc1  = InstWord[19:15];
    assign Rsrc2  = InstWord[24:20];
    assign funct3 = InstWord[14:12];  // R-Type, I-Type, S-Type
    assign funct7 = InstWord[31:25];  // R-Type

    assign IImm = InstWord[31:20];
    assign UImm = InstWord[31:12];

    assign SImm = {
        InstWord[31:25],
        InstWord[11:7]
    };

    assign BImm = {
        InstWord[31],
        InstWord[7],
        InstWord[30:25],
        InstWord[11:8]
    };

    assign JImm = {
        InstWord[31],
        InstWord[19:12],
        InstWord[20],
        InstWord[30:21]
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

    /*
    wire [31:0] opB;
    assign opB = (opcode == `OPCODE_IMMEDIATE)
              || (opcode == `OPCODE_LOAD)
              || (opcode == `OPCODE_STORE)
               ? ext_imm : Rdata2; // Wrong
    */

    wire [31:0] euResult;
    assign RWrdata  = (opcode == `OPCODE_LOAD)
                    ? ext_data : euResult; // remember to add conditions
    assign DataAddr = euResult;

    // Control signals for register write enable
    /*
    always @(*) begin
        RWrEn = (opcode == `OPCODE_COMPUTE)
             || (opcode == `OPCODE_IMMEDIATE)
             || (opcode == `OPCODE_LOAD);
    end
    */
    /*
    assign RWrEn = (opcode == `OPCODE_COMPUTE)
                || (opcode == `OPCODE_IMMEDIATE)
                || (opcode == `OPCODE_LOAD)
                || (opcode == `OPCODE_JUMP)
                || (opcode == `OPCODE_JUMP_REG)
                || (opcode == `OPCODE_LOAD_UPPR)
                || (opcode == `OPCODE_ADD_UPPR);
    */
    always @ (posedge clk) begin
        MemWrEn <= (opcode != `OPCODE_STORE);
        RWrEn   <= (opcode == `OPCODE_BRANCH)
                || (opcode == `OPCODE_STORE);
    end

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

   // EU instantiation for R-type and I-type operations
   ExecutionUnit eu(
      .result(euResult),  // Output of the EU goes to the register file or data memory
      .opA(Rdata1),       // Operand A comes from the register file (rs1)
      .opB(Rdata2),       // Operand B is immediate for I-type and load and save instructions, or rs2 for R-type
      .func(funct3),
      .aux_func(funct7),  // Auxiliary function field from the instruction (not used for I-type)
      .opcode(opcode),    // Opcode to determine the operation
      .MemSize(MemSize),

      .imm(ext_imm),
      .oldPC(PC),
      .newPC(NPC),
      .memdata(StoreData)
   );


   // Extend module instantiation for I-type immediate extension
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

   Extender data_extender(
      .data_in(DataWord),        // Data read from memory
      .ext_type({1'b1, funct3}), // Type of extension for the data (sign, zero, etc.)
      .data_out(ext_data)        // Extended data output for register file
   );






   // Control unit (not shown) would set 'euSrc' based on the instruction type
   // For example, if the opcode indicates an I-type instruction, 'euSrc' would be set to 1



   // Fetch Address Datapath
   // assign PC_Plus_4 = PC + 4;
   // assign NPC = PC_Plus_4;

endmodule // SingleCycleCPU


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
    output reg [1:0] MemSize  // Memory Size signal
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
            newPC = oldPC + 4;

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
            newPC = oldPC + 4;

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
                `FUNC_BEQ:  newPC = (opA == opB) ? oldPC + imm : oldPC + 4;
                `FUNC_BNE:  newPC = (opA != opB) ? oldPC + imm : oldPC + 4;
                `FUNC_BLT:  newPC = (opA >= opB) ? oldPC + imm : oldPC + 4;
                `FUNC_BGE:  newPC = (opA  < opB) ? oldPC + imm : oldPC + 4;
                `FUNC_BLTU: newPC = ($signed(opA) >= $signed(opB)) ? oldPC + imm : oldPC + 4;
                `FUNC_BGEU: newPC = ($signed(opA)  < $signed(opB)) ? oldPC + imm : oldPC + 4;
                default:    newPC = 32'hX;
            endcase
        end

        `OPCODE_JUMP:      begin
            result = oldPC + 4;
            newPC  = oldPC + imm;
        end

        `OPCODE_JUMP_REG:  begin
            result = oldPC + 4;
            newPC  = opA   + imm;
        end

        `OPCODE_LOAD_UPPR: begin
            result = imm;
            newPC  = oldPC + 4;
        end

        `OPCODE_ADD_UPPR:  begin
            result = oldPC + imm;
            newPC  = oldPC + 4;
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
