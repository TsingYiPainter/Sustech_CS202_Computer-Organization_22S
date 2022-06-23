`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/13 19:37:16
// Design Name: 
// Module Name: clkdiv
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module debounceClkDiv(
	input wire clk_100MHz,
	input wire clr,
	output wire clk_190Hz
);
	reg [24:0] q;

	always @(posedge clk_100MHz or posedge clr)
		begin
			if(clr==1)
				q <= 0;
			else
				q <= q+1;
		end

	assign clk_190Hz = q[18];

endmodule