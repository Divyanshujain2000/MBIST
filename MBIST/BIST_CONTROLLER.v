`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:21:31 04/02/2021 
// Design Name: 
// Module Name:    BIST_CONTROLLER 
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
 * Bist Controller 
*/
///////////////////////////////////////////////////////////////////////////////
module bist_controller #(
                          parameter DWIDTH = 32,
                                    AWIDTH = 4 
                        )
                    (
                     input clk,
                     input rst,
                     input Test, 

                     input we,
                     input [AWIDTH-1:0] wraddr,
                     input [DWIDTH-1:0] datain,

                     input re,
                     input [AWIDTH-1:0] rdaddr,

                     output reg bist_status,
                     output reg bist_check_valid
                    );

reg [AWIDTH-1:0] wraddr_mux;
reg [AWIDTH-1:0] rdaddr_mux;
reg [DWIDTH-1:0] datain_mux;
reg [DWIDTH-1:0] data_gen;
reg [AWIDTH-1:0] wraddr_gen;
reg [AWIDTH-1:0] rdaddr_gen;
reg bist_control;
reg we_gen,re_gen;
reg we_mux,re_mux;
reg [3:0] state;
reg check;
wire [DWIDTH-1:0] dataout_mem;
reg pattern;
reg fisrt;
localparam IDLE = 'd0,
           w0 = 'd1,
           state1r0 = 'd2,
           state1w1 = 'd3,
			  state2r1 = 'd4,
			  state2w0 = 'd5,
			  state3r0 = 'd6,
			  state3w1 = 'd7,
			  state4r1 = 'd8,
			  state4w0 = 'd9,
			  state5r0 = 'd10,
			  PATTERN_CHECK = 'd11,
			  STOP = 'd12;

localparam DEPTH = 2**AWIDTH;           

always @ (posedge clk) 
begin
  if(rst)
  begin
    state <= IDLE;
    bist_control <= 0;
    wraddr_gen <= 0;
    data_gen <= 0;
    we_gen <= 0;
    check <= 0;
    pattern <= 0;
	 fisrt <=0;
   end
  else
   begin
    case(state)
IDLE : 
      begin
       $display("State = IDLE");
        if(Test)
          begin
            state <= w0;
            bist_control <= 1;
            data_gen <= 1;
          end
        else
         begin
          state <= IDLE;
          bist_control <= 0;
         end
      end
w0:
begin
   	we_gen <= 1;
	re_gen <= 0;
	check <= 0;
       	wraddr_gen <= wraddr_gen + 1; 
       	data_gen <=  {DWIDTH{1'b0}};
       	$display("state = w0");
       	if(wraddr_gen == DEPTH-1)
       	begin
        	state <= state1r0;
		fisrt <= 0;
       	end
end

state1r0:
if(fisrt == 0)
begin
	rdaddr_gen <= 0;
	wraddr_gen <= 0;
	fisrt <= 1;
end
else
begin
   $display("state = state1r0");
	$display("data read = %h",dataout_mem);
	check <= 1;
	we_gen <= 0;
	re_gen <= 1;
	pattern <=0;
	rdaddr_gen <= rdaddr_gen + 1;
        $display("rdaddr_gen=%x",rdaddr_gen);
       	state <=state1w1;
 end
state1w1:
begin
       we_gen <= 1;
	re_gen <= 0;
	check <= 0;
       wraddr_gen <= wraddr_gen + 1; 
       data_gen <=  {DWIDTH{1'b1}};
		 $display("data = %h",data_gen);
       $display("state = state1w1 ");
       if(wraddr_gen == DEPTH-1)
       begin
        state <= state2r1;
	fisrt <= 0;
       end
	else
	state <= state1r0;
       $display("wraddr_gen=%x,data_gen=%x",wraddr_gen,data_gen);
end

state2r1:
if(fisrt ==0 )
begin
	rdaddr_gen <= 0;
	wraddr_gen <= 0;
	we_gen <= 0;
	re_gen <= 1;	
	
	fisrt <= 1;
	$display("state = TEMP state2r1");
end
else
begin
   $display("state = state2r1");
	$display("data read = %h",dataout_mem);
	
	check <= 1;
	pattern <= 1;
	rdaddr_gen <= rdaddr_gen + 1;
        $display("rdaddr_gen=%x",rdaddr_gen);
       	state <=state2w0;
 end

state2w0:
begin
       we_gen <= 1;
	re_gen <= 0;
	check <= 0;
	pattern <= 0;
       wraddr_gen <= wraddr_gen + 1; 
       data_gen <=  {DWIDTH{1'b0}};
       $display("state = state2w0");
       if(wraddr_gen == DEPTH-1)
       begin
        state <= state3r0;
	fisrt<=0;
       end
	else
	state<=state2r1;
       $display("wraddr_gen=%x,data_gen=%x",wraddr_gen,data_gen);
end


state3r0:
if(fisrt == 0)
begin
	rdaddr_gen <= DEPTH-1;
	wraddr_gen <= DEPTH-1;	
	fisrt <= 1;
	we_gen <= 0;
	re_gen <= 1;
end
else
begin
       	$display("state = state3r0");
			$display("data read = %h",dataout_mem);
			check <= 1;
	
	pattern <= 0;
	rdaddr_gen <= rdaddr_gen - 1'b1;
	$display("rdaddr_gen=%x",rdaddr_gen);
       	state <=state3w1;
 end
state3w1:
begin
       we_gen <= 1;
	re_gen <= 0;
	check <= 0;
       wraddr_gen <= wraddr_gen - 1'b1; 
       data_gen <=  {DWIDTH{1'b1}};
       $display("state = state3w1");
       if(wraddr_gen == 0)
       begin
        state <= state4r1;
	fisrt <= 0;
       end
	else
	state<=state3r0;
       $display("wraddr_gen=%x,data_gen=%x",wraddr_gen,data_gen);
end

//


state4r1:
if(fisrt == 0)
begin
	rdaddr_gen <= DEPTH-1;
	wraddr_gen <= DEPTH-1;
	re_gen <= 1;
	check <= 1;
	fisrt <= 1;
end
else
begin
       	$display("state = state4r1");
			$display("data read = %h",dataout_mem);
			we_gen <= 0;
	re_gen <= 1;
	pattern <= 1;
	rdaddr_gen <= rdaddr_gen - 1'b1;
	
        $display("rdaddr_gen=%x",rdaddr_gen);
       	state <=state4w0;
 end

state4w0:
begin
       we_gen <= 1;
	re_gen <= 0;
	check <= 0;
       wraddr_gen <= wraddr_gen - 1'b1; 
       data_gen <=  {DWIDTH{1'b0}};
       $display("state = state4w0");
       if(wraddr_gen == 0)
       begin
        state <= state5r0;
	fisrt<=0;
       end
	else
	state<=state4r1;
       $display("wraddr_gen=%x,data_gen=%x",wraddr_gen,data_gen);
end

state5r0:
      begin
        $display("state = state5r0");
		  we_gen <= 0;
        wraddr_gen <= 0;
        rdaddr_gen <= 0;
        re_gen <= 1;
        state <= PATTERN_CHECK;
        $display("rdaddr_gen=%x",rdaddr_gen);
      end
      PATTERN_CHECK :
      begin
       check <= 1;
	pattern <= 0;
       rdaddr_gen <= rdaddr_gen + 1;
        $display("rdaddr_gen=%x",rdaddr_gen);
       if(rdaddr_gen == DEPTH-1)
        state <= STOP;
      end
STOP:begin 
		$display("state = stop");
		end

   endcase
  end
end


always @ *
begin
 if(bist_control)
 begin
  datain_mux = data_gen;
  wraddr_mux = wraddr_gen;
  re_mux = re_gen;
  rdaddr_mux = rdaddr_gen;
  we_mux = we_gen;
 end
 else
 begin
  datain_mux = datain;
  wraddr_mux = wraddr;
  re_mux = re;
  rdaddr_mux = rdaddr;
  we_mux = we;
 end
end


always @ (posedge clk) 
begin
 if(rst)
 begin
  bist_status <= 0;
  bist_check_valid <= 0;
 end
 else
 begin
 if(check)
 begin
  if((pattern && (~&dataout_mem)) || (~pattern && ( |dataout_mem)))
	begin
		bist_status <= 1;
	end
 end
  $display("bist_status=%b",bist_status);
  $display("dataout_mem=%x",dataout_mem);
  bist_check_valid <= check;
 end
end


memory_model #(
               .DWIDTH(DWIDTH),
               .AWIDTH(AWIDTH)
              )
     u_mem_model (
                 .clk(clk),
                 .rst(rst),
                 .we(we_mux),
                 .wraddr(wraddr_mux),
                 .datain(datain_mux),
                 .re(re_mux),
                 .rdaddr(rdaddr_mux),
                 .dataout(dataout_mem)
               );


endmodule                    


