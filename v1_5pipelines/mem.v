`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/26 21:00:30
// Design Name: 
// Module Name: mem
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


module mem(


    input wire rst,
          
    input wire[`MemAddrBus] mem_waddr_i,   
      
    input wire[`RegBus] reg_wdata_i,      
    input wire reg_we_i,                   
    input wire[`RegAddrBus] reg_waddr_i,  
    input wire[`AluOpBus]       aluop_i, 
    
    //from mem
     input wire[`RegBus]     ram_r_data_i,
     output reg              ram_we_o,
     output reg              ram_req_o,
     output reg[`RegBus]     ram_addr_o,
     output reg[`RegBus]     ram_wdata_o,     
    output reg reg_we_o,                 
    output reg[`RegAddrBus] reg_waddr_o,
    output reg[`RegBus] reg_wdata_o, 
    
    //to mem
    output reg[1:0]         ram_state_o
    );
        
   	always @ (*) begin
		if(rst == `RstEnable) begin
			reg_wdata_o <= `ZeroWord;	
			reg_we_o	<=`WriteDisable;
			reg_waddr_o <= `NOPRegAddr;
			
			ram_we_o <=`WriteDisable;
			ram_req_o <= `False;
			 ram_addr_o <= `ZeroWord;
			 ram_wdata_o <= `ZeroWord;
		     ram_state_o <= 2'b11;
		end else begin		
			reg_we_o	<=reg_we_i;
			reg_waddr_o <= reg_waddr_i;
		case(aluop_i)
            `MEM_NOP: begin
               ram_req_o     = `False;
               ram_we_o     = `False;
               ram_wdata_o    = `ZeroWord;
               ram_addr_o      = `ZeroWord;
               reg_wdata_o         = reg_wdata_i;
               ram_state_o <= 2'b11;
            end
            `EX_LB: begin
               ram_req_o     = `True;
               ram_we_o     = `False;
               ram_wdata_o    = `ZeroWord;
               ram_addr_o      = mem_waddr_i;
               ram_state_o <= 2'b11;
                case (mem_waddr_i[1:0])
						2'b00:	begin
							
							reg_wdata_o <= {{24{ram_r_data_i[7]}},ram_r_data_i[7:0]};
						end
						2'b01:	begin
							reg_wdata_o <= {{24{ram_r_data_i[15]}},ram_r_data_i[15:8]};
						end
						2'b10:	begin
							reg_wdata_o <= {{24{ram_r_data_i[23]}},ram_r_data_i[23:16]};
						end
						2'b11:	begin
							reg_wdata_o <= {{24{ram_r_data_i[31]}},ram_r_data_i[31:24]};
						end
						default:	begin
							reg_wdata_o <= `ZeroWord;
						end
					endcase
				end

            `EX_LBU:  begin
               ram_req_o     = `True;
               ram_we_o     = `False;
               ram_wdata_o    = `ZeroWord;
               ram_addr_o      = mem_waddr_i;
               ram_state_o <= 2'b11;
                case (mem_waddr_i[1:0])
						2'b00:	begin
							
							reg_wdata_o <= {{24{1'b0}},ram_r_data_i[7:0]};
						end
						2'b01:	begin
							reg_wdata_o <= {{24{1'b0}},ram_r_data_i[15:8]};
						end
						2'b10:	begin
							reg_wdata_o <= {{24{1'b0}},ram_r_data_i[23:16]};
						end
						2'b11:	begin
							reg_wdata_o <= {{24{1'b0}},ram_r_data_i[31:24]};
						end
						default:	begin
							reg_wdata_o <= `ZeroWord;
						end
					endcase
				end
            `EX_LH: begin
               
               ram_req_o     = `True;
               ram_we_o     = `False;
               ram_wdata_o    = `ZeroWord;
               ram_addr_o      = mem_waddr_i;
               ram_state_o <= 2'b11;
                case (mem_waddr_i[1:0])
						2'b00:	begin
							reg_wdata_o <= {{16{ram_r_data_i[15]}},ram_r_data_i[15:0]};
						end
						2'b10:	begin
							reg_wdata_o <= {{16{ram_r_data_i[31]}},ram_r_data_i[31:16]};
						end
						default:	begin
							reg_wdata_o <= `ZeroWord;
						end
					endcase
				end
            `EX_LHU: begin
                
               ram_req_o     = `True;
               ram_we_o     = `False;
               ram_wdata_o    = `ZeroWord;
               ram_addr_o      = mem_waddr_i;
               ram_state_o <= 2'b11;
                case (mem_waddr_i[1:0])
						2'b00:	begin
							reg_wdata_o <= {{16{1'b0}},ram_r_data_i[15:0]};
						end
						2'b10:	begin
							reg_wdata_o <= {{16{1'b0}},ram_r_data_i[31:16]};
						end
						default:	begin
							reg_wdata_o <= `ZeroWord;
						end
					endcase
				end
            `EX_LW: begin
               ram_req_o     = `True;
               ram_we_o     = `False;
               ram_wdata_o    = reg_wdata_i;
               ram_addr_o      = mem_waddr_i;
               reg_wdata_o =   ram_r_data_i;
               ram_state_o <= 2'b11;
            end
            `EX_SB: begin
               ram_req_o     = `True;
               ram_we_o     = `True;
               ram_wdata_o    = reg_wdata_i;
               ram_addr_o      = mem_waddr_i;
               reg_wdata_o =   `ZeroWord;
               ram_state_o <= 2'b00;
            end

            `EX_SH: begin       
               ram_req_o     = `True;
               ram_we_o     = `True;
               ram_wdata_o    =  reg_wdata_i;
               ram_addr_o      = mem_waddr_i;
               reg_wdata_o =   ram_r_data_i;
               ram_state_o <= 2'b01;
            end

            `EX_SW: begin
               ram_req_o     = `True;
               ram_we_o     = `True;
               ram_wdata_o    = reg_wdata_i;
               ram_addr_o      = mem_waddr_i;
               reg_wdata_o =   `ZeroWord;
               ram_state_o <= 2'b10;
            end
            default: begin
                ram_req_o     = `False;
                ram_we_o     = `False;
                ram_wdata_o    = `ZeroWord;
                ram_addr_o      = `ZeroWord;
                reg_wdata_o         = `ZeroWord;
                ram_state_o       = 2'b11;
            end
        endcase
    end   
    end
    
endmodule

