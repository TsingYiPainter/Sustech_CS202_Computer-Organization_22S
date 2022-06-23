`timescale 1ns / 1ps


module decode32(read_data_1,read_data_2,Instruction,mem_data,ALU_result,
                 Jal,RegWrite,MemtoReg,RegDst,Sign_extend,clock,reset,opcplus4);
    output[31:0] read_data_1;              
    output[31:0] read_data_2;              
    input[31:0]  Instruction;              
    input[31:0]  mem_data;   				
    input[31:0]  ALU_result;   				
    input        Jal;                      
    input        RegWrite;                 
    input        MemtoReg;                 
    input        RegDst;                
    output[31:0] Sign_extend;              
    input		 clock,reset;              
    input[31:0]  opcplus4;                 

  
    reg [31:0] register [31:0];
    integer i;
    initial
    begin
        for(i=0;i<=31;i=i+1) begin
            register[i] <= 32'b0;
        end
    end

    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    assign rs = Instruction[25:21];
    assign rt = Instruction[20:16];
    assign rd = Instruction[15:11];
//读取
    assign read_data_1 = register[rs];
    assign read_data_2 = register[rt];

//立即数扩�?
    wire [5:0] opcode;
    assign opcode = Instruction[31:26];
    wire zero_ex;
    assign zero_ex = (opcode == 6'b001001  || opcode == 6'b001100 || opcode == 6'b001011 || opcode == 6'b001101 || opcode == 6'b001110)? 1 : 0;
    assign Sign_extend = (zero_ex == 1)? {{16{1'b0}},Instruction[15:0]}:{{16{Instruction[15]}},Instruction[15:0]};

//目标寄存�?
    reg [4:0] des_reg;
    always @(*) begin
        if(Jal == 1 && opcode == 6'b000011)
            des_reg = 5'b11111;
        else if(RegDst == 1)
            des_reg = rd;
        else
            des_reg = rt;
    end

//目标�?
    reg [31:0] des_data;
    always @(*) 
    begin
        if(Jal == 1 && opcode == 6'b000011)
            des_data = opcplus4;
        else if(MemtoReg == 0)
            des_data = ALU_result;
        else
            des_data = mem_data;
    end

    integer j;
    always @(posedge clock or posedge reset)
        if (reset) begin
            for(j=0;j<=31;j=j+1) begin
                register[j] <= 32'b0;
            end
        end
        else if (RegWrite == 1 && des_reg != 0) 
                register[des_reg] <= des_data;


endmodule