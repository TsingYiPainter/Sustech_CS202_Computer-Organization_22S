`timescale 1ns / 1ps

module register (
    input clk,
    input flag,
    input backspace_button,
    input rst,
    input [3:0] key,
    output [63:0] seg_out
    );

    //mode = 1 -> backspace
    //mode = 0 -> flag
    reg mode = 0;
    always @ (posedge clk or posedge rst) begin
        if(rst) begin
            mode <= 0;
        end
        else if (backspace_button) mode <= 1;
        else mode <= 0;
    end

    wire[7:0] val;
    shift shift(clk, rst, flag, backspace_button, mode, key, seg_out);

endmodule
