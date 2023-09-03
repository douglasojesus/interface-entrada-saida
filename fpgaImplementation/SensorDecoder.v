module DHT11Communication (
	input clock,
	input enable,
	input reset,
	inout transmission_line,
	output [7:0] hum_int,
	output [7:0] hum_float,
	output [7:0] temp_int,
	output [7:0] temp_float,
	output reg hold,  // Sinaliza que a comunicação está acontecendo e aguardando retorno do DHT11.
	output reg error,  // Sinaliza que houve problema em algum estado.
	output reg dadosPodemSerEnviados
);

	reg [39:0] sensor_data;
	reg [25:0] counter;
	reg [5:0] index;
	reg debug;
	reg sensor_out, direction;
	
	wire sensor_in;
	wire [7:0] checksum;

	TriState TS0 (transmission_line, direction, sensor_out, sensor_in);

	assign hum_int    = sensor_data[7:0];
	assign hum_float  = sensor_data[15:8];
	assign temp_int   = sensor_data[23:16];
	assign temp_float = sensor_data[31:24];
	assign checksum   = sensor_data[39:32];
	
	localparam [3:0] 	S0 = 4'b0001, S1 = 4'b0010, S2 = 4'b0011,
							S3 = 4'b0100, S4 = 4'b0101, S5 = 4'b0110,
							S6 = 4'b0111, S7 = 4'b1000, S8 = 4'b1001,
							S9 = 4'b1010, START = 4'b1011, STOP = 4'b0000;

	reg [3:0] current_state;

	always @(posedge clock) 
		begin : FSM
			if (reset == 1'b1) 
				begin
					hold <= 1'b0;
					error <= 1'b0;
					direction <= 1'b1;
					sensor_out <= 1'b1;
					counter <= 26'b000000000000000000000000000;
					sensor_data <= 40'b0000000000000000000000000000000000000000;
					current_state <= START;
				end 
			else 
				begin
					case (current_state)
						START: 
							begin
								hold <= 1'b1;
								direction <= 1'b1;
								sensor_out <= 1'b1;
								dadosPodemSerEnviados <= 1'b0;
								current_state <= S0;
							end
						S0: 
							begin
								hold <= 1'b1;
								error <= 1'b0;
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
						S1: 
							begin
								hold <= 1'b1;
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
						S3: 
							begin
								if (sensor_in == 1'b1 && counter < 3_000) 
									begin
										current_state <= S3;
										counter <= counter + 1'b1;
									end
								else 
									begin
										if (sensor_in == 1'b1)
											begin
												current_state <= STOP;
												error <= 1'b1;
												counter <= 26'b000000000000000000000000000;
											end 
										else 
											begin
												current_state <= S4;
												counter <= 26'b000000000000000000000000000;
											end
									end
							end
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
												error <= 1'b1;
												counter <= 26'b000000000000000000000000000;
											end
										else 
											begin
												current_state <= S5;
												counter <= 26'b000000000000000000000000000;
											end
									end
							end
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
												error <= 1'b1;
												counter <= 26'b000000000000000000000000000;
											end 
										else 
											begin
												current_state <= S6;
												error <= 1'b1;
												index <= 6'b000000;
												counter <= 26'b000000000000000000000000000;
											end
									end
							end
						S6: 
							begin
								if (sensor_in == 1'b0) 
									begin
										current_state <= S7;
									end 
								else 
									begin
										current_state <= STOP;
										error <= 1'b1;
										counter <= 26'b000000000000000000000000000;
									end
							end
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
												error <= 1'b1;
												counter <= 26'b000000000000000000000000000;
											end
									end
							end
						S8: 
							begin
								if (sensor_in == 1'b0) 
									begin
										if (counter > 2_500) 
											begin
												debug <= 1'b1;
												sensor_data[index] <= 1'b1;
											end 
										else 
											begin
												debug <= 1'b0;
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
												error <= 1'b0;
											end
									end 
								else 
									begin
										counter <= counter + 1'b1;
										if (counter == 1_600_000) 
											begin
												current_state <= STOP;
												error <= 1'b1;
											end
									end
							end
						S9: 
							begin
								current_state <= S6;
								index <= index + 1'b1;
							end
						STOP: 
							begin
								current_state <= STOP;
								if (error == 1'b0) 
									begin
										hold <= 1'b0;
										error <= 1'b0;
										dadosPodemSerEnviados <= 1'b1;
										direction <= 1'b1;
										sensor_out <= 1'b1;
										index <= 6'b000000;
										counter <= 26'b000000000000000000000000000;
									end 
								else 
									begin
										if (counter < 1_600_000) //Por que a escolha do 1600000 ao invés de 3200000? Perguntar a Gerson.
											begin
												hold <= 1'b1;
												error <= 1'b1;
												dadosPodemSerEnviados <= 1'b0; 
												direction <= 1'b0;
												counter <= counter + 1'b1;
												sensor_data <= 40'b0000000000000000000000000000000000000000;
											end 
										else 
											begin
												error <= 1'b0;
											end
									end
							end
					endcase
				end
		end

endmodule