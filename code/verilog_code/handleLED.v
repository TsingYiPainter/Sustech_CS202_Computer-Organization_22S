module handleLED(
	input wire LEDCtrl,
    input wire LEDELCtrl,
	input wire rst,
	input wire [31:0] write_data,
	output wire [16:0] IO_LED_Data
);

    reg [16:0] IO_WriteData = 0;
    assign IO_LED_Data = IO_WriteData;


    always @(posedge LEDCtrl or posedge rst)    
    begin
        if(rst == 1)
         IO_WriteData <=0;
        else if(LEDCtrl == 1)
        begin
            IO_WriteData <= write_data[16:0];
            if(LEDELCtrl != 1)
                IO_WriteData[16] <= 0;
        end
    end


endmodule