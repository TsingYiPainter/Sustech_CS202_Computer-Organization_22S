`timescale 1ns / 1ps

module MemOrIO(MemRead, MemWrite, IORead, IOWrite, addr_in, addr_out, M_ReadData, IO_ReadData, test_index, InputCtrl, Reg_WriteData, Reg_ReadData, write_data, LEDCtrl, LEDELCtrl, SwitchCtrl); 
    //from controller
    input MemRead;                          // read memory, from Controller 
    input MemWrite;                         // write memory, from Controller 
    input IORead;                         // read IO, from Controller 
    input IOWrite;                        // write IO, from Controller 

    input[31:0] addr_in;                  // from alu_result in ALU 
    output[31:0] addr_out;                // address to Data-Memory 

    input[31:0] M_ReadData;                  // data read from Data-Memory 
    input[15:0] IO_ReadData;                 // data read from IO,16 bits 
    input[2:0] test_index;
    input InputCtrl;                       // index inputCtrl
    
    output reg[31:0] Reg_WriteData;              // data to Decoder(register file) 

    input[31:0] Reg_ReadData;                  // data read from Decoder(register file) 
    output reg[31:0] write_data;          // data to memory or I/O（m_wdata, io_wdata)
    output LEDCtrl;                       // LED Chip Select 
    output LEDELCtrl;
    output SwitchCtrl;                    // Switch Chip Select

    assign addr_out = addr_in;
    
    // The data wirte to register file may be from memory or io.
    // While the data is from io, it should be the lower 16bit of r_wdata.
    always @(*) begin
        if(IORead == 1)begin
            if ((addr_in >= 32'hffff_fc70) && (addr_in <= 32'hffff_fc73)) begin//input data
                Reg_WriteData <= IO_ReadData;
            end
            else if((addr_in >= 32'hffff_fc7c) && (addr_in <= 32'hffff_fc7f)) begin//input ctrl
                Reg_WriteData <= InputCtrl;
            end
            else if((addr_in >= 32'hffff_fc78) && (addr_in <= 32'hffff_fc7b)) begin//input test_index
                Reg_WriteData <= test_index;
            end else
                Reg_WriteData <= 0;
        end
        else begin
            Reg_WriteData <= M_ReadData;
        end
    end
    // Chip select signal of Led and Switch are all active high; 
    assign LEDCtrl = ((addr_in >= 32'hffff_fc60) && ((addr_in <= 32'hffff_fc68)) && (IOWrite == 1))? 1 : 0;
    assign LEDELCtrl = (addr_in == 32'hffff_fc68)? 1 : 0;
    assign SwitchCtrl = ((addr_in >= 32'hffff_fc70) && (addr_in <= 32'hffff_fc73) && (IORead == 1))? 1 : 0;
    always @* begin 
        if((MemWrite==1)||(IOWrite==1)) 
            //wirte_data could go to either memory or IO. where is it from? 
            write_data = Reg_ReadData;
        else 
            write_data = 32'hZZZZ_ZZZZ; 
    end

endmodule