module conexaoSensor(
	input clock,
	input reset,
	input [7:0] request_command,
	input [7:0] request_address,
	inout transmission_line,
	output dadosPodemSerEnviados,
	output [7:0] response_command,
	output [7:0] response_value
);

	wire [7:0] hum_int, hum_float, temp_int, temp_float;

	DHT11Communication (clock, request_address, reset, transmission_line, hum_int, hum_float, temp_int, temp_float, hold, error, dadosPodemSerEnviados);
	//Todos os outros sensores
	//TODO ver os protocolos para devolver o comando solicitado
	//if o comando solicitado foi umidade, devolver umidade do módulo, assim sucessivamente....
	
	
	//Para teste:
	assign response_command = hum_int;
	assign response_value 	= temp_int;
	
	

endmodule