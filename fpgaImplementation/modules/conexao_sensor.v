module conexao_sensor(
	input clock,
	input enable,
	input [7:0] request_command,
	input [7:0] request_address,
	inout transmission_line,
	output dadosPodemSerEnviados,
	output [7:0] response_command,
	output [7:0] response_value
);

	wire [7:0] hum_int_dht11, hum_float_dht11, temp_int_dht11, temp_float_dht11;
	wire error, errorChecksum, hold;
	wire dadosOK;
	
	reg [7:0] value_data, command_data;
		
	reg enable_sensor, reset_sensor, dadosPodemSerEnviados_reg;
	reg [7:0] response_command_reg, response_value_reg;
	

	DHT11_communication TROCA_DADOS_DHT11(clock, enable_sensor, request_address, 8'b00000001, reset_sensor, 
	transmission_line, hum_int_dht11, hum_float_dht11, temp_int_dht11, temp_float_dht11, errorChecksum, hold, error, dadosOK);
	
	//Preciso pegar o resultado de um dos módulos e repassar para a saída
	
	//SENSOR 2
	
	//SENSOR 3
	
	//SENSOR 4
	
	localparam [2:0] ESPERA = 3'b000, LEITURA = 3'b001, ENVIO = 3'b010, STOP = 3'b011, LOOP = 3'b100;
	
	reg [2:0] current_state = ESPERA;
	
	always @(posedge clock)
		begin
			if (errorChecksum == 1'b1 || error == 1'b1)
				begin //Sensor com problema
					value_data <= 8'h1F;
					command_data <= 8'h1F;
				end
			else //Se não tiver erro
				begin
					case (current_state)
						ESPERA:
							begin
								if (hold == 1'b1 || enable == 1'b0)
									begin
										current_state <= ESPERA;
										enable_sensor <= 1'b1;
										reset_sensor  <= 1'b0;
									end
								else  //Quando o sensor parar de enviar os dados e o enable estiver ativado
									begin
										current_state <= LEITURA;
										enable_sensor <= 1'b1;
										reset_sensor  <= 1'b0;
									end
							end
						LEITURA:
							begin
								if(hold == 1'b1 || dadosOK == 1'b0)
									begin
										current_state <= ESPERA;
									end
								else 
									begin
										case (request_command)
											8'h00: //Solicita a situação atual do sensor
												begin
													if (dadosOK == 1'b1 && errorChecksum == 1'b0)
														begin
															value_data <= 8'h07; //Sensor funcionando normalmente
															command_data <= 8'h07;
														end
													
													else
														begin
															value_data <= 8'h1F; //Sensor com problema
															command_data <= 8'h1F;
														end
													current_state <= ENVIO;
												end
											8'h01: //Solicita a medida de temperatura atual
												begin
													value_data <= temp_int_dht11;
													command_data <= 8'h09; //Medida de temperatura
													current_state <= ENVIO;
												end
											8'h02: //Solicita a medida de umidade atual
												begin
													value_data <= hum_int_dht11;
													command_data <= 8'h08;//Medida de umidade
													current_state <= ENVIO;
												end
											8'h03: //Ativa sensoriamento contínuo de temperatura
												begin
													current_state <= LOOP;
												end
											8'h04: //Ativa sensoriamento contínuo de umidade
												begin
													current_state <= LOOP;
												end 
											8'h05: //Comando inválido pois o sensoriamento contínuo não foi ativado
												begin
													value_data <= 8'hAA;
													command_data <= 8'hAA;
													current_state <= ENVIO;
												end 
											8'h06: //Comando inválido pois o sensoriamento contínuo não foi ativado
												begin
													value_data <= 8'hAA;
													command_data <= 8'hAA;
													current_state <= ENVIO;
												end 
											/*8'h10: //Envia solicitação para requisição (start)
												begin
													value_data <= 
													command_data <=
												end */
											default:
												begin
													value_data <= 8'h0F;
													command_data <= 8'h0F;
													current_state <= ENVIO;
												end
										endcase
									end
							end
						ENVIO:
							begin
								response_value_reg <= value_data;
								response_command_reg <= command_data;
								dadosPodemSerEnviados_reg <= 1'b1;
								current_state <= STOP;
							end
						STOP:
							begin
								current_state <= ESPERA;
								dadosPodemSerEnviados_reg <= 1'b0;
								enable_sensor <= 1'b0;
								reset_sensor <= 1'b1;
							end
						LOOP:
							begin
								if (request_command == 8'h05 || request_command == 8'h06) //Desativar sensoriamento contínuo
									begin
										current_state <= STOP;
									end
								else 
									begin //Continua sensoriamente contínuo
										if (request_command == 8'h03) //Ativa sensoriamento contínuo de temperatura
											begin
												response_value_reg <= temp_int_dht11;
												response_command_reg <= 8'h09; //Medida de temperatura
											end
										else 
											begin
												if (request_command == 8'h04) //Ativa sensoriamento contínuo de umidade
													begin
														response_value_reg <= hum_int_dht11;
														response_command_reg <= 8'h08;//Medida de umidade
													end
												else 
													begin //Comando inválido devido a ativação do sensoriamento contínuo. Precisa desativar.
														response_value_reg <= 8'hFF;
														response_command_reg <= 8'hFF;
													end
											end
										current_state <= LOOP;
									end
							end
						default: //Algum erro na máquina de estados
							begin
								value_data <= 8'hAB;
								command_data <= 8'hAB;
							end
					endcase	
				end				
		end
		
	assign dadosPodemSerEnviados = dadosPodemSerEnviados_reg;
	assign response_command = response_command_reg;
	assign response_value = response_value_reg;
	
endmodule