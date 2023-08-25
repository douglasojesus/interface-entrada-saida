module FPGAImplementation(i_Clock, i_Rx_Serial, o_Rx_DV, o_Rx_Byte, i_Tx_DV, i_Tx_Byte, o_Tx_Active, o_Tx_Serial, o_Tx_Done);

	input 			i_Clock;
	input 			i_Rx_Serial;
	output 			o_Rx_DV;
	output [7:0] 	o_Rx_Byte;
	input 			i_Tx_DV;
	input [7:0] 	i_Tx_Byte; 
	output 			o_Tx_Active;
	output 			o_Tx_Serial;
	output 			o_Tx_Done;

	uart_rx (i_Clock, i_Rx_Serial, o_Rx_DV, o_Rx_Byte);
	uart_tx (i_Clock, i_Tx_DV, i_Tx_Byte, o_Tx_Active, o_Tx_Serial, o_Tx_Done);

endmodule
