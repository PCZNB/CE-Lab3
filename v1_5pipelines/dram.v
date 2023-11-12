`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/30 14:54:23
// Design Name: 
// Module Name: dram
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
module ram(

    input wire clk,
    input wire rst,
    input wire ram_req_i,
    input wire ram_we_i,                   // write enable
    input wire[1:0] ram_state_i,
    input wire[`MemAddrBus] ram_addr_i,    // addr
    input wire[`MemBus] ram_wdata_i,

    output reg[`MemBus] ram_r_data_o         // read data

    );

    reg[`MemBus] _ram[0:`MemNum - 1];

wire [1:0] addr_SB_offset= ram_addr_i[1:0];
wire [1:0] addr_SH_offset= ram_addr_i[1];
wire [31:0] base_index = ram_addr_i >> 2;

    always @ (posedge clk) begin
        if(ram_req_i && ram_we_i)
        begin
            if(ram_state_i == 2'b00) 
            begin
                if(addr_SB_offset==2'b00)
                begin
                    _ram[base_index][7:0] = ram_wdata_i[7:0];
                end
                else if(addr_SB_offset==2'b01)
                begin
                     _ram[base_index][15:8] = ram_wdata_i[7:0];
                end
                else if(addr_SB_offset==2'b10)
                begin
                     _ram[base_index][23:16] = ram_wdata_i[7:0];
                end
                else if(addr_SB_offset==2'b11)
                begin
                     _ram[base_index][31:17] = ram_wdata_i[7:0];
                end
            end
            else if(ram_state_i == 2'b01)
            begin
                if(addr_SH_offset==0)
                begin
                    _ram[base_index][15:0] = ram_wdata_i[15:0];
                end
                else if(addr_SH_offset==1)
                begin
                     _ram[base_index][31:16] =ram_wdata_i[15:0];
                end
            end
            else if(ram_state_i == 2'b10)
            begin
                _ram[base_index] <= ram_wdata_i;
            end
            else if(ram_state_i == 2'b11)
               _ram[base_index] <=_ram[base_index];
        end    
    end

    always @ (*) begin
        if (rst == `RstEnable || ~(ram_req_i)) begin
            ram_r_data_o = `ZeroWord;
        end else if (ram_we_i == `False)  begin
            ram_r_data_o = _ram[base_index];
        end
        else ram_r_data_o = `ZeroWord;
    end

endmodule
