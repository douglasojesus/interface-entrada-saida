module FPGAImplementation	(clock, bitSerialAtualRX, bitsEstaoRecebidos, byteCompleto, haDadosParaTransmitir, 
									indicaTransmissao, bitSerialAtualTX, bitsEstaoEnviados, display);

	input 				clock;
	input 				bitSerialAtualRX;
	output 				bitsEstaoRecebidos;
	output	[7:0] 	byteCompleto;
	input 				haDadosParaTransmitir;
	output 				indicaTransmissao;
	output 				bitSerialAtualTX;
	output 				bitsEstaoEnviados;
	output	[6:0]		display;
	
	uart_rx (clock, bitSerialAtualRX, bitsEstaoRecebidos, byteCompleto);
	uart_tx (clock, haDadosParaTransmitir, indicaTransmissao, bitSerialAtualTX, bitsEstaoEnviados);
	
	decoder (byteCompleto, display);

endmodule
