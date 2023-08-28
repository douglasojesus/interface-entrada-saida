/*
*Partes que faltam ser implementadas: 
*	recebimento de dados do PC; -> em construção. -> Falta testar comunicação e aplicar para 2 bytes.
*	envio de dados para o PC; -> em construção. -> Falta testar comunicação e aplicar para 2 bytes.
*	recebimento e envio de dados do DHT11;
*	decodificação de entrada vinda do DTH11 para enviar os dados corretos para o PC;
*	decodificação de entrada vinda do PC;
*  processamento de dados recebidos do DHT11 de acordo com a entrada vinda do PC;
*/


/*
*						MÓDULO PRINCIPAL
*/


module FPGAImplementation	(clock, bitSerialAtualRX, bitsEstaoRecebidos, haDadosParaTransmitir, 
									indicaTransmissao, bitSerialAtualTX, bitsEstaoEnviados, display);

	input 				clock;
	input 				bitSerialAtualRX;
	output 				bitsEstaoRecebidos;
	input 				haDadosParaTransmitir;
	output 				indicaTransmissao;
	output 				bitSerialAtualTX;
	output 				bitsEstaoEnviados;
	output	[6:0]		display;

	wire [7:0] 	byteCompleto;	
	
	//Implementação da comunicação entre o PC e a FPGA
	uart_rx (clock, bitSerialAtualRX, bitsEstaoRecebidos, byteCompleto);
	uart_tx (clock, haDadosParaTransmitir, indicaTransmissao, bitSerialAtualTX, bitsEstaoEnviados);
	
	decoder (byteCompleto, display);

endmodule
