`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/10 22:27:50
// Design Name: 
// Module Name: dmemory32
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


module dmemory32(clock,memWrite,address,writeData,readData );

    input clock, memWrite;  //memWrite 来自controller，为1'b1时表示要对data-memory做写操作

    input [31:0] address;   //address 以字节为单位

    input [31:0] writeData; //writeData ：向data-memory中写入的数据

    output[31:0] readData;  //writeData ：从data-memory中读出的数据

    wire clk;
    
    RAM ram(
        .clka(clk),
        .wea(memWrite),
        .addra(address[15:2]),
        .dina(writeData),
        .douta(readData)
    );
    assign clk=!clock;
endmodule
