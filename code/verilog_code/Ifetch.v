`timescale 1ns / 1ps

module Ifetc32(Instruction,branch_base_addr,Addr_result,Read_data_1,Branch,nBranch,Jmp,Jal,Jr,Zero,clock,reset,link_addr,PC_plus_4,PC);
    input[31:0] Instruction;           // 根据PC的值从存放指令的prgrom中取出的指令
    output[31:0] branch_base_addr;      // 对于有条件跳转类的指令而言，该值为(pc+4)送往ALU
    input[31:0]  Addr_result;            // 来自ALU,为ALU计算出的跳转地址
    input[31:0]  Read_data_1;           // 来自Decoder，jr指令用的地址
    input        Branch;                // 来自控制单元
    input        nBranch;               // 来自控制单元
    input        Jmp;                   // 来自控制单元
    input        Jal;                   // 来自控制单元
    input        Jr;                    // 来自控制单元
    input        Zero;                  //来自ALU，Zero为1表示两个值相等，反之表示不相等
    input        clock,reset;           //时钟与复位,复位信号用于给PC赋初始值，复位信号高电平有效
    output reg [31:0] link_addr = 0;        // JAL指令专用的PC+4
    output [31:0] PC_plus_4;             // PC + 4;
    output reg [31:0] PC = 32'b0;
    
    reg [31:0] Next_PC = 32'b0;
    assign PC_plus_4 = PC + 4;
    wire [25:0]address = Instruction[25:0];
    assign branch_base_addr = PC + 4;
    always @* begin
        if(((Branch == 1) && (Zero == 1 )) || ((nBranch == 1) && (Zero == 0))) // beq, bne
            Next_PC = Addr_result;
        else if(Jr == 1)
            Next_PC = Read_data_1; // the value of $31 register
        else 
            Next_PC = PC_plus_4; // PC+4
    end

    always @(negedge clock or posedge reset) begin
        if(reset == 1)
            PC <= 32'b0;
        else if((Jmp == 1) || (Jal == 1)) 
            PC <= {PC[31:28], address, 2'b00};//
        else
            PC <= Next_PC;
    end

    always @(negedge clock or posedge reset) begin
        if(reset) link_addr <= 0;
        else if((Jal == 1)) 
            link_addr <= PC_plus_4;
    end



endmodule