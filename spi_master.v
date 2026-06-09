`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/07/2025 01:18:07 AM
// Design Name: 
// Module Name: spi_master
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


module spi_master #(parameter dbits =8)(
        input clk,reset,
        input [dbits-1:0] din,
        input [15:0] dvsr,
        input cpol, cpha,
        input start,
        input slave_sel,
        input miso,
        input done_ack,
        output [dbits-1:0] dout,
        output reg cs0,cs1,
        output sclk,
        output spi_done,ready,
        output  reg done_flag, 
        output mosi
    );
    localparam idle=0 , cpha_delay =1 , p0=2, p1=3;
    reg [15:0] timer_count_reg ,timer_count_next  ;
    reg [$clog2(dbits)-1:0]sent_bits_reg , sent_bits_next;
    reg [1:0] state_reg , state_next;
    reg [dbits-1:0] si_reg, si_next;
    reg [dbits-1:0] so_reg, so_next;
    reg spi_clk_reg, ready_i, spi_done_i;
    wire p_clk;
    wire spi_clk_next;

    always @(posedge clk ,negedge reset) begin
        if(~reset) begin
            state_reg <= idle;
            timer_count_reg <=0;
            sent_bits_reg <=0;
            si_reg <=0;
            so_reg <=0 ;
            spi_clk_reg <=0 ;
        end
        else begin
            state_reg <= state_next;
            timer_count_reg <= timer_count_next;
            sent_bits_reg <= sent_bits_next;
            si_reg <=si_next;
            so_reg <=so_next ;
            spi_clk_reg <= spi_clk_next;
        end
    end
    always @(*) begin
        state_next = state_reg;
        timer_count_next =timer_count_reg;
        sent_bits_next =sent_bits_reg;
        so_next = so_reg;
        si_next = si_reg ;
        ready_i =0;
        spi_done_i =0;
        cs0 = slave_sel;
        cs1= ~slave_sel ;
        done_flag =0;
        case(state_reg)
            idle: begin
                    ready_i = 1'b1;
                    if (start) begin
                        timer_count_next =0;
                        sent_bits_next =0;
                        so_next = din;
                        if(cpha) 
                            state_next = cpha_delay;
                        else
                            state_next = p0;
                    end
                  end
            cpha_delay: begin
                                if (timer_count_reg == dvsr) begin
                                    state_next = p0;
                                    timer_count_next = 0;
                                end
                                else
                                    timer_count_next = timer_count_reg+1;

                        end
            p0: begin

                        if(timer_count_reg == dvsr) begin
                            timer_count_next =0;
                            if(sent_bits_reg < dbits)
                                si_next = {si_reg[dbits-2:0] , miso};
                            state_next = p1;
                        end
                        else
                            timer_count_next =timer_count_reg+1;

                end
                
            p1: begin
                       if(timer_count_reg == dvsr) begin                          
                            if(sent_bits_reg == dbits-1) begin
                                  if(done_ack ) begin
                                      spi_done_i = 1'b1;
                                      state_next = idle;
                                      done_flag =1'b1;
                                      timer_count_next =0;
                                      //cs0 = 1;
                                     // cs1= 1 ;
                                  end
                                  else begin
                                      state_next = p0;
                                      timer_count_next =0;
                                  end
                             end
                            else begin
                                sent_bits_next =sent_bits_reg+1;
                                timer_count_next =0;
                                so_next ={so_reg[dbits-2:0] , 1'b0};
                                state_next = p0;
                            end
                        end
                        else
                            timer_count_next =timer_count_reg+1;

                end
        endcase
    end
    
    assign dout = si_reg;
    assign spi_done = spi_done_i;
    assign ready = ready_i;
    assign mosi = so_reg [dbits-1];
    assign sclk = spi_clk_reg;
    assign p_clk = (state_next== p1 && ~cpha) || (state_next==p0 && cpha);
    assign spi_clk_next = (cpol)? ~p_clk : p_clk;

endmodule
