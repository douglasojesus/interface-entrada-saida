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

/*
SICRONIZAÇÃO:
MÓDULOS:

DHT11 -> 1MHz
CONEXAO_SENSOR -> 50MHz
UART RX/TX -> 50MHz

*/

module FPGAImplementation	(clock, bitSerialAtualRX, bitSerialAtualTX, transmission_line);

	input 				clock;
	input 				bitSerialAtualRX;
	output 				bitSerialAtualTX;
	inout  				transmission_line; //Fio de entrada e saida do DHT11 (Tri-state) 
	
	wire [7:0] 	segundoByteCompleto;
	wire [7:0]  byteASerTransmitido; //Vai ser do DHT11
	wire 			haDadosParaTransmitir;
	wire 			dadosPodemSerEnviados;
	
	wire [7:0]	request_command, request_address, response_command, response_value;
	
	wire bitsEstaoEnviados, indicaTransmissao, bitsEstaoRecebidos;
	
	//bitSerialAtualRX: bit a bit que chega do PC por UART.
	//bitsEstaoRecebidos: bit que confirma todo o recebimento dos bits.
	//byteCompleto: vetor com todos os bits que chegaram atraves do UART.
	
	//Implementação da comunicação entre o PC e a FPGA
	uart_rx RECEBE_DADOS(clock, bitSerialAtualRX, bitsEstaoRecebidos, request_command, segundoByteCompleto);
	
	//haDadosParaTransmitir: bit que informa que os dados do byteASerTransmitido devem ser enviados.
	//byteASerTransmitido: byte que serve de entrada para enviar bit a bit.
	
	//Para teste:
	assign request_address = 8'b00000001; //Deve ligar o DHT11.
	
	conexao_sensor SE_CONECTA_COM_SENSORES(clock, bitsEstaoRecebidos, request_command, request_address, transmission_line, dadosPodemSerEnviados, response_command, response_value);
	
	uart_tx ENVIA_DADOS(clock, dadosPodemSerEnviados, response_command, response_value, indicaTransmissao, bitSerialAtualTX, bitsEstaoEnviados);

endmodule
