`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/10 21:05:42
// Design Name: 
// Module Name: ifetc32
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


module Ifetc32(Instruction,branch_base_addr,Addr_result,Read_data_1,Branch,nBranch,Jmp,Jal,Jr,Zero,clock,reset,link_addr);
    output[31:0] Instruction;
    output wire [31:0] branch_base_addr; //(pc+4) to ALU used by branch type instruction
    input[31:0] Addr_result;    //the calculated address from ALU
    input[31:0] Read_data_1;    //the address of instruction used by jr instruction
    input Branch;   //while Branch=1, means current instruction is beq
    input nBranch;  //while nBranch=1, means current instruction is bnq
    input Jmp;  //while Jmp=1, means current  instruction is jump
    input Jal;  //while Jal=1, means current instruction is jal
    input Jr;  //while Jrn=1, means current instruction is jrn
    input Zero; //while Zero=1, means the ALUresult is 0
    input clock,reset;
    output reg [31:0] link_addr;  //(pc+4) to Decoder used by jal

    wire[31:0] PC_plus_4;
    reg[31:0] PC;
    reg[31:0] Next_PC;  // 指向下一条指令，不一定是pc+4

    // width 16384-64kb
    prgrom instmem(
        .clka(clock),
        .addra(PC[15:2]),
        .douta(Instruction)
    );

    assign PC_plus_4[31:2] = PC[31:2]+1'b1; // +4
    assign PC_plus_4[1:0] = PC[2:0];  //实际上后两位一直保持00不需要变化 
    assign branch_base_addr=PC_plus_4[31:0];

    always @* begin
    
    if(Jr==1)begin
        Next_PC=Read_data_1;
    end
    else if(Branch==1&&Zero==1) begin
        Next_PC=Addr_result;
    end
    else if(nBranch==1&&Zero==0) begin
        Next_PC=Addr_result;
    end
    else begin
        Next_PC=branch_base_addr;
    end

    end

    always @(negedge clock) begin
    if(Jmp==1) begin
        PC={4'b0000,Instruction[25:0]<<2};
    end
    else if(Jal==1) begin
        link_addr=branch_base_addr;
        PC={4'b0000,Instruction[25:0]<<2};
    end
    else if(reset==1) begin
        PC=32'h0000_0000;
    end
    else begin
        PC=Next_PC;
    end
    end
endmodule
