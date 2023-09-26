/*

		Módulo principal de comunicação com os sensores.

*/


module conexao_sensor(
	input 			clock,
	input 			enable,
	input [7:0] 	request_command,
	input [7:0] 	request_address,
	inout 			transmission_line_sensor_01,
	inout [30:0]	transmission_line_other_sensors,
	output			dadosPodemSerEnviados,
	output [7:0] 	response_command,
	output [7:0] 	response_value
);

	/************VARIÁVEIS TEMPORÁRIAS************/
	
	reg [7:0] 	response_command_reg, response_value_reg;
	reg 			dadosPodemSerEnviados_reg;
	wire [39:0] sensor_data;
	
	/************VARIÁVEIS TEMPORÁRIAS************/
		

	reg 			enable_sensor;
	reg [26:0] 	contador;
	reg 			in_loop;
	wire [7:0] 	hum_int_dht11, temp_int_dht11;
	wire 			error;
	wire 			errorChecksum;
	wire 			dadosOK;	
	wire 			clock_1M;

		
	/*************************************************** SENSORES ***************************************************/
	
	// Declaração de fios de enable de cada sensor disponível para ser utilizado
	wire 	enable_sensor_01, enable_sensor_02, enable_sensor_03, enable_sensor_04,
			enable_sensor_05, enable_sensor_06, enable_sensor_07, enable_sensor_08,
			enable_sensor_09, enable_sensor_10, enable_sensor_11, enable_sensor_12,
			enable_sensor_13, enable_sensor_14, enable_sensor_15, enable_sensor_16,
			enable_sensor_17, enable_sensor_18, enable_sensor_19, enable_sensor_20,
			enable_sensor_21, enable_sensor_22, enable_sensor_23, enable_sensor_24,
			enable_sensor_25, enable_sensor_26, enable_sensor_27, enable_sensor_28,
			enable_sensor_29, enable_sensor_30, enable_sensor_31, enable_sensor_32;
	
	/*	Cada sensor tem sua implementação. Todos são chamados nesse bloco "SENSORES". O enable_sensor_X enviado 
		para cada um será de acordo com a seguinte regra de endereço: depois do último underline, o número identificado em
		decimal será equivalente ao endereço representado em binário. Exemplo: enable_sensor_01 é o enable do sensor 
		alocado no endereço 8'b00000001.
	*/

	divisor_de_clock DIVISAO_CLOCK_50_TO_1(clock, clock_1M);

	//Todos os sensores devem ter como saída 40 bits de dados, um bit de erro e um bit que informe que os dados foram recebidos.
	//Todos os sensores devem ter como entrada o enable de acordo com seu endereço e o clock.
	//A comunicação da FPGA com o anexo do sensor é bidirecional, portanto, deve haver um fio inout de comunicação.
	
	/*SENSOR 1*/
	DHT11_Communication SENSOR_DHT11(clock_1M, enable_sensor_01, transmission_line_sensor_01, sensor_data, error, dadosOK);
	
	/*SENSOR 2*/
	/*SENSOR 3*/
	/*SENSOR 4*/
	/*SENSOR 5*/
	/*SENSOR 6*/
	/*...*/
	/*SENSOR 32*/
	

	//Seleciona qual sensor foi ativado de acordo com o endereço.
	//Forma de testar: manda um endereço. Liga cada enable_sensor a um led. Verifica qual led liga de acordo com o endereço enviado.
	assign enable_sensor_01 = (request_address == 8'b00000001) ? enable_sensor : 1'b0;
	assign enable_sensor_02 = (request_address == 8'b00000010) ? enable_sensor : 1'b0;	
	/*...*/
	assign enable_sensor_32 = (request_address == 8'b00100000) ? enable_sensor : 1'b0;
	
	/*************************************************** SENSORES ***************************************************/
	
	assign hum_int_dht11   	= sensor_data[39:32];
	assign temp_int_dht11   = sensor_data[23:16];
	
	assign errorChecksum = (sensor_data[7:0] == sensor_data[15:8] + sensor_data[23:16] + sensor_data[31:24] + sensor_data[39:32]) ? 1'b0 : 1'b1;	

	localparam [1:0] ESPERA = 2'b00, LEITURA = 2'b01, ENVIO = 2'b10, STOP = 2'b11;
	
	reg [2:0] current_state = ESPERA;
	
	always @(posedge clock)
		begin
			if (errorChecksum == 1'b1 || error == 1'b1)
				begin //Sensor com problema
					response_value_reg <= 8'h45; //E
					response_command_reg <= 8'h45; //E
				end
			else
				//Se não tiver erro
				begin
					case (current_state)
						ESPERA:
							begin
								if (in_loop == 1'b1)
									begin
										contador <= contador + 1'b1;
										if (contador >= 27'd100000000) //2 segundos
											begin
												current_state <= LEITURA;
												contador <= 1'b0;
											end
										else
											begin
												current_state <= ESPERA;
											end
									end
								else
									begin
										if (enable == 1'b0)
											begin
												current_state <= ESPERA;
												enable_sensor  <= 1'b0;
											end
										else  //Quando o sensor parar de enviar os dados e o enable estiver ativado
											begin
												current_state <= LEITURA;
												enable_sensor  <= 1'b1;
											end
										dadosPodemSerEnviados_reg <= 1'b0;
									end
							end
						LEITURA:
							begin
								if(dadosOK == 1'b1)
									begin
									//Verifica se depois que iniciou o loop, o comando é algum diferente do sensoriamento contínuo (ativação ou desativação)
										if (in_loop == 1'b1 && (request_command != 8'h03 && request_command != 8'h04 && response_command != 8'h05 && response_command != 8'h06))
											begin
												response_value_reg <= 8'hFF; //Comando inválido devido a ativação do sensoriamento contínuo. Precisa desativar.
												response_command_reg <= 8'hFF;
												current_state <= ENVIO;
											end
										else
											begin
												case (request_command)
													8'hAC: //Solicita a situação atual do sensor
														begin
															if (dadosOK == 1'b1 && errorChecksum == 1'b0 && error == 1'b0)
																begin
																	response_value_reg <= 8'h07; //Sensor funcionando normalmente
																	response_command_reg <= 8'h07;
																end
															else
																begin
																	response_value_reg <= 8'h1F; //Sensor com problema
																	response_command_reg <= 8'h1F;
																end
														end
													8'h01: //Solicita a medida de temperatura atual
														begin
															response_value_reg <= temp_int_dht11;
															response_command_reg <= 8'h09; //Medida de temperatura
														end
													8'h02: //Solicita a medida de umidade atual
														begin
															response_value_reg <= hum_int_dht11;
															response_command_reg <= 8'h08;//Medida de umidade
														end
													8'h03: //Ativa sensoriamento contínuo de temperatura
														begin
															response_value_reg <= temp_int_dht11;
															response_command_reg <= 8'h0D;
															in_loop <= 1'b1;
														end
													8'h04: //Ativa sensoriamento contínuo de umidade
														begin
															response_value_reg <= hum_int_dht11;
															response_command_reg <= 8'h0E;
															in_loop <= 1'b1;
														end 
													8'h05: //Desativa sensoriamento contínuo de temperatura
														begin
															response_value_reg <= 8'h0A;
															response_command_reg <= 8'h0A;
															in_loop <= 1'b0;
														end 
													8'h06: //Desativa sensoriamento contínuo de umidade
														begin
															response_value_reg <= 8'h0B;
															response_command_reg <= 8'h0B;
															in_loop <= 1'b0;
														end 
													default:
														begin
															response_value_reg <= 8'h45; //E
															response_command_reg <= 8'h45; //E
														end
												endcase
												current_state <= ENVIO;
											end
									end
							end
						ENVIO:
							begin
								dadosPodemSerEnviados_reg <= 1'b1;
								current_state <= STOP;
								contador <= 0;
							end
						STOP:
							begin
								current_state <= ESPERA;
								enable_sensor <= 1'b0;
							end				

						default: //Algum erro na máquina de estados
							begin
								response_value_reg <= 8'hAB;
								response_command_reg <= 8'hAB;
								enable_sensor <= 1'b0;
							end
					endcase	
				end				
		end
		
	assign dadosPodemSerEnviados = dadosPodemSerEnviados_reg;
	assign response_command = response_command_reg;
	assign response_value = response_value_reg;
	
	
endmodule