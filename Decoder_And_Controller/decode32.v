`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/11 16:39:46
// Design Name: 
// Module Name: decode32
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

module decode32(read_data_1,read_data_2,Instruction,mem_data,ALU_result,
                 Jal,RegWrite,MemtoReg,RegDst,Sign_extend,clock,reset,opcplus4);
        output[31:0] read_data_1;               // 输出的第一操作数
        output[31:0] read_data_2;               // 输出的第二操作数
        input[31:0]  Instruction;               // 取指单元来的指令, 当前指令

        input[31:0]  mem_data;   		// 从DATA RAM or I/O port取出的数据   
        // 用了
        input[31:0]  ALU_result;   	        // 从执行单元来的运算的结果, 要写入的值
        // 用了
        input        Jal;                       // 来自控制单元，说明是JAL指令 

        input        RegWrite;                  // 来自控制单元

        input        MemtoReg;                  // 来自控制单元
        // 用了
        input        RegDst;                    
        // 用了
        output[31:0] Sign_extend;               // 扩展后的32位立即数
        input        clock,reset;               // 时钟和复位
        input[31:0]  opcplus4;                  // 来自取指单元，JAL中用


        reg  [4:0] Destination;                 // 要写入的寄存器的编号
        wire [4:0] read_data_1_address;         // 要读的第一个寄存器的编号
        wire [4:0] read_data_2_address;         // 要读的第二个寄存器的编号
        reg  [31:0] regs[0:31];                 // 寄存器组                    
        reg  [31:0] write_Data;                 // 要写入的值
        wire [5:0] Opcode;                      // [31:26]
        wire [15:0]immediate;                   // 立即数
        wire sign_bit;                          // 立即数的符号位

        assign  immediate = Instruction[15:0];
        assign  Opcode = Instruction[31:26];
        assign  read_data_1_address = Instruction[25:21]; 
        assign  read_data_2_address = Instruction[20:16];

        // 先处理拓展
        assign sign_bit = immediate[15];
        assign Sign_extend = (Opcode == 6'b00_1110 || Opcode == 6'b00_1011 || Opcode == 6'b00_1100 || Opcode == 6'b00_1101) 
                        ? {16'b0000_0000_0000_0000,immediate}: { sign_bit,sign_bit,sign_bit,sign_bit,sign_bit,sign_bit,sign_bit,sign_bit,
                        sign_bit,sign_bit,sign_bit,sign_bit,sign_bit,sign_bit,sign_bit,sign_bit, immediate } ;


        // 定义reset为1时，复位
        // 处理读写
        // 先处理读
        assign read_data_1 = regs[read_data_1_address];
        assign read_data_2 = regs[read_data_2_address];
        // 读处理完了


    

        // 再处理写
        
        // 先搞出要存入的数值的值
        always @* begin
                if (Jal == 1'b1) begin
                        // 说明是jal指令
                        write_Data = opcplus4;
                end        
                else begin
                        write_Data = (MemtoReg == 1'b1)? mem_data : ALU_result ;
                end
        end

        // 再搞出要存入的寄存器的地址
        always @* begin
                if (Jal == 1'b1) begin
                        Destination = 5'b1_1111 ;
                end
                else begin
                        Destination = (RegDst == 1'b1) ? Instruction[15:11]: Instruction[20:16];                
                end
        end


        integer i;
        always @(posedge clock, negedge reset) begin
                if (reset == 1'b1) begin
                        for( i=0; i<32; i=i+1 )
                                regs[i] <= 0; 
                end
                // 写入
                else begin
                        if (RegWrite == 1'b1) begin
                                regs[Destination] = write_Data; 
                        end
                end
        end


endmodule

