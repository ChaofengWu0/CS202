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

    input clock, memWrite;  //memWrite ����controller��Ϊ1'b1ʱ��ʾҪ��data-memory��д����

    input [31:0] address;   //address ���ֽ�Ϊ��λ

    input [31:0] writeData; //writeData ����data-memory��д�������

    output[31:0] readData;  //writeData ����data-memory�ж���������

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
