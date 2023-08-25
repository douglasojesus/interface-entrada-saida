module FPGAImplementation(clock, bitSerialAtual, bitsEstaoRecebidos, byteCompleto, i_Tx_DV, i_Tx_Byte, o_Tx_Active, o_Tx_Serial, o_Tx_Done, display);

	input 			clock;
	input 			bitSerialAtual;
	output 			bitsEstaoRecebidos;
	output [7:0] 	byteCompleto;
	input 			i_Tx_DV;
	input [7:0] 	i_Tx_Byte; 
	output 			o_Tx_Active;
	output 			o_Tx_Serial;
	output 			o_Tx_Done;
	output [6:0]	display;
	
	uart_rx (clock, bitSerialAtual, bitsEstaoRecebidos, byteCompleto);
	uart_tx (clock, i_Tx_DV, i_Tx_Byte, o_Tx_Active, o_Tx_Serial, o_Tx_Done);
	
	decoder (byteCompleto, display);

endmodule
