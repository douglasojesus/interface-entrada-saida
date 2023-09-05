module DHT11Communication (
	input clock,
	input [7:0] enable,
	input reset,
	inout transmission_line,
	output [7:0] hum_int,
	output [7:0] hum_float,
	output [7:0] temp_int,
	output [7:0] temp_float,
	output [7:0] checksum,
	output hold,  // Sinaliza que a comunicação está acontecendo e aguardando retorno do DHT11.
	output error,  // Sinaliza que houve problema em algum estado.
	output dadosPodemSerEnviados
);

	reg [39:0] sensor_data;
	reg [25:0] counter;
	reg [5:0] index;
	reg debug;
	reg sensor_out, direction;
	
	wire sensor_in;
	
	reg hold_reg, debug_reg, error_reg, dadosPodemSerEnviados_reg;
	
	assign hold = hold_reg;
	assign error = error_reg;
	assign dadosPodemSerEnviados = dadosPodemSerEnviados_reg;	

	TriState TS0 (transmission_line, direction, sensor_out, sensor_in);

	assign hum_int    = sensor_data[7:0];
	assign hum_float  = sensor_data[15:8];
	assign temp_int   = sensor_data[23:16];
	assign temp_float = sensor_data[31:24];
	assign checksum   = sensor_data[39:32];
	
	/*localparam [3:0] 	S0 = 4'b0001, S1 = 4'b0010, S2 = 4'b0011,
							S3 = 4'b0100, S4 = 4'b0101, S5 = 4'b0110,
							S6 = 4'b0111, S7 = 4'b1000, S8 = 4'b1001,
							S9 = 4'b1010, START = 4'b1011, STOP = 4'b0000;*/
	
	parameter S0=1, S1=2, S2=3, S3=4, S4=5, S5=6, S6=7, S7=8, S8=9, S9=10, STOP=0, START=11;

	reg [3:0] current_state;

	always @(posedge clock) 
		begin : FSM
			if (enable == 8'b00000001)
				begin
					if (reset == 1'b1) 
						begin
							hold_reg <= 1'b0;
							error_reg <= 1'b0;
							direction <= 1'b1;
							sensor_out <= 1'b1;
							counter <= 26'b000000000000000000000000000;
							sensor_data <= 40'b0000000000000000000000000000000000000000;
							dadosPodemSerEnviados_reg <= 1'b0;
							current_state <= START;
						end 
					else 
						begin
							case (current_state)
							/*Esta é a primeira máquina de estado, que é ativada quando o sinal reset é acionado. 
							Quando isso acontece, os registros internos são inicializados, as flags de controle são 
							configuradas e a máquina de estado é definida como S0. É o estado de início.*/
								START: 
									begin
										hold_reg <= 1'b1;
										direction <= 1'b1;
										sensor_out <= 1'b1;
										current_state <= S0;
									end
							/*Nesta máquina de estado, a comunicação com o sensor DHT11 começa. O sinal hold_reg é 
							ativado, indicando que a comunicação está em andamento. O sinal direction e sensor_out 
							são definidos para transmitir dados para o sensor. O contador counter é usado para 
							temporização e, quando atinge 18ms, a máquina de estado passa para S1.*/
								S0: 
									begin
										hold_reg <= 1'b1;
										error_reg <= 1'b0;
										direction <= 1'b1;
										sensor_out <= 1'b1;
										if (counter < 900_000) 
											begin
												counter <= counter + 1'b1;
											end 
										else 
											begin
												current_state <= S1;
												counter <= 26'b000000000000000000000000000;
											end
									end
							/*Neste estado, a máquina de estado continua a comunicação com o sensor DHT11. 
							O sinal sensor_out é alterado para um estado diferente, e o contador counter continua 
							a contar. Quando o contador atinge 18ms, a máquina de estado avança para S2.*/
								S1: 
									begin
										hold_reg <= 1'b1;
										sensor_out <= 1'b0;

										if (counter < 900_000) 
											begin
											  counter <= counter + 1'b1;
											end 
										else 
											begin
												current_state <= S2;
												counter <= 26'b000000000000000000000000000;
											end
									end
							/*Aqui, o sinal sensor_out é ajustado novamente, e o contador counter é usado para
							temporização. Quando o contador atinge 20 uS (resposta do DHT ocorre entre 20 e 40 uS), 
							a máquina de estado passa para S3.*/
								S2: 
									begin
										sensor_out <= 1'b1;
										if (counter < 1_000) 
											begin
												counter <= counter + 1'b1;
											end 
										else
											begin
												current_state <= S3;
												direction <= 1'b0;
											end
									end
							/*Nesta etapa, a máquina de estado espera por uma resposta do sensor DHT11, que é indicada 
							pelo sinal sensor_in. Ela também conta o tempo usando o contador counter. Se o sensor 
							responder e o contador não atingir seu limite, a máquina de estado permanece em S3. 
							Caso contrário, se o sensor responder e o contador atingir o limite, a máquina de estado 
							avança para STOP. Se o sensor não responder, a máquina de estado passa para S4.*/
								S3: 
									begin
										if (sensor_in == 1'b1 && counter < 3_000) //60 (88) uS / 0,02uS = 2000 CICLOS DE 50MHZ
											begin
												current_state <= S3;
												counter <= counter + 1'b1;
											end
										else 
											begin
												if (sensor_in == 1'b1) //Se ultrapassa o limite de 40uS -- erro de inicializacao do DHT11
													begin
														current_state <= STOP;
														error_reg <= 1'b1;
														counter <= 26'b000000000000000000000000000;
													end 
												else 
													begin
														current_state <= S4;
														counter <= 26'b000000000000000000000000000;
													end
											end
									end
							/*Neste estado, a máquina de estado espera pela resposta do sensor, que é indicada pelo sinal sensor_in. 
							O contador counter é usado para temporização. Se o sensor responder e o contador não atingir seu limite, 
							a máquina de estado permanece em S4. Se o sensor não responder e o contador atingir o limite, a máquina 
							de estado avança para STOP.*/
								S4: 
									begin
										if (sensor_in == 1'b0 && counter < 4_400) 
											begin
											  current_state <= S4;
											  counter <= counter + 1'b1;
											end
										else 
											begin
												if (sensor_in == 1'b0) 
													begin
														current_state <= STOP;
														error_reg <= 1'b1;
														counter <= 26'b000000000000000000000000000;
													end
												else 
													begin
														current_state <= S5;
														counter <= 26'b000000000000000000000000000;
													end
											end
									end
							/*Semelhante a S4, esta máquina de estado espera pela resposta do sensor e monitora o contador counter. 
							Se o sensor responder e o contador não atingir seu limite, a máquina de estado permanece em S5. Se o 
							sensor responder e o contador atingir o limite, o estado atual vai para stop. Se o 
							sensor não responder e o contador atingir o limite, a máquina de estado avança para S6. */
								S5: 
									begin
										if (sensor_in == 1'b1 && counter < 4_400) 
											begin
												current_state <= S5;
												counter <= counter + 1'b1;
											end
										else 
											begin
												if (sensor_in == 1'b1) 
													begin
														current_state <= STOP;
														error_reg <= 1'b1;
														counter <= 26'b000000000000000000000000000;
													end 
												else 
													begin
														current_state <= S6;
														error_reg <= 1'b1;
														index <= 6'b000000;
														counter <= 26'b000000000000000000000000000;
													end
											end
									end
							/*Neste estado, se o sensor não responder, a MEF avança para S7. Caso responda, vai para STOP com erro.*/
								S6: 
									begin
										if (sensor_in == 1'b0) 
											begin
												current_state <= S7;
											end 
										else 
											begin
												current_state <= STOP;
												error_reg <= 1'b1;
												counter <= 26'b000000000000000000000000000;
											end
									end
							/*Aqui, a máquina de estado aguarda uma resposta do sensor, indicada pelo sinal sensor_in. 
							Se o sensor responder, a máquina de estado passa para S8. Se o sensor não responder e o 
							contador atingir 60uS, a máquina de estado avança para STOP.*/
								S7: 
									begin
										if (sensor_in == 1'b1) 
											begin
												current_state <= S8;
												counter <= 26'b000000000000000000000000000;
											end 
										else 
											begin
												if (counter < 1_600_000) 
													begin
														current_state <= S7;
														counter <= counter + 1'b1;
													end 
												else 
													begin
														current_state <= STOP;
														error_reg <= 1'b1;
														counter <= 26'b000000000000000000000000000;
													end
											end
									end
							/*Neste estado, a máquina de estado lida com a recepção de dados do sensor DHT11. Ela verifica
							o valor recebido e os armazena no register sensor_data em resposta às condições observadas. 
							O índice index é atualizado na S9 para rastrear a posição dos bits recebidos. Quando todos os bits são 
							recebidos, o índice chega em 39 e a máquina avança para stop, com os dados carregados.*/
								S8: 
									begin
										if (sensor_in == 1'b0) 
											begin
												//start to transmit 1 bit data
												if (counter > 2_500) // t(ms)/0,00002(s) = 2500 ciclos -> t = 0,05ms = 50us
													begin
														debug_reg <= 1'b1;
														sensor_data[index] <= 1'b1;
													end 
												else 
													begin
														debug_reg <= 1'b0;
														sensor_data[index] <= 1'b0;
													end

												if (index < 39) 
													begin
														current_state <= S9;
														counter <= 26'b000000000000000000000000000;
													end 
												else 
													begin
														current_state <= STOP;
														error_reg <= 1'b0;
													end
											end 
										else 
											begin
												counter <= counter + 1'b1;
												if (counter == 1_600_000) 
													begin
														current_state <= STOP;
														error_reg <= 1'b1;
													end
											end
									end
							/*Esta máquina de estado simplesmente move-se de volta para S6, preparando-se para 
							uma nova leitura ou reinicialização e iterando o índice.*/
								S9: 
									begin
										current_state <= S6;
										index <= index + 1'b1;
									end
							/*A máquina de estado STOP é alcançada no final do ciclo de comunicação com o sensor. 
							Se não houver erros (error_reg é zero), a flag dadosPodemSerEnviados_reg é ativada, 
							indicando que os dados podem ser enviados. Se houver um erro, a flag de erro error_reg 
							é configurada. A máquina de estado aguarda um tempo antes de reiniciar a próxima comunicação 
							ou aguarda uma nova solicitação.*/
								STOP: 
									begin
										current_state <= STOP;
										if (error_reg == 1'b0) 
											begin
												hold_reg <= 1'b0;
												error_reg <= 1'b0;
												dadosPodemSerEnviados_reg <= 1'b1;
												direction <= 1'b1;
												sensor_out <= 1'b1;
												index <= 6'b000000;
												counter <= 26'b000000000000000000000000000;
											end 
										else 
											begin
												if (counter < 1_600_000) //Se houver erro, espera o DHT11 finalizar.
													begin
														hold_reg <= 1'b1;
														error_reg <= 1'b1;
														dadosPodemSerEnviados_reg <= 1'b1; 
														direction <= 1'b0;
														counter <= counter + 1'b1;
														sensor_data <= 40'b0000000000000000000000000000000000000000;
													end 
												else 
													begin
														error_reg <= 1'b0;
													end
											end
									end
							endcase
						end
				end
		end

endmodule