/*
* Módulo para testar a comunicação com o DHT11.
* Retirado de: https://blog.csdn.net/Ninquelote/article/details/105824323
*/

module DHT11_OtherImpl(clock, reset, dht11, dados_sensor, dadosOk);

	// Entradas e Saídas	
	input clock, reset;            // Sinais de clock e reset.
	inout dht11;                   // Interface bidirecional para o sensor DHT11.
	output reg dadosOk;            // Indica se os dados foram lidos com sucesso.
	output reg [31:0] dados_sensor; // Dados de temperatura e umidade.
	
	// Parâmetros para a máquina de estados
	parameter	POWER_ON_NUM 					= 1_000_000,
					ESTADO_ESPERA   				= 3'd0,
					ESTADO_WAIT_PERIODO_20MS	= 3'd1,
					ESTADO_WAIT_PULSO_13US		= 3'd2,
					ESTADO_WAIT_PERIODO_83US	= 3'd3,
					ESTADO_WAIT_PULSO_87US		= 3'd4,
					ESTADO_RECEBE_DADOS			= 3'd5,
					ESTADO_DELAY					= 3'd6;
	
	// Sinais internos
	reg [2:0] 	estado_atual; // Estados da máquina de estados
	reg [20:0] 	contador_1us; // Contador de microssegundos
	reg [5:0] 	contador_dados; // Contador de bits de dados
	reg [39:0] 	dados_bruto; // Dados brutos do sensor
	reg [4:0] 	contador_clock; // Contador para dividir o clock

	reg clock_1M, sinal_limpa_contador_us, estado, dht_buffer, dht_d0, dht_d1;
	
	wire dht_posedge, dht_negedge; // Detectores de borda de sinal DHT11
	
	// Atribuições
	assign dht11 			= dht_buffer;     // Conecta dht11 a dht_buffer
	assign dht_posedge 	= ~dht_d1 & dht_d0;  // Detecta borda de subida do sinal DHT11
	assign dht_negedge 	= dht_d1 & (~dht_d0);  // Detecta borda de descida do sinal DHT11
	
	// Contadores
	
	// Contador de clock com 1MHz		
	always @(posedge clock, negedge reset) 
		begin
			if (!reset)
				begin
					contador_clock <= 5'd0;
					clock_1M <= 1'b0;
				end
			else if (contador_clock == 6'd50) 
				begin
					contador_clock = 5'd0;
					clock_1M = ~clock_1M;
				end
			else 
				begin
					contador_clock = contador_clock + 1'b1;
					clock_1M = 1'b0;
				end
		end
	
	// Contador de 1 us
	always @ (posedge clock_1M, negedge reset) 
		begin
			if (!reset)
				contador_1us <= 21'd0;
			else if (sinal_limpa_contador_us)
				contador_1us <= 21'd0;
			else
				contador_1us <= contador_1us + 1'b1;
		end
	
	// Máquina de Estados
	always @ (posedge clock_1M, negedge reset) 
		begin
			if (reset == 1'b0)
				begin
					estado_atual <= ESTADO_ESPERA;
					dht_buffer <= 1'bz;
					estado <= 1'b0;
					sinal_limpa_contador_us <= 1'b0;
					dados_bruto <= 40'd0;
					contador_dados <= 6'd0;
				end
			else
				begin
					case (estado_atual)
						ESTADO_ESPERA: //wait
							begin
								if (contador_1us < POWER_ON_NUM)
									begin
										dht_buffer <= 1'bz;
										sinal_limpa_contador_us <= 1'b0;
									end
								else
									begin
										estado_atual <= ESTADO_WAIT_PERIODO_20MS;
										sinal_limpa_contador_us <= 1'b1;
									end
							end
							
						ESTADO_WAIT_PERIODO_20MS: // Espera por 20ms
							begin
								if(contador_1us < 20000)
									begin
										dht_buffer <= 1'b0;
										sinal_limpa_contador_us <= 1'b0;
									end
								else 
									begin
										estado_atual <= ESTADO_WAIT_PULSO_13US;
										dht_buffer <= 1'bz;
										sinal_limpa_contador_us <= 1'b1;
									end
							end
							
						ESTADO_WAIT_PULSO_13US: // Espera por pulso de 13us
							begin  
								if(contador_1us < 20)
									begin
										sinal_limpa_contador_us <= 1'b0;
											if(dht_negedge)
												begin
													estado_atual <= ESTADO_WAIT_PERIODO_83US;
													sinal_limpa_contador_us <= 1'b1;
												end
									end
								else
									estado_atual <= ESTADO_DELAY; // Aguarda até o próximo estado
							end
							
						ESTADO_WAIT_PERIODO_83US: // Espera por período de 83us
							begin
								if(dht_posedge)
									estado_atual <= ESTADO_WAIT_PULSO_87US;
							end
							
						ESTADO_WAIT_PULSO_87US: // Pronto para receber o sinal de dados
							begin
								if(dht_negedge)
									begin
										estado_atual <= ESTADO_RECEBE_DADOS;
										sinal_limpa_contador_us <= 1'b1;
									end
								else
									begin
										contador_dados <= 6'd0;
										dados_bruto <= 40'd0;
										estado <=1'b0;
									end
							end
							
						ESTADO_RECEBE_DADOS: // Recebe os 40 bits de dados
							begin
								case(estado)
									0: 
										begin
											if(dht_posedge)
												begin
													estado <= 1'b1;
													sinal_limpa_contador_us <= 1'b1;
												end
											else
												sinal_limpa_contador_us <= 1'b0;
										end

									1: 
										begin
											if(dht_negedge)
												begin
													contador_dados <= contador_dados + 1'b1;
													estado    <= 1'b0;
													sinal_limpa_contador_us <= 1'b1;
													if(contador_1us < 60)
														dados_bruto <= {dados_bruto[38:0],1'b1}; // Lê '0'
													else
														dados_bruto <= {dados_bruto[38:0],1'b1}; // Lê '1'
												end
											else // wait for high end
												sinal_limpa_contador_us <= 1'b0;
										end
								endcase

								if(contador_dados == 40) // Verifica os bits de dados
									begin
										estado_atual <= ESTADO_DELAY; //st_delay
										if(dados_bruto[7:0] == dados_bruto[39:32] + dados_bruto[31:24] + dados_bruto[23:16] + dados_bruto[15:8])
											begin
												dados_sensor <= dados_bruto[38:8];
												dadosOk <= 1'b1; // Define como válido se a soma de verificação coincidir
											end
										else
											dadosOk <= 1'b0;
									end
							end
							
						ESTADO_DELAY: // Aguarda 2 segundos após receber os dados
							begin
								if(contador_1us < 2000_000)
									sinal_limpa_contador_us <= 1'b0; //us_cnt_clr
								else
									begin
										estado_atual <= ESTADO_WAIT_PERIODO_20MS; // Envia sinal novamente
										sinal_limpa_contador_us <= 1'b0; //us_cnt_clr
									end
							end
						default:
							estado_atual <= estado_atual;
					endcase
				end
		end

	// Detectores de borda
	always @ (posedge clock_1M, negedge reset) 
		begin
			if (!reset) 
				begin
					dht_d0 <= 1'b1;
					dht_d1 <= 1'b1;
				end
			else 
				begin
					dht_d0 <= dht11;
					dht_d1 <= dht_d0;
				end
		end
		
endmodule