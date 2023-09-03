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
									indicaTransmissao, bitSerialAtualTX, bitsEstaoEnviados, display, transmission_line, hold, error);

	input 				clock;
	input 				bitSerialAtualRX;
	output 				bitsEstaoRecebidos;
	output 				indicaTransmissao;
	output 				bitSerialAtualTX;
	output 				bitsEstaoEnviados;
	output	[6:0]		display;
	inout  				transmission_line; //Fio de entrada e saida do DHT11 (Tri-state)
	output  				hold; //FLag de comunicacao em andamento  
	output  				error;  


	wire [7:0] 	primeiroByteCompleto, primeiroByteASerTransmitido;	//Byte a ser recebido do PC através do RX
	wire [7:0] 	segundoByteCompleto, segundoByteASerTransmitido;
	wire [7:0]  byteASerTransmitido; //Vai ser do DHT11
	wire 			haDadosParaTransmitir;
	wire 			dadosPodemSerEnviados;
	wire [7:0] 	hum_int;
	wire [7:0] 	hum_float;
	wire [7:0] 	temp_int;
	wire [7:0] 	temp_float;
	
	wire enable, reset;

	
	//bitSerialAtualRX: bit a bit que chega do PC por UART.
	//bitsEstaoRecebidos: bit que confirma todo o recebimento dos bits.
	//byteCompleto: vetor com todos os bits que chegaram atraves do UART.
	
	//Implementação da comunicação entre o PC e a FPGA
	uart_rx (clock, bitSerialAtualRX, bitsEstaoRecebidos, primeiroByteCompleto, segundoByteCompleto);
	
	//haDadosParaTransmitir: bit que informa que os dados do byteASerTransmitido devem ser enviados.
	//byteASerTransmitido: byte que serve de entrada para enviar bit a bit.
	
	DHT11Communication (clock, enable, reset, transmission_line, hum_int, hum_float, temp_int, temp_float, hold, error, dadosPodemSerEnviados);
	
	wire teste;
	
	//or(teste, hum_int[7], hum_int[6], hum_int[5], hum_int[4], hum_int[3], hum_int[2], hum_int[1], hum_int[0]);
	
	decoder (segundoByteCompleto, display, teste);
	
	assign primeiroByteASerTransmitido = hum_int; //Faz o que está entrando na FPGA voltar para o PC
	assign segundoByteASerTransmitido = temp_int; //Faz o que está entrando na FPGA voltar para o PC
	assign haDadosParaTransmitir = dadosPodemSerEnviados;
	
	uart_tx (clock, haDadosParaTransmitir, primeiroByteASerTransmitido, segundoByteASerTransmitido, indicaTransmissao, bitSerialAtualTX, bitsEstaoEnviados);

endmodule
