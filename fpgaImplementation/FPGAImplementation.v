module FPGAImplementation	(clock, bitSerialAtualRX, bitsEstaoRecebidos, byteCompleto, haDadosParaTransmitir, 
									byteASerTransmitido, indicaTransmissao, bitSerialAtualTX, bitsEstaoEnviados, display);

	input 				clock;
	input 				bitSerialAtualRX;
	output 				bitsEstaoRecebidos;
	output	[7:0] 	byteCompleto;
	input 				haDadosParaTransmitir;
	input		[7:0] 	byteASerTransmitido; 
	output 				indicaTransmissao;
	output 				bitSerialAtualTX;
	output 				bitsEstaoEnviados;
	output	[6:0]		display;
	
	uart_rx (clock, bitSerialAtual, bitsEstaoRecebidos, byteCompleto);
	uart_tx (clock, haDadosParaTransmitir, byteASerTransmitido, indicaTransmissao, bitSerialAtual, bitsEstaoEnviados);
	
	decoder (byteCompleto, display);

endmodule
