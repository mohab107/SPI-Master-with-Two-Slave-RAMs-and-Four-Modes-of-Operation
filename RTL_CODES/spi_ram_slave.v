`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/12/2025 05:22:46 AM
// Design Name: 
// Module Name: spi_ram_slave
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


module spi_ram_slave #(parameter dbits = 8 , addr_width=8)(
        input sclk,reset,
        input mosi,
        input spi_done_tick,
        input slave_sel,
        input cpol,cpha,
        input done_flag,
        input ready,
        output [dbits-1:0] written_data,
        output [dbits-1:0] written_addr,
        output [dbits-1:0] read_addr,
        output reg miso,
        output reg done_ack
        
    );
    
    localparam idle=0 , chck_cmd =1 , get_rd_addr=2, return_data=3 , get_wr_addr=4, get_wr_data=5;
    reg [2:0] state_reg,state_reg_pos ,state_reg_neg , state_next;
    reg [dbits-1:0] addr_read_reg, addr_read_reg_pos, addr_read_reg_neg, addr_read_next;
    reg [dbits-1:0] data_read_reg, data_read_reg_pos,data_read_reg_neg, data_read_next;
    reg [dbits-1:0] addr_write_reg, addr_write_reg_pos,addr_write_reg_neg, addr_write_next;
    reg [dbits-1:0] data_write_reg, data_write_reg_pos,data_write_reg_neg, data_write_next;
    reg [dbits-1:0] cmd_reg, cmd_reg_pos ,cmd_reg_neg , cmd_next;
    reg we;
    reg [$clog2(dbits):0] sent_bits_reg, sent_bits_reg_pos ,sent_bits_reg_neg, sent_bits_next;
    reg [dbits-1:0] mem [0:2**addr_width -1];
    


    always@(posedge sclk) begin
        if(we)
            mem[addr_write_reg] <= data_write_reg;
    end
    
    always @(posedge sclk ,negedge reset) begin
        if(~reset) begin
            state_reg_pos <= idle;
            addr_read_reg_pos <= 0;
            addr_write_reg_pos <=0;
            data_read_reg_pos <= 0;
            data_write_reg_pos <= 0;
            cmd_reg_pos <= 0;
            sent_bits_reg_pos <= 0;
        end
        
        else begin
            state_reg_pos <= state_next;
            addr_read_reg_pos <= addr_read_next;
            addr_write_reg_pos <= addr_write_next;
            data_read_reg_pos <= data_read_next;
            data_write_reg_pos <= data_write_next;
            cmd_reg_pos <= cmd_next;
            sent_bits_reg_pos <= sent_bits_next;
        end
    end
    always @(negedge sclk ,negedge reset) begin
        if(~reset) begin
            state_reg_neg <= idle;
            addr_read_reg_neg <= 0;
            addr_write_reg_neg <=0;
            data_read_reg_neg <= 0;
            data_write_reg_neg <= 0;
            cmd_reg_neg <= 0;
            sent_bits_reg_neg <= 0;
        end
        
        else begin
            state_reg_neg <= state_next;
            addr_read_reg_neg <= addr_read_next;
            addr_write_reg_neg <= addr_write_next;
            data_read_reg_neg <= data_read_next;
            data_write_reg_neg <= data_write_next;
            cmd_reg_neg <= cmd_next;
            sent_bits_reg_neg <= sent_bits_next;
        end
    end

    
    always @(*) begin
        addr_read_next = addr_read_reg;
        addr_write_next = addr_write_reg;
        data_read_next = data_read_reg;
        data_write_next = data_write_reg;
        cmd_next = cmd_reg;
        miso = 0 ;
        we =0;
        if(state_next == idle)
            sent_bits_next = 0;
        else
            sent_bits_next = sent_bits_reg;
        done_ack = 1'b0;
        state_next = state_reg ;
        
        if(cpol == cpha) begin
            state_reg = state_reg_pos;
            addr_read_reg = addr_read_reg_pos;
            addr_write_reg = addr_write_reg_pos;
            data_read_reg = data_read_reg_pos;
            data_write_reg = data_write_reg_pos;
            cmd_reg = cmd_reg_pos;
            sent_bits_reg = sent_bits_reg_pos;
        end
        else begin
            state_reg = state_reg_neg;
            addr_read_reg = addr_read_reg_neg;
            addr_write_reg = addr_write_reg_neg;
            data_read_reg = data_read_reg_neg;
            data_write_reg = data_write_reg_neg ;
            cmd_reg = cmd_reg_neg;
            sent_bits_reg = sent_bits_reg_neg;
        end
        case(state_reg) 
            idle: begin 
                    if(~slave_sel & sent_bits_reg == dbits-1) begin
                        state_next = chck_cmd;
                        sent_bits_next = 0;
                        done_ack =1'b1;
                        cmd_next = {cmd_reg[dbits-2:0] , mosi};
                    end
                    else if(slave_sel) begin
                        state_next = idle;
                    end
                    else begin
                        state_next = idle;
                        sent_bits_next = sent_bits_reg +1;
                    end
                  end
                  
                  
            chck_cmd: begin
                        
                        if(~slave_sel & sent_bits_reg == dbits-1) begin
                            done_ack=1'b1;
                            if(cmd_reg ==0) begin
                                state_next = get_wr_addr; 
                                addr_write_next = {addr_write_reg[dbits-2:0] , mosi};
                                sent_bits_next = 0;
                            end
                            else if(cmd_reg ==1) begin
                                state_next = get_rd_addr;
                                addr_read_next = {addr_read_reg[dbits-2:0] , mosi};
                                sent_bits_next = 0;
                            end
                            else begin
                                state_next =idle;  
                            end
                        end
                        else if(slave_sel) begin
                            state_next = idle; 
                        end
                        else begin
                            state_next = chck_cmd;
                            sent_bits_next = sent_bits_reg +1;
                            cmd_next = {cmd_reg[dbits-2:0] , mosi};
                        end
                      end
                      
            get_rd_addr: begin
                            if(~slave_sel & sent_bits_reg == dbits-1) begin
                                done_ack=1'b1;
                                state_next = return_data;
                                sent_bits_next = 0;
                                data_read_next = mem[addr_read_reg]; 
                            end
                            else if(slave_sel) begin
                                state_next = idle;
                            end
                            else begin
                                state_next = get_rd_addr;
                                sent_bits_next = sent_bits_reg +1;
                                addr_read_next = {addr_read_reg[dbits-2:0] , mosi};
                            end
                         end
                         
            return_data: begin 
                            miso = data_read_reg[7];          
                            if(~slave_sel & sent_bits_reg == dbits) begin
                                done_ack=1'b1;
                                state_next = idle;
                                sent_bits_next = 0;
                            end
                            else if(slave_sel) begin
                                state_next = idle;
                            end
                            else begin
                                state_next = return_data;
                               sent_bits_next = sent_bits_reg +1;  
                               data_read_next = {data_read_reg[dbits-2:0] ,1'b0};
                               
                            end
                         end
                         
            get_wr_addr: begin                          
                            if(~slave_sel & sent_bits_reg == dbits-1) begin
                                done_ack=1'b1;
                                state_next = get_wr_data;
                                sent_bits_next = 0;
                                data_write_next = {data_write_reg[dbits-2:0] , mosi};
                            end
                            else if(slave_sel) begin
                                state_next = idle;
                            end
                            else begin
                                state_next = get_wr_addr;
                                sent_bits_next = sent_bits_reg +1;  
                                addr_write_next = {addr_write_reg[dbits-2:0] , mosi}; 
                            end    
                         end
                         
            get_wr_data: begin
                            if(~slave_sel & sent_bits_reg == dbits-1) begin
                                done_ack=1'b1;
                                we = 1'b1; 
                                state_next = idle;
                                sent_bits_next = 0;
                            end
                            else if(slave_sel) begin
                                state_next = idle;
                            end
                            else begin
                                state_next = get_wr_data;
                                sent_bits_next = sent_bits_reg +1; 
                                data_write_next = {data_write_reg[dbits-2:0] , mosi};
                            end
                         end
                         
        endcase
    end
    assign written_data = mem[addr_write_reg];
    assign written_addr = addr_write_reg;
    assign read_addr = addr_read_reg;

    
endmodule
