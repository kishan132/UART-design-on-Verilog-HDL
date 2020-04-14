//*************************************************************************
//*************  UART TRANSMITTER MODULE   ********************************
//*************************************************************************

module uartTX(
	input clk,
	input i_tx_dv,
	input [7:0]i_tx_byte,
	output o_tx_active,
	output reg o_tx_serial,
	output o_tx_done
    );

// FPGA OPERATE ON 100 MZ CLOCK FREQUENCY
// SET BAUDRATE OF 115200	
// CLK_PER_BIT= 100 MZ/115200 =87 
parameter CLK_PER_BIT=87;

// DIFFERENT BIT STATE
parameter IDLE    =3'b000;
parameter START   =3'b001;
parameter DATA    =3'b010;
parameter STOP    =3'b011;
parameter CLEANUP =3'b100;
// DIFFERENT INTERNAL COMPONENTS
reg [7:0]count;
reg [2:0] bitIndex;
reg [2:0]state;
reg [7:0]r_tx_data;
reg r_tx_done=0;
reg r_tx_active;

always@(posedge clk)
begin
	case(state)
   // INITIALLY ALL PROCESS IN IDLE STATE
	IDLE: begin                     
				o_tx_serial<=1'b1;
				count<=0;
				bitIndex<=0;
				if(i_tx_dv==1'b1)
				begin
					r_tx_active<=1'b1;
					r_tx_data<=i_tx_byte;
					state<=START;
				end
				else
					state<=IDLE;
			end
   // SEND ZERO FIRST AS START BIT
	START: begin                   
				o_tx_serial<=1'b0;
				if(count<CLK_PER_BIT-1)
				begin
					count<=count+1;
					state<=START;
				end
				else
				begin
					count<=0;
					state<=DATA;
				end
			 end
   // SEND 8 BIT DATA BIT SERIALLY WITH BAUDRATE OF 115200
	DATA: begin                      
				o_tx_serial<=r_tx_data[bitIndex];
				if(count<CLK_PER_BIT-1)
				begin
					count<=count+1;
					state<=DATA;
				end
				else
				begin
					count<=0;
					if(bitIndex<7)  // ONLY UPTO 8 BIT OF DATA
					begin
						bitIndex<=bitIndex+1;
						state<=DATA;
					end
					else
					begin
						bitIndex<=0;
						state<=STOP;
					end
				end
			end
    //  SEND STOP BIT AFTER 8 BIT DATA
	STOP: begin                       
				o_tx_serial<=1'b1;
				if(count<CLK_PER_BIT-1)
				begin
					count<=count+1;
					state<=STOP;
				end
				else
				begin
					r_tx_done<=1'b1;
					count<=0;
					state<=CLEANUP;
					r_tx_active<=1'b0;
				end
			end
     //  FINALLY PROCESS WILL GO IN CLEANUP STATE
	CLEANUP: begin                    
					r_tx_done<=1'b1;
					state<=IDLE;
				end
	default: state<=IDLE;	
   endcase	
end

assign o_tx_active=r_tx_active;
assign o_tx_done=r_tx_done;

endmodule
