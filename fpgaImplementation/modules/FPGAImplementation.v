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

module FPGAImplementation	(clock, bitSerialAtualRX, bitSerialAtualTX, transmission_line_sensor_01, transmission_line_other_sensors, cancel_monitoring);

	input 				clock; //50MHz
	input 				bitSerialAtualRX;
	input					cancel_monitoring;
	output 				bitSerialAtualTX;
	inout  				transmission_line_sensor_01; //Fio de entrada e saida do DHT11 (Tri-state) 
	inout [30:0]		transmission_line_other_sensors; //Vetor de entrada e saida para implementação de outros sensores
	
	wire 			dadosPodemSerEnviados;
	
	wire [7:0]	request_command, request_address, response_command, response_value;
	
	wire bitsEstaoEnviados, indicaTransmissao, bitsEstaoRecebidos;
	
	//bitSerialAtualRX: bit a bit que chega do PC por UART.
	//bitsEstaoRecebidos: bit que confirma todo o recebimento dos bits.
	
	//Implementação da comunicação entre o PC e a FPGA
	//bitsEstaoRecebidos em uart_rx: Em um estado vai para 1, mas nesse mesmo estado já atualiza para outro estado. Nesse outro estado, vai para 0. Com isso, a variação é de um clock.
	uart_rx RECEBE_DADOS(clock, bitSerialAtualRX, bitsEstaoRecebidos, request_command, request_address);
	
	conexao_sensor SE_CONECTA_COM_SENSORES(clock, bitsEstaoRecebidos, request_command, request_address, 
	transmission_line_sensor_01, transmission_line_other_sensors, dadosPodemSerEnviados, response_command, response_value);
	
	uart_tx ENVIA_DADOS(clock, dadosPodemSerEnviados, response_command, response_value, indicaTransmissao, bitSerialAtualTX, bitsEstaoEnviados);

endmodule
