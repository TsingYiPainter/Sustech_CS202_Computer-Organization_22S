`timescale 1ns / 1ps

module shift(
    input clk,                   //backspace or flag
    input rst,
    input flag_button,
    input bs_button,
    input direction,             //0 for flag , 1 for backspace
    input [3:0] in,
    output reg [63:0] out
    );

    wire bs_ex,flag_ex;    

    //转变输出为一个时钟周期的信号
    exciting bs(clk, rst, bs_button, bs_ex);
    exciting flag(clk, rst, flag_button, flag_ex);

    reg counting;
    reg [19:0] cnt;
    reg [7:0] val;
    wire [7:0] last_seg;
    assign last_seg = out[63:56];
    always @ (posedge clk or posedge rst) begin
        if(rst) begin
            out <= ~0;
            cnt <= 0;
        end
        else if(~direction && last_seg == 8'b1111_1111) begin //未满八位
            if(flag_ex) counting <= 1;
            if(counting) begin
                if(cnt == 1000000) begin
                    counting <= 0;
                    cnt <= 0;
                    out <= {out[55:0], val};  // 检测到按键按下就将输入载入
                end 
                else cnt <= cnt + 1;
            end
        end 
        else begin 
            if (bs_ex)out <= {8'b1111_1111, out[63:8]};//退格
            else out <= out;
        end
    end

    always @* begin
        case(in)
            4'h0: val <= 8'b1100_0000;  // 0
            4'h1: val <= 8'b1111_1001;  // 1
            4'h2: val <= 8'b1010_0100;  // 2
            4'h3: val <= 8'b1011_0000;  // 3
            4'h4: val <= 8'b1001_1001;  // 4
            4'h5: val <= 8'b1001_0010;  // 5
            4'h6: val <= 8'b1000_0010;  // 6
            4'h7: val <= 8'b1111_1000;  // 7
            4'h8: val <= 8'b1000_0000;  // 8
            4'h9: val <= 8'b1001_0000;  // 9
            4'hA: val <= 8'b1000_1000;  // A
            4'hB: val <= 8'b1000_0011;  // B
            4'hC: val <= 8'b1100_0110;  // C
            4'hD: val <= 8'b1010_0001;  // D
            4'hE: val <= 8'b1000_0110;  // E
            4'hF: val <= 8'b1000_1110;  // F
            default val <= 8'b1111_1111;
        endcase
    end
endmodule
