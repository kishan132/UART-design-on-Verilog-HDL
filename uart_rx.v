//*************************************************************************
//*************  UART RECEIVER MODULE   ***********************************
//*************************************************************************

module uartRX(
	input clk,
	input i_rx_serial,
	output o_rx_dv,
	output [7:0]o_rx_byte
 );

// FPGA OPERATE ON 100 MZ CLOCK FREQUENCY
// SET BAUDRATE OF 115200	
// CLK_PER_BIT= 100 MZ/115200 =87 
parameter CLK_PER_BIT=87;  // AFTER EVERY 87 CLOCK PULSE 1 BIT WILL RECEIVE

// DIFFERENT BIT STATE
parameter IDLE=3'b000;
parameter START=3'b001;
parameter DATA=3'b010;
parameter STOP=3'b011;
parameter CLEANUP=3'b100;	

// DIFFERENT INTERNAL COMPONENTS
reg r_rx_data_r  =1'b1;
reg r_rx_data    =1'b1;

reg [7:0]count;
reg [2:0] bitIndex;
reg [2:0]state;
reg [7:0]r_rx_byte;
reg r_rx_dv;

always@(posedge clk)
begin
	r_rx_data_r<=i_rx_serial;    // USE OF DOUBLE RESISROR TO AVOID 
	r_rx_data<=r_rx_data_r;      // UNSTABILITY OF MESSAGE BIT
end

always@(posedge clk)
begin
	case(state)
  // INITIALLY ALL PROCESS IN IDLE STATE
		IDLE: begin             
				count<=0;
				bitIndex<=0;
				r_rx_dv<=0;
				if(r_rx_data==0)
					state<=START;
				else
					state<=IDLE;
				end
      // RECEIVE AND CHECK ZERO BIT FIRST
		START: begin                
					 if(count==(CLK_PER_BIT-1)/2)
					 begin
						if(r_rx_data==0)
						begin
							state<=DATA;
							count<=0;
						end
						else
							state<=IDLE;
					 end
					 else
					 begin
						count<=count+1;
						state<=START;
					 end
				 end
       // RECEIVE 8 BIT DATA SERIALLY WITH BAUDRATE OF 115200
		DATA: begin               
					if(count<CLK_PER_BIT-1)
					begin
						count<=count+1;
						state<=DATA;
					end
					else
					begin
						count<=0;
						r_rx_byte[bitIndex]<=r_rx_data;
						if(bitIndex<7)           // ONLY UPTO 8 BIT OF DATA
						begin
							bitIndex=bitIndex+1;
							state<=DATA;
						end
						else
						begin
							bitIndex<=0;
							state<=STOP;
						end
					end
				end
      // RECEIVE 1 BIT AFTER RECEIVING 8 BIT OF DATA SERIALLY
		STOP: begin                       
					if(count<CLK_PER_BIT-1)
						begin
							count<=count+1;
							state<=STOP;
						end
					else
						begin
							r_rx_dv<=1'b1;
							count<=0;
							state<=CLEANUP;
						end
				end
      // FINALLY PROCESS WILL GO IN CLEANUP STATE
		CLEANUP: begin                   
						r_rx_dv<=1'b1;
						state<=IDLE;
					end
		default: state<=IDLE;			
	endcase
end

assign o_rx_dv=r_rx_dv;
assign o_rx_byte=r_rx_byte;

endmodule
