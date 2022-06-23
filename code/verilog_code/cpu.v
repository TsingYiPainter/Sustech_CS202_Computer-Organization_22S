`timescale 1ns / 1ps

//Use for onBoard
module cpu(clk, rst, IO_ReadData, test_index, boardOrSwCtrl, InputCtrl, IO_LED_Data, 
seg_en, seg_out, row, col, backspace_button, start_pg, rx, tx);

//Use for Simulation

    input  clk,rst;
    input [15:0] IO_ReadData;
    input [2:0] test_index;
    input boardOrSwCtrl;
    input InputCtrl;
    output [16:0] IO_LED_Data;
    output [7:0] seg_en;
    output [7:0] seg_out;
    input [3:0] row;            //keybd input
    output [3:0] col;               //keybd output
    input backspace_button;
    //uart port
    input start_pg;
    input rx;
    output tx;
 
//|||||When not Simulation, Use This To Generate Bitstream!!!|||||
  
    wire[31:0]  PC;
    wire[2:0]   test_index_Debounce;
    wire[31:0]  Instruction;       
    wire[31:0]  Reg_WriteData;           
    wire[31:0]  ALU_result;             
    wire[31:0]  write_data;

    wire rst_new;

//CPU_ClkDiv
    wire upg_clk, cpu_clk;
    cpuclkDiv cclk( .clk_in1(clk), .cpu_clk(cpu_clk), .clk_out2(upg_clk));
// assign cpu_clk = clk;

    wire debounce_clk;
    debounceClkDiv dclk( .clk_100MHz(clk), .clr(rst_new), .clk_190Hz(debounce_clk));

//clkdiv
    wire clk_fast;
    counter getfast(clk, rst_new, clk_fast);///////////////////////////?????????

//backspace debounce
    wire backspace_stable;
    debounce backspacebutton(clk_fast, rst_new, backspace_button, backspace_stable);


//debounce
    wire[15:0] IO_ReadData_Debounce; 

//input data debounce
    debounce sw0(debounce_clk, rst_new, IO_ReadData[0], IO_ReadData_Debounce[0]);
    debounce sw1(debounce_clk, rst_new, IO_ReadData[1], IO_ReadData_Debounce[1]);
    debounce sw2(debounce_clk, rst_new, IO_ReadData[2], IO_ReadData_Debounce[2]);
    debounce sw3(debounce_clk, rst_new, IO_ReadData[3], IO_ReadData_Debounce[3]);
    debounce sw4(debounce_clk, rst_new, IO_ReadData[4], IO_ReadData_Debounce[4]);
    debounce sw5(debounce_clk, rst_new, IO_ReadData[5], IO_ReadData_Debounce[5]);
    debounce sw6(debounce_clk, rst_new, IO_ReadData[6], IO_ReadData_Debounce[6]);
    debounce sw7(debounce_clk, rst_new, IO_ReadData[7], IO_ReadData_Debounce[7]);
    debounce sw8(debounce_clk, rst_new, IO_ReadData[8], IO_ReadData_Debounce[8]);
    debounce sw9(debounce_clk, rst_new, IO_ReadData[9], IO_ReadData_Debounce[9]);
    debounce sw10(debounce_clk, rst_new, IO_ReadData[10], IO_ReadData_Debounce[10]);
    debounce sw11(debounce_clk, rst_new, IO_ReadData[11], IO_ReadData_Debounce[11]);
    debounce sw12(debounce_clk, rst_new, IO_ReadData[12], IO_ReadData_Debounce[12]);
    debounce sw13(debounce_clk, rst_new, IO_ReadData[13], IO_ReadData_Debounce[13]);
    debounce sw14(debounce_clk, rst_new, IO_ReadData[14], IO_ReadData_Debounce[14]);
    debounce sw15(debounce_clk, rst_new, IO_ReadData[15], IO_ReadData_Debounce[15]);

//test index debounce
    debounce ts0(debounce_clk, rst_new, test_index[0], test_index_Debounce[0]);
    debounce ts1(debounce_clk, rst_new, test_index[1], test_index_Debounce[1]);
    debounce ts2(debounce_clk, rst_new, test_index[2], test_index_Debounce[2]);

//ready signal debounce
    wire InputCtrl_Debounce;
    debounce in(debounce_clk, rst_new, InputCtrl, InputCtrl_Debounce);

//////////////////////-------port for uart--------////////////////

// UART Programmer Pinouts 
    wire upg_clk_w; 
    wire upg_wen_w; //Uart write out enable 
    wire upg_done_w; //Uart rx data have done 
//data to which memory unit of program_rom/dmemory32 
    wire [14:0] upg_adr_w; 
//data to program_rom or dmemory32 
    wire [31:0] upg_dat_w;

    wire spg_bufg; 
    BUFG U1(.I(start_pg), .O(spg_bufg)); // de-twitter 
// Generate UART Programmer reset signal 
    reg upg_rst; 
    always @ (posedge clk) begin 
        if (spg_bufg) upg_rst = 0; 
        if (rst) upg_rst = 1; 
    end 
//used for other modules which don't relate to UART wire rst; 
    assign rst_new = rst | !upg_rst;
    uart_bmpg_0 uart(.upg_clk_i(upg_clk), .upg_rst_i(upg_rst), .upg_rx_i(rx), .upg_tx_o(tx),
    .upg_clk_o(upg_clk_w), .upg_wen_o(upg_wen_w), .upg_adr_o(upg_adr_w), .upg_dat_o(upg_dat_w), .upg_done_o(upg_done_w));



    //ifetch
    wire[31:0]  branch_base_addr; 
    wire[31:0]  Addr_result;      
    wire[31:0]  Read_data_1;      
    wire        Branch;           
    wire        nBranch;          
    wire        Jmp;              
    wire        Jal;              
    wire        Jr;               
    wire        Zero;             
    wire [31:0] link_addr;          
    wire [31:0] PC_plus_4;           
    //port of program
    wire[31:0] rom_adr_w;

    Ifetc32 ifetch(.Instruction(Instruction), .branch_base_addr(branch_base_addr), .Addr_result(Addr_result),
                    .Read_data_1(Read_data_1),.Branch(Branch), .nBranch(nBranch), .Jmp(Jmp), .Jal(Jal),
                    .Jr(Jr), .Zero(Zero), .clock(cpu_clk), .reset(rst_new), .link_addr(link_addr), 
                    .PC_plus_4(PC_plus_4), .PC(rom_adr_w));
    
    

    programrom program(.rom_clk_i(cpu_clk),.rom_adr_i(rom_adr_w[15:2]),.Instruction_o(Instruction),
    .upg_rst_i(upg_rst),.upg_clk_i(upg_clk_w),.upg_wen_i(upg_wen_w&!upg_adr_w[14]),
    .upg_adr_i(upg_adr_w[13:0]),.upg_dat_i(upg_dat_w),.upg_done_i(upg_done_w));



    wire[5:0]   Opcode;             
    assign Opcode = Instruction[31:26];
    wire[5:0]   Function_opcode;  
    assign Function_opcode = Instruction[5:0];
    wire       RegDST;            
    wire       ALUSrc;           
    wire       MemorIOtoReg;      
    wire       RegWrite;   	      
    wire       MemWrite;          
    wire       I_format;          
    wire       Sftmd;             
    wire[1:0]  ALUOp;             
    wire[21:0] Alu_resultHigh;      // From the execution unit Alu_Result[31..10]
    wire MemRead;                   //out // 1 indicates that the instruction needs to read from the memory
    wire IORead;                    //out // 1 indicates I/O read output IOWrite; // 1 indicates I/O write
    wire IOWrite;                   //out // 1 indicates I/O write
    control32 controller(.Opcode(Opcode), .Function_opcode(Function_opcode), .Jr(Jr), .RegDST(RegDST),
                         .ALUSrc(ALUSrc), .MemorIOtoReg(MemorIOtoReg), .RegWrite(RegWrite), .MemWrite(MemWrite),
                         .Branch(Branch), .nBranch(nBranch), .Jmp(Jmp), .Jal(Jal), .I_format(I_format),
                         .Sftmd(Sftmd), .ALUOp(ALUOp), .Alu_resultHigh(Alu_resultHigh), .MemRead(MemRead), .IORead(IORead), .IOWrite(IOWrite));




    wire[31:0] Read_data_2;                 //out 
    assign Alu_resultHigh = ALU_result[31:10];
    wire[31:0] Sign_extend;                 //out 
    
    
    decode32 decoder(.read_data_1(Read_data_1), .read_data_2(Read_data_2), .Instruction(Instruction),
                     .mem_data(Reg_WriteData), .ALU_result(ALU_result), .Jal(Jal), .RegWrite(RegWrite),
                     .MemtoReg(MemorIOtoReg), .RegDst(RegDST), .Sign_extend(Sign_extend), .clock(cpu_clk),
                     .reset(rst_new), .opcplus4(link_addr));



    wire[4:0]   Shamt;              
    assign Shamt = Instruction[10:6];
    executs32 ALU(.Read_data_1(Read_data_1), .Read_data_2(Read_data_2), .Sign_extend(Sign_extend),
                 .Function_opcode(Function_opcode), .Exe_opcode(Opcode), .ALUOp(ALUOp),
                 .Shamt(Shamt), .ALUSrc(ALUSrc), .I_format(I_format), .Zero(Zero), .Jr(Jr), .Sftmd(Sftmd),
                 .ALU_Result(ALU_result), .Addr_Result(Addr_result), .PC_plus_4(PC_plus_4));
    
    

    //Memory Or IO
    wire [31:0] addr_out;                    //out address to Data-Memory 
    wire [31:0] mem_data;                     // data read from Data-Memory
    wire [15:0] IO_ReadData;                 // data read from IO,16 bits 
    wire LEDCtrl;                            //out // LED Chip Select 
    wire LEDELCtrl;
    wire SwitchCtrl;                         //out // Switch Chip Select


    wire ram_wen_w;//链接controller
    assign ram_wen_w = MemWrite;
    wire[13:0] ram_adr_w;//链接ALU的alu_result
    assign ram_adr_w = addr_out[15:2];
    wire[31:0] ram_dat_i_w;//链接decoder的read_data_2
    assign ram_dat_i_w = Read_data_2;
    wire[31:0] ram_dat_o_w;//
    assign ram_dat_o_w = mem_data;

    dmemory32 mem(.ram_clk_i(cpu_clk),.ram_wen_i(ram_wen_w),.ram_adr_i(ram_adr_w),
    .ram_dat_i(ram_dat_i_w),.ram_dat_o(ram_dat_o_w),.upg_rst_i(upg_rst),.upg_clk_i(upg_clk_w),
    .upg_wen_i(upg_wen_w&upg_adr_w[14]),.upg_adr_i(upg_adr_w[13:0]),.upg_dat_i(upg_dat_w),.upg_done_i(upg_done_w));


//keyboard
    wire [3:0] value;
    wire key_flag;
    key_board board(.clk(clk), .rst(rst_new), .row(row), .col(col), .keyboard_val(value), .key_pressed_flag(key_flag));

    wire [63:0] seg_in;

    register regist(.clk(clk), .flag(key_flag), .backspace_button(backspace_stable), 
                    .rst(rst_new), .key(value), .seg_out(seg_in));

    wire [31:0]seg_trans;
    segTrans segtrans(.seg_in(seg_in), .seg_trans(seg_trans));

    wire [15:0] fin_InputIO;
    assign fin_InputIO = (boardOrSwCtrl == 1)? seg_trans[15:0] : IO_ReadData_Debounce;

    MemOrIO MemorIO(.MemRead(MemRead), .MemWrite(MemWrite), .IORead(IORead), .IOWrite(IOWrite),
                     .addr_in(ALU_result), .addr_out(addr_out), .M_ReadData(mem_data), .IO_ReadData(fin_InputIO),
                     .test_index(test_index_Debounce), .InputCtrl(InputCtrl_Debounce), .Reg_WriteData(Reg_WriteData), .Reg_ReadData(Read_data_2), 
                     .write_data(write_data), .LEDCtrl(LEDCtrl), .LEDELCtrl(LEDELCtrl), .SwitchCtrl(SwitchCtrl));

//handle LED

    handleLED hled( .IO_LED_Data(IO_LED_Data),.LEDCtrl(LEDCtrl), .LEDELCtrl(LEDELCtrl), .rst(rst_new), .write_data(write_data));
   

    //segment
    seg_ces seg(.clk(clk), .rst(rst_new), .seg_in(seg_in), .seg_en(seg_en), .seg_out(seg_out));


endmodule