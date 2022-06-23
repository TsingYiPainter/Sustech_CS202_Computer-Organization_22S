`timescale 1ns / 1ps

module control32(Opcode, Function_opcode, Jr, RegDST, ALUSrc, MemorIOtoReg, RegWrite, MemWrite, Branch, nBranch, Jmp, Jal, I_format, Sftmd, ALUOp, Alu_resultHigh, MemRead, IORead, IOWrite);
    input[5:0]   Opcode;            // 来自IFetch模块的指令高6bit, instruction[31..26]
    input[5:0]   Function_opcode;  	// 来自IFetch模块的指令低6bit, 用于区分r-类型中的指令, instructions[5..0]
    output       Jr;         	 // 为1表明当前指令是jr, 为0表示当前指令不是jr
    output       RegDST;          // 为1表明目的寄存器是rd, 否则目的寄存器是rt
    output       ALUSrc;          // 为1表明第二个操作数（ALU中的Binput）是立即数（beq, bne除外）, 为0时表示第二个操作数来自寄存器
    output       MemorIOtoReg;     // 为1表明需要从存储器或I/O读数据到寄存器
    output       RegWrite;   	  // 为1表明该指令需要写寄存器
    output       MemWrite;       // 为1表明该指令需要写存储器
    output       Branch;        // 为1表明是beq指令, 为0时表示不是beq指令
    output       nBranch;       // 为1表明是Bne指令, 为0时表示不是bne指令
    output       Jmp;            // 为1表明是J指令, 为0时表示不是J指令
    output       Jal;            // 为1表明是Jal指令, 为0时表示不是Jal指令
    output       I_format;      // 为1表明该指令是除beq, bne, LW, SW之外的其他I-类型指令
    output       Sftmd;         // 为1表明是移位指令, 为0表明不是移位指令
    output[1:0]  ALUOp;        // 是R-类型或I_format=1时位1（高bit位）为1,  beq、bne指令则位0（低bit位）为1
    //new port for IO
    input[21:0] Alu_resultHigh; // From the execution unit Alu_Result[31..10]
    output MemRead;             // 1 indicates that the instruction needs to read from the memory
    output IORead;              // 1 indicates I/O read 
    output IOWrite;             // 1 indicates I/O write


    wire sw, lw;
    assign sw = (Opcode == 6'b101011)? 1 : 0;
    assign lw = (Opcode == 6'b100011)? 1 : 0;


    //new port for IO
    assign MemWrite = ((sw == 1) && (Alu_resultHigh[21:0] != 22'h3FFFFF)) ? 1 : 0; 
    assign MemRead =((lw == 1) && (Alu_resultHigh[21:0] != 22'h3FFFFF)) ? 1 : 0; // Read memory
    assign IORead = ((lw == 1) && (Alu_resultHigh[21:0] == 22'h3FFFFF)) ? 1 : 0; // Read input port
    assign IOWrite = ((sw == 1) && (Alu_resultHigh[21:0] == 22'h3FFFFF)) ? 1 : 0; // Write output port
    assign MemorIOtoReg = IORead || MemRead; // Read operations require reading data from memory or I/O to write to the register 


    assign I_format = (Opcode[5:3] == 3'b001)? 1 : 0;
    // Jr
    assign Jr = (Opcode == 6'b0 && Function_opcode == 6'b001000)? 1 : 0; 
    //R-type
    assign RegDST = (Opcode == 6'b0)? 1 : 0; 
    //sll srl sra
    assign ALUSrc = (Opcode == 6'b100011 || Opcode == 6'b101011 || I_format)? 1 : 0;
    //lw/////////////needed update
    //assign MemorIOtoReg = IORead || MemRead;
    //jr sw beq bne j buyao
    assign RegWrite = !(Jr) && (Opcode == 6'b0 || Opcode == 6'b100011 || Opcode == 6'b000011 || I_format)? 1 : 0;
    //sw
    //assign MemWrite = (Opcode == 6'b101011)? 1 : 0;
    //beq
    assign Branch = (Opcode == 6'b000100)? 1 : 0;
    //bne
    assign nBranch = (Opcode == 6'b000101)? 1 : 0;
    //j
    assign Jmp = (Opcode == 6'b000010)? 1 : 0;
    //jal
    assign Jal = (Opcode == 6'b000011)? 1 : 0;
    
    //sll srl sra sllv srlv srav
    assign Sftmd = (Opcode == 6'b0 && (Function_opcode == 6'b0 || Function_opcode == 6'b000010 || Function_opcode == 6'b000011 || Function_opcode == 6'b000100 || Function_opcode == 6'b000110 || Function_opcode == 6'b000111))? 1 : 0;
    
    assign ALUOp = {(Opcode == 6'b0 || I_format),(Branch || nBranch)};
endmodule
