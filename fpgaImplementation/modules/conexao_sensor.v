module conexao_sensor(
	input 			clock,
	input 			enable,
	input				stop_button,
	input [7:0] 	request_command,
	input [7:0] 	request_address,
	inout 			transmission_line,
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
	
	wire [7:0] 	hum_int_dht11, temp_int_dht11;
	wire 			error;
	wire 			errorChecksum;
	
	wire 			dadosOK;
	
	reg 			in_loop;
	
	/*************************************************** SENSORES ***************************************************/
	
	//Todos os sensores devem ter como saída 40 bits de dados, um bit de erro e um bit que informe que os dados foram recebidos.
	
	/*SENSOR 1*/
	//DHT11_Communication SENSOR_DHT11(clock, enable_sensor, transmission_line, sensor_data, error, dadosOK);
	
	/*SENSOR 2*/
	/*SENSOR 3*/
	/*SENSOR 4*/
	/*SENSOR 5*/
	/*SENSOR 6*/
	/*...*/
	
	/*************************************************** SENSORES ***************************************************/
	
	assign hum_int_dht11   	= sensor_data[39:32];
	assign temp_int_dht11   = sensor_data[23:16];
	
	assign errorChecksum = (sensor_data[7:0] == sensor_data[15:8] + sensor_data[23:16] + sensor_data[31:24] + sensor_data[39:32]) ? 1'b0 : 1'b1;	

	localparam [2:0] ESPERA = 3'b000, LEITURA = 3'b001, ENVIO = 3'b010, STOP = 3'b011, LOOP = 3'b100;
	
	reg [2:0] current_state = ESPERA;
	
	always @(posedge clock)
		begin
			if (errorChecksum == 1'b1 || error == 1'b1)
				begin //Sensor com problema
					response_value_reg <= 8'h45; //E
					response_command_reg <= 8'h45; //E
				end
			else //Se não tiver erro
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
								if(dadosOK == 1'b0)
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
															current_state <= ENVIO;
														end
													8'h01: //Solicita a medida de temperatura atual
														begin
															response_value_reg <= temp_int_dht11;
															response_command_reg <= 8'h09; //Medida de temperatura
															current_state <= ENVIO;
														end
													8'h02: //Solicita a medida de umidade atual
														begin
															response_value_reg <= hum_int_dht11;
															response_command_reg <= 8'h08;//Medida de umidade
															current_state <= ENVIO;
														end
													8'h03: //Ativa sensoriamento contínuo de temperatura
														begin
															response_value_reg <= temp_int_dht11;
															response_command_reg <= 8'h0D;
															current_state <= ENVIO;
															in_loop <= 1'b1;
														end
													8'h04: //Ativa sensoriamento contínuo de umidade
														begin
															response_value_reg <= hum_int_dht11;
															response_command_reg <= 8'h0E;
															current_state <= ENVIO;
															in_loop <= 1'b1;
														end 
													8'h05: //Desativa sensoriamento contínuo de temperatura
														begin
															response_value_reg <= 8'h0A;
															response_command_reg <= 8'h0A;
															current_state <= ENVIO;
															in_loop <= 1'b0;
														end 
													8'h06: //Desativa sensoriamento contínuo de umidade
														begin
															response_value_reg <= 8'h0B;
															response_command_reg <= 8'h0B;
															current_state <= ENVIO;
															in_loop <= 1'b0;
														end 
													default:
														begin
															response_value_reg <= 8'h45; //E
															response_command_reg <= 8'h45; //E
															current_state <= ENVIO;
														end
												endcase
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