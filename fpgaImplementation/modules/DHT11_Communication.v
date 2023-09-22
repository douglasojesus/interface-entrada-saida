/*
* Módulo para testar a comunicação com o DHT11.
* Retirado de: https://www.kancloud.cn/dlover/fpga/1637659
* Adaptado por Douglas Oliveira de Jesus.
*/

module DHT11_Communication (
	input wire       	clock_1M, //1 MHz
	input wire	     	enable_sensor,
	inout	          	dht11,
	output reg [39:0]	dados_sensor,
	output 				erro,
	output 				done
);

	reg        	direcao_dado;     // Direção do sinal do inout
	reg        	dados_enviados_sensor;	
	reg [5:0]  	contador_dados;
	reg [39:0] 	dados_bruto; 
	reg [15:0] 	contador; 
	reg        	start_f1, start_f2, start_rising;
	reg  [3:0] 	estado_atual;  
	reg 			erro_na_maquina;
	reg 			done_reg;

	wire       	dado_do_sensor;   
	wire			erro_checksum;
	wire			enable_address;
	 
	localparam 	ESPERA             		= 0,
					BIT_DE_INICIO        	= 1,
					ENVIA_SINAL_A_20US  		= 2, //ENVIA_SINAL_ALTO_20US
					ESPERA_SINAL_B    		= 3, //Espera sinal baixo
					ESPERA_SINAL_A     		= 4, //Espera sinal alto
					FIM_SYNC     				= 5, //Fim da sicronização
					WAIT_1_BIT_DHT11  		= 6, //Aguarda um bit do sensor
					LE_DADOS        			= 7, //Lê os dados
					COLETA_DADOS 				= 8, //Coleta os dados
					ACABA_PROCESSO      		= 9; //Finaliza todo o processo
	
	// Tristate
	assign dht11 = direcao_dado ? 1'bz : dados_enviados_sensor;
	
	assign dado_do_sensor = dht11;
	
	assign erro = erro_na_maquina;
	
	assign done = done_reg;
	
	always @ (posedge clock_1M, negedge enable_sensor) 
		begin
			if (!enable_sensor) 
				begin
					start_f1 <= 1'b0;
					start_f2 <= 1'b0;
					start_rising <= 1'b0;
				end
		
			else 
				begin
					start_f1 <= enable_sensor;
					start_f2 <= start_f1;
					start_rising <= start_f1 & (~start_f2);
				end
		end

	//FSM
	always @ (posedge clock_1M, negedge enable_sensor) 
		begin
			if (enable_sensor == 1'b0) 
				begin
					direcao_dado <= 1'b1;
					estado_atual <= ESPERA;
					dados_enviados_sensor <= 1'b1;
					dados_bruto <= 40'd0;
					dados_sensor <= 40'd0;
					contador <= 16'd0;
					contador_dados <= 6'd0;
					erro_na_maquina <= 0;
					done_reg <= 1'b0;
				end
			else 
				begin
					case (estado_atual)
						ESPERA: 
							begin
								if (start_rising && dado_do_sensor == 1'b1) 
									begin
										estado_atual <= BIT_DE_INICIO;
										direcao_dado <= 1'b0;
										dados_enviados_sensor <= 1'b0;
										contador <= 16'd0;
										contador_dados <= 6'd0;
									end
								else 
									begin
										direcao_dado <= 1'b1;
										dados_enviados_sensor <= 1'b1;
										contador <= 16'd0;
									end	
							end

						BIT_DE_INICIO :  //19Ms
							begin      
								if (contador >= 16'd19000) 
									begin
										estado_atual <= ENVIA_SINAL_A_20US;
										dados_enviados_sensor <= 1'b1;
										contador <= 16'd0;
									end
								else 
									begin
										contador<= contador + 1'b1;
									end
							end
						
						ENVIA_SINAL_A_20US : 
							begin           
								if (contador >= 16'd20)
									begin
										contador <= 16'd0;
										direcao_dado <= 1'b1;
										estado_atual <= ESPERA_SINAL_B;
									end
								else 
									begin
										contador <= contador + 1'b1;
									end
							end
						
						ESPERA_SINAL_B:
							begin            
								if (dado_do_sensor == 1'b0) 
									begin
										estado_atual <= ESPERA_SINAL_A;
										contador <= 16'd0;
									end
								else 
									begin
										contador <= contador + 1'b1;
										if (contador >= 16'd65500) //tempo limite de espera - sem respostas do sensor
											begin
												estado_atual <= ACABA_PROCESSO;
												erro_na_maquina <= 1'b1;
												contador <= 16'd0;
												direcao_dado <= 1'b1;
											end	
									end
							end
						
						ESPERA_SINAL_A: 
							begin           
								if (dado_do_sensor == 1'b1) 
									begin
										estado_atual <= FIM_SYNC;
										contador <= 16'd0;
										contador_dados <= 6'd0;
									end
								else 
									begin
										contador <= contador + 1'b1;
										if (contador >= 16'd65500) 
											begin
												estado_atual <= ACABA_PROCESSO;
												erro_na_maquina <= 1'b1;
												contador <= 16'd0;
												direcao_dado <= 1'b1;
											end
									
									end
								
							end
						
						FIM_SYNC : 
							begin 
								if (dado_do_sensor == 1'b0) 
									begin           
										estado_atual <= WAIT_1_BIT_DHT11;
										contador <= contador + 1'b1;
									end
								else 
									begin
										contador <= contador + 1'b1;
										if (contador >= 16'd65500) 
											begin
												estado_atual <= ACABA_PROCESSO;
												erro_na_maquina <= 1'b1;
												contador <= 16'd0;
												direcao_dado <= 1'b1;
											end
									end
							end

						WAIT_1_BIT_DHT11:
							begin            
								if ( dado_do_sensor == 1'b1) 
									begin
										estado_atual <= LE_DADOS;
										contador <= 16'd0;
									end
								else 
									begin
										contador <= contador + 1'b1;
										if ( contador >= 16'd65500) 
											begin
												estado_atual <= ACABA_PROCESSO;
												erro_na_maquina <= 1'b1;
												contador <= 16'd0;
												direcao_dado <= 1'b1;
											end	
									end	
							end

						LE_DADOS: 
							begin
								if (dado_do_sensor == 1'b0) 
									begin     
										contador_dados <= contador_dados + 1'b1; 
										estado_atual <= (contador_dados >= 6'd39) ? COLETA_DADOS : WAIT_1_BIT_DHT11;
										contador <= 16'd0;
										if (contador >= 16'd60) 
											begin     
												dados_bruto <= {dados_bruto[39:0], 1'b1}; // Lê '1'
											end
										else 
											begin 
												dados_bruto <= {dados_bruto[39:0], 1'b0}; // Lê '0'
											end
									end
								else 
									begin 
										contador <= contador + 1'b1;
										if (contador >= 16'd65500) 
											begin       
												estado_atual <= ACABA_PROCESSO;
												erro_na_maquina <= 1'b1;
												contador <= 16'd0;
												direcao_dado <= 1'b1;
											end	
									end
							end
						
						COLETA_DADOS: 
							begin
								dados_sensor <= dados_bruto;
								if (dado_do_sensor == 1'b1) 
									begin
										estado_atual <= ACABA_PROCESSO;
										contador <= 16'd0;
									end
								else 
									begin
										contador <= contador + 1'b1;
										if (contador >= 16'd65500) 
											begin
												estado_atual <= ESPERA;
												contador <= 16'd0;
												direcao_dado <= 1'b1;
											end
									end
							end
							
						ACABA_PROCESSO:
							begin
								if (erro_na_maquina == 1'b1)
									begin
										estado_atual <= ACABA_PROCESSO;
										contador <= contador + 1'b1;
										if (contador >= 16'd65500) //Período para WAITr normalização da máquina
											begin
												estado_atual <= ESPERA;
												contador <= 16'd0;
												direcao_dado <= 1'b1;
												done_reg <= 1'b1;
											end
									end
								else 
									begin
										done_reg <= 1'b1;
										estado_atual <= ESPERA;
										contador <= 16'd0;
									end
							end

						default: 
							begin
								estado_atual <= ESPERA;
								contador <= 16'd0;
							end	
							
					endcase
				end		
		end
endmodule