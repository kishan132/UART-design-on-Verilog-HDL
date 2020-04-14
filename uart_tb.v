//*************************************************************************
//*************  TEST SIMULATION OF UART MODULE   *************************
//*************************************************************************
`timescale 1ns / 1ps

module uart_TB;

	// Inputs
	reg clk;
	reg i_tx_dv;
	reg [7:0] i_tx_byte;

	// Outputs
	wire o_rx_dv;
	wire [7:0] o_rx_byte;

	// Instantiate the Unit Under Test (UUT)
	top uut (
		.clk(clk), 
		.i_tx_dv(i_tx_dv), 
		.i_tx_byte(i_tx_byte), 
		.o_rx_dv(o_rx_dv), 
		.o_rx_byte(o_rx_byte)
	);

	 always begin
    clk=0;
	 #5 clk=1;
	 #5;
	end
	 
 
   
  // Main Testing:
  initial
    begin
       
      // Tell UART to send a command (exercise Tx)
      @(posedge clk);
      @(posedge clk);
      i_tx_dv <= 1'b1;
      i_tx_byte <= 8'hBE;
      @(posedge clk);
      i_tx_dv <= 1'b0;
      
      #9000;       
      // Check that the correct command was received
      if (o_rx_byte == 8'hBE)
        $display("Test Passed - Correct Byte Received");
      else
        $display("Test Failed - Incorrect Byte Received");
		  
      #10
		$finish;
    end
      
endmodule

