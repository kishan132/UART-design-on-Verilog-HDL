//*************************************************************************
//*************  TOP MODULE   *********************************************
//*************************************************************************

module top(
	input clk,
	input i_tx_dv,
	input [7:0]i_tx_byte,
	output o_rx_dv,
	output [7:0]o_rx_byte
    );

wire t1;

// INSTANTIATE UART TRANSMITTER MODULE.
uartTX u1(clk,i_tx_dv,i_tx_byte,o_tx_active,t1,o_tx_done);

// INSTANTIATE UART RECEIVER MODULE.
uartRX u2(clk,t1,o_rx_dv,o_rx_byte);

endmodule
