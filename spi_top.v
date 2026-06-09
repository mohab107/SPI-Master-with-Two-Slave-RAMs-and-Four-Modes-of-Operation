`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/12/2025 08:19:19 AM
// Design Name: 
// Module Name: spi_top
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


module spi_top #(parameter dbits=8)(
        input clk,reset,
        input [dbits-1:0] din,
        input [15:0] dvsr,
        input cpol, cpha,
        input start,
        input slave_sel,
        output [dbits-1:0] master_received_data,
        output spi_done,
        output [dbits-1:0] written_data_1 , written_data_2,
        output [dbits-1:0] read_addr_1,read_addr_2,
        output sclk,
        output [dbits-1:0] written_addr_1,written_addr_2
    );
    wire miso_1 , miso_2;
    wire cs0, cs1;
    wire ready;
    wire mosi;
    wire done_flag_wire , done_ack_wire_1 , done_ack_wire_2;
    spi_master #(.dbits(dbits)) master (
        .clk(clk),
        .reset(reset),
        .din(din),
        .dvsr(dvsr),
        .cpol(cpol),
        .cpha(cpha),
        .start(start),
        .slave_sel(slave_sel),
        .miso(cs0? miso_2 : miso_1),
        .dout(master_received_data),
        .cs0(cs0),
        .cs1(cs1),
        .sclk(sclk),
        .spi_done(spi_done),
        .ready(ready),
        .done_flag(done_flag_wire),
        .done_ack(cs0? done_ack_wire_2 : done_ack_wire_1 ),
        .mosi(mosi)
    );
    spi_ram_slave #(.dbits(dbits), .addr_width(dbits)) first_ram_slave (
        .sclk(sclk),
        .reset(reset),
        .mosi(mosi),
        .spi_done_tick(spi_done),
        .slave_sel(cs0),
        .cpol(cpol),
        .cpha(cpha),
        .miso(miso_1),
        .done_flag(done_flag_wire),
        .done_ack(done_ack_wire_1),
        .written_data(written_data_1),
        .read_addr(read_addr_1),
        .ready(ready),
        .written_addr(written_addr_1)
    );
    spi_ram_slave #(.dbits(dbits), .addr_width(dbits)) second_ram_slave (
        .sclk(sclk),
        .reset(reset),
        .mosi(mosi),
        .spi_done_tick(spi_done),
        .slave_sel(cs1),
        .cpol(cpol),
        .cpha(cpha),
        .miso(miso_2),
        .done_flag(done_flag_wire),
        .done_ack(done_ack_wire_2),
        .written_data(written_data_2),
        .read_addr(read_addr_2),
        .ready(ready),
        .written_addr(written_addr_2)
    );
endmodule
