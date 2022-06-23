`timescale 1ns / 1ps

module debounce(
    input clk_fast,
    input rst,
    input key_in,
    output wire key_out
    );

    reg delay1=0;
    reg delay2=0;
    reg delay3=0;

    always @ (posedge clk_fast or posedge rst)
    begin
        if(rst == 1)
            begin
                delay1<=key_in;
                delay2<=key_in;
                delay3<=key_in;
            end
        else begin
            delay1 <= key_in;
            delay2 <= delay1;
            delay3 <= delay2;
        end
    end

    assign key_out = ((delay1 == delay2) && (delay2 == delay3) && (delay1 == 1))?1:0;

endmodule