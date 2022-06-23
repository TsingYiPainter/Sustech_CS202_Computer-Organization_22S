`timescale 1ns / 1ps

module counter(
    input clk,
    input rst,
    output clk_out
    );
    parameter period = 14'd10000;
    reg [13:0] cnt_1 = period;
    always @ (posedge clk or posedge rst) 
        if(rst) begin
            cnt_1 <= 0;
        end
        else if(cnt_1 == period)
            cnt_1 <= 14'd0;
        else cnt_1 <= cnt_1 + 1'b1;
        
    assign clk_out = (cnt_1 == period) ? 1'b1 : 1'b0;
    //测试下
endmodule