`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/12/2025 08:42:17 AM
// Design Name: 
// Module Name: spi_top_tb
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


module spi_top_tb(
    );

    reg clk, reset;
    reg [7:0] din;
    reg [15:0] dvsr;
    reg cpol, cpha;
    reg start;
    reg slave_sel;
    wire [7:0] ram1_written_data, ram2_written_data;
    wire [7:0] ram1_written_addr , ram2_written_addr;
    wire [7:0] ram1_read_addr, ram2_read_addr;
    wire [7:0] master_received_data;
    wire spi_done;
    spi_top #(.dbits(8)) uut (
        .clk(clk),
        .reset(reset),
        .din(din),
        .dvsr(dvsr),
        .cpol(cpol),
        .cpha(cpha),
        .start(start),
        .slave_sel(slave_sel),
        .master_received_data(master_received_data),
        .written_data_1(ram1_written_data),
        .written_addr_1(ram1_written_addr),
        .read_addr_1(ram1_read_addr),
        
        .written_data_2(ram2_written_data),
        .written_addr_2(ram2_written_addr),
        .read_addr_2(ram2_read_addr),
        .spi_done(spi_done)
    );
    
    localparam t=10;
    always begin
        clk=1'b0;
        #(t/2);
        clk =1'b1;
        #(t/2);
    end
    
    initial begin
        reset =1'b0;
        dvsr =49 ;
        
        //mode 0 write in second ram
        din = 8'b00000000;
        cpol =0;
        cpha=0;
        slave_sel =0 ;
        #1 reset= 1'b1;
        repeat(4) @(negedge clk);
        start = 1;
        #10 start =0;
        #8000;
        start = 1;
        #10 start =0;
        #8000;
        din = 8'b00000011;
        start =1;
        #10 start =0;
        #8000;
        
        din = 8'h3F;
        start =1;
        #10 start=0 ;
        #8000;

        
        //mode 0 read from first ram
        #1000 
        slave_sel = 1'b0;
        din = 8'b00000001;
        start = 1;
        #10 start =0;
        #8000;
        start = 1;
        #10 start =0;
        #8000;
        din = 8'b00000011;
        start =1;
        #10 start=0;
        #8000;
        start =1;
        #10 start=0;
        #8000;
        #8000;
        
        
        
        
        //mode 1 write in second ram
        slave_sel =1 ;
        cpol =0;
        cpha=1;
        din = 8'b00000000;
        start = 1;
        #10 start =0;
        #9000;
        start = 1;
        #10 start =0;
        #9000;
        din = 8'b00000100;
        start =1;
        #10 start =0;
        #9000;
        din = 8'hAB;
        start =1;
        #10 start=0 ;
        #9000;

        
        //mode 1 read from second ram
        slave_sel = 1;
        din = 8'b00000001;
        start = 1;
        #10 start =0;
        #9000;
        start = 1;
        #10 start =0;
        #9000;
        din = 8'b00000100;
        start =1;
        #10 start=0;
        #9000;
        start =1;
        #10 start=0;
        #9000;
        #9000;
        
        
        
        
        // mode 2 write in first ram

        slave_sel =0 ;
        cpol =1;
        cpha=0;
        din = 8'b00000000;
        start = 1;
        #10 start =0;
        #8000;
        start = 1;
        #10 start =0;
        #8000;
        din = 8'b00001010;
        start =1;
        #10 start =0;
        #8000;
        din = 8'hCD;
        start =1;
        #10 start=0 ;
        #8000;
        
        //mode 2 read from first ram

        slave_sel = 1'b0;
        din = 8'b00000001;
        start = 1;
        #10 start =0;
        #8000;
        start = 1;
        #10 start =0;
        #8000;
        din = 8'b00001010;
        start =1;
        #10 start=0;
        #8000;
        start =1;
        #10 start=0;
        #8000;
        #8000;
        
        
        // mode 3 write in second ram
        
        slave_sel =1 ;
        cpol =1;
        cpha=1;
        din = 8'b00000000;
        start = 1;
        #10 start =0;
        #9000;
        start = 1;
        #10 start =0;
        #9000;
        din = 8'b00001101;
        start =1;
        #10 start =0;
        #9000;
        din = 8'h8F;
        start =1;
        #10 start=0 ;
        #9000;
        
        //mode 3 read from second ram

        
        slave_sel = 1;
        din = 8'b00000001;
        start = 1;
        #10 start =0;
        #9000;
        start = 1;
        #10 start =0;
        #9000;
        din = 8'b00001101;
        start =1;
        #10 start=0;
        #9000;
        start =1;
        #10 start=0;
        #9000;
        #9000;
        $stop;
    end
    
endmodule
