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

module FPGAImplementation	(clock, bitSerialAtualRX, bitsEstaoRecebidos, 
									indicaTransmissao, bitSerialAtualTX, bitsEstaoEnviados, display);

	input 				clock;
	input 				bitSerialAtualRX;
	output 				bitsEstaoRecebidos;
	output 				indicaTransmissao;
	output 				bitSerialAtualTX;
	output 				bitsEstaoEnviados;
	output	[6:0]		display;

	wire [7:0] 	primeiroByteCompleto, primeiroByteASerTransmitido;	//Byte a ser recebido do PC através do RX
	wire [7:0] 	segundoByteCompleto, segundoByteASerTransmitido;
	wire [7:0]  byteASerTransmitido; //Vai ser do DHT11
	wire 			haDadosParaTransmitir;
	
	//bitSerialAtualRX: bit a bit que chega do PC por UART.
	//bitsEstaoRecebidos: bit que confirma todo o recebimento dos bits.
	//byteCompleto: vetor com todos os bits que chegaram atraves do UART.
	
	//Implementação da comunicação entre o PC e a FPGA
	uart_rx (clock, bitSerialAtualRX, bitsEstaoRecebidos, primeiroByteCompleto, segundoByteCompleto);
	
	//haDadosParaTransmitir: bit que informa que os dados do byteASerTransmitido devem ser enviados.
	//byteASerTransmitido: byte que serve de entrada para enviar bit a bit.
	
	assign primeiroByteASerTransmitido = primeiroByteCompleto; //Faz o que está entrando na FPGA voltar para o PC
	assign segundoByteASerTransmitido = segundoByteCompleto; //Faz o que está entrando na FPGA voltar para o PC
	assign haDadosParaTransmitir = bitsEstaoRecebidos;
	
	uart_tx (clock, haDadosParaTransmitir, primeiroByteASerTransmitido, segundoByteASerTransmitido, 
	indicaTransmissao, bitSerialAtualTX, bitsEstaoEnviados);
	
	decoder (segundoByteCompleto, display);

endmodule
