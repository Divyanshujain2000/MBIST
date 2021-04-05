`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:21:39 04/02/2021 
// Design Name: 
// Module Name:    tb 
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
// Copyright (c) 2005 Xilinx, Inc.
// All Rights Reserved


module tb;
parameter DWIDTH = 32;
parameter AWIDTH = 4;

reg clk;
reg Test;
reg rst;

reg [AWIDTH-1:0] wraddr,rdaddr;
reg we,re;
reg [DWIDTH-1:0] datain;

initial
begin
clk = 0;
end

always
begin
#100 clk = ~clk;
end

bist_controller u (
                   .clk(clk),
                   .rst(rst),
                   .Test(Test),
                   .we(we),
                   .wraddr(wraddr),
                   .datain(datain),
                   .re(re),
                   .rdaddr(rdaddr),
                   .bist_status(bist_status),
                   .bist_check_valid(bist_check_valid)
                  );

initial
begin
 Test = 0;
 rst = 1;
 #250;
 rst = 0;
 Test = 1;
  #(100*100);
 force u.u_mem_model.mem[3] = 0;
 #(100*100);
 $finish;
end

always @ (posedge clk)
begin
 if(bist_check_valid)
 begin
   if(bist_status == 0)
    $display("BIST PASSED");
   else
    $display("BIST FAILED");
 end
end

endmodule


