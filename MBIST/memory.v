`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:21:46 04/02/2021 
// Design Name: 
// Module Name:    memory 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
/*
 * Simple Memory Model with Synchronous Reset
 * If Reset is asserted all the contents are initialized to zero
 * If we is asserted, data is written to location pointed by wraddr (write address)
 * Output appears on the dataout synchronously when re (read enable) is
 * asserted for the corresponding raddr (read address)
*/
///////////////////////////////////////////////////////////////////////////////
module memory_model #(
                      parameter DWIDTH = 32,
                                AWIDTH = 10
                     )
                    (
                     // Clock and Reset
                     input clk,
                     input rst,
                  
                     // Write Interface
                     input we,
                     input [AWIDTH-1:0] wraddr,
                     input [DWIDTH-1:0] datain,

                     // Read Interface
                     input re,
                     input [AWIDTH-1:0] rdaddr,
                     output reg [DWIDTH-1:0] dataout
                    );

localparam DEPTH = 2**AWIDTH;
reg [DWIDTH-1:0] mem [DEPTH-1:0];

integer i;

always @ (posedge clk)
begin
 if(rst)
  begin
    for(i=0;i<DEPTH-1;i=i+1)
      mem[wraddr] <= 0;
  end
 else
  begin
    if(we)
      mem[wraddr] <= datain;
  end
end

always @ (posedge clk)
begin
 if(re)
  dataout <= mem[rdaddr];
end

endmodule                    








