/* MÓDULO INTERFACE_SENSOR
   ESTE MÓDULO REPRESENTA TODA A BASE DE SINCRONIZAÇÃO COM O SENSOR DHT11 E A COLETA DOS DADOS RECEBIDOS POR ELE.
*/
module interface_sensor (

	input wire       	clk		 ,     // CLOCK DE 50 MHZ
	input wire	     	rst_n		 ,     // SINAL DE RESET
	inout	          	dat_io	 ,     // PINO DE ENTRADA E SAÍDA DE DADOS DO DHT11
	output reg [39:0]	data            // BARRAMENTO COM TODOS OS DADOS RECEBIDOS DO DHT11

);


	/* RECURSOS DE CONTROLE DO PINO INOUT DO DHT11 */
	reg        read_flag;     // DETERMINA A DIREÇÃO DO PINO INOUT DO SENSOR
	reg        dout;          // DADOS ENVIADOS PARA O SENSOR
	wire       din;           // DADOS RECEBIDOS DO SENSOR
	
	/* RECURSOS PARA REALIZAR A DIVISÃO DO CLOCK */
	reg       clk_1MHz;       // CLOCK DE 1 MHZ
	reg [5:0] cnt_clk;        // CONTADORA UTILIZADA PARA DIVIDIR O CLOCK DE 50 MHZ
	
	/* RECURSOS DE COLETA DOS BITS DE DADOS */
	reg [5:0]  data_cnt;       // CONTAGEM DE QUANTOS BITS FORAM LIDOS DO DHT11
	reg [39:0] data_buf;       // ARMAZENAMENTO DOS 40 BITS COLETADOS
	
	/* RECURSOS DE INICIALIZAÇÃO DA MÁQUINA E CRONOMETRAGEM DE TEMPO*/
	reg [15:0] cnt ;           // CONTADORA USADA PARA CRONOMETRAR O TEMPO NOS ESTADOS
	reg        en_1, en_2, en_rising;    // REGISTRADORAS UTILIZADAS PARA CRIAR UM SINAL DE ENABLE TEMPORÁRIO UTILIZANDO O RESET

	
	/* DECLARAÇÃO DA MÁQUINA DE ESTADO */
	reg  [3:0] state;          // REGISTRADORA DO ESTADO DO CIRCUITO     
	 
	localparam IDLE             = 0;        // AGUARDO DO SINAL DE ENABLE
	localparam START_BIT        = 1;        // ENVIO DO START BIT PARA O DHT11
	localparam SEND_HIGH_20US   = 2;        // MANDA NÍVEL LÓGICO ALTO COMO ETAPA DE SINCRONIZAÇÃO
	localparam WAIT_LOW         = 3;        // ESPERA NÍVEL LÓGICO BAIXO COMO SINAL VINDO DO SENSOR
	localparam WAIT_HIGH        = 4;        // ESPERA NÍVEL LÓGICO ALTO COMO SINAL VINDO DO SENSOR
	localparam FINAL_SYNC       = 5;        // ESPERA NÍVEL LÓGICO BAIXO COMO SINAL VINDO DO SENSOR PARA FINALIZAR ETAPA DE SINCRONIZAÇÃO
	localparam WAIT_BIT_DATA    = 6;        // ESPERA NÍVEL LÓGICO ALTO QUE REPRESENTA O BIT DE DADO
	localparam READ_DATA        = 7;        // CONTA O TEMPO DO NÍVEL LÓGICO ALTO PARA IDENTIFICAR O BIT DE DADO RECEBIDO
	localparam COLLECT_ALL_DATA = 8;        // TRANSMITE TODOS OS BITS DE DADOS COLETADOS PARA A SAÍDA
	localparam END_PROCESS      = 9;        // FIM DA MÁQUINA DE ESTADO
	localparam ERROR            = 10;       // UM ERRO FOI IDENTIFICADO NO PROCESSO DE SINCRONIZAÇÃO OU LEITURA
	

	/* LÓGICA DE DIREÇÃO DO PINO INOUT DO DHT11 */
	assign dat_io = read_flag ? 1'bz : dout;       // SE "read_flag" FOR 0, O CIRCUITO MANDA O SINAL QUE DESEJA ENVIAR POR "dout"
																  // SE "read_flag" FOR 1, O SINAL 1 É ENVIADO PARA NÃO ATRAPALHAR O RECEBIMENTO DE DADOS
	assign din = dat_io;                           // "din"  RECEBE O VALOR QUE O DHT11 ESTÁ ENVIANDO

	
	/* DIVIDINDO O SINAL DE CLOCK DE 50 MHZ PARA 1 MHZ */
	always @(posedge clk) begin

		if (cnt_clk == 6'd50) begin
	
			cnt_clk = 0;
			clk_1MHz = 1'b1;

		end
		else begin
			
			cnt_clk = cnt_clk + 1'b1;
			clk_1MHz = 1'b0;
		
		end
	
	end

	/* LÓGICA DO SINAL ALTO DO ENABLE, QUE É CRIADO TEMPORARIAMENTE A PARTIR DO RESET.
		ISSO FOI FEITO PARA A MÁQUINA NÃO INICIALIZAR UMA SEGUNDA VEZ QUANDO VOLTA AO IDLE SEM SER RESETADA*/
	always @ ( posedge clk_1MHz, negedge rst_n) begin
	
		if ( !rst_n) begin
		
			en_1 <= 1'b0;
			en_2 <= 1'b0;
			en_rising <= 1'b0;
			
		end
		
		else begin
		
			en_1 <= rst_n;
			en_2 <= en_1;
			en_rising <= en_1 & (~en_2);   // SINAL USADO PARA SAIR DO ESTADO DE IDLE DA MÁQUINA
			
		end
		
	end

	/* PROCESSO DA MÁQUINA DE ESTADOS */
	always @ ( posedge clk_1MHz, negedge rst_n) begin
	
		/* RESETANDO RECURSOS */
		if ( rst_n == 1'b0) begin
		
			read_flag <= 1'b1;
			state <= IDLE;
			dout <= 1'b1;
			data_buf <= 40'd0;
			cnt <= 16'd0;
			data_cnt <= 6'd0;
			data<=40'd0;
			
		end
		
		else begin
		
			case (state)
			
				/* PREPARANDO PARA INICIAR O PROCESSO DE SINCRONIZAÇÃO COM O SENSOR */
				IDLE : begin        
					 
					   if ( en_rising && din == 1'b1) begin      // O ENABLE DEVE ESTAR ATIVO E A DIREÇÃO DO PINO INOUT NORMALIZADA
						
							state <= START_BIT;          // PASSA PARA O ESTADO DE INÍCIO DA SINCRONIZAÇÃO
							read_flag <= 1'b0;           // SETA DIREÇÃO DO PINO DO SENSOR PARA: FPGA -> DHT11
							dout <= 1'b0;                // COMEÇANDO O ENVIO DO START BIT
							cnt <= 16'd0;
							data_cnt <= 6'd0;
							
						end
						
						else begin
						
							read_flag <= 1'b1;
							dout <= 1'b1;
							cnt <= 16'd0;
							
						end	
						
					end
				
				/* ENVIA O START PARA O SENSOR POR 19 MS */
				START_BIT : begin      
				
						if ( cnt >= 16'd19000) begin      // ATINGIU O TEMPO DE 19 MS
						
							state <= SEND_HIGH_20US;     // PASSA PARA O PRÓXIMO ESTADO
							dout <= 1'b1;                // ENVIA NÍVEL LÓGICO ALTO PARA O SENSOR COMO PRÓXIMO PASSO DA SINCRONIZAÇÃO
							cnt <= 16'd0;
							
						end
						
						else begin
						
							cnt<= cnt + 1'b1;
							
						end
						
					end
				
				/* ENVIA NÍVEL LÓGICO ALTO POR 20 US PARA DEPOIS ESPERAR A RESPOSTA DO SENSOR */
				SEND_HIGH_20US : begin           
				
						if ( cnt >= 16'd20)begin          // ATINGIU O TEMPO DE 20 US
						
							cnt <= 16'd0;
							read_flag <= 1'b1;      // SETA DIREÇÃO DO PINO DO SENSOR PARA: DHT11 -> FPGA
							state <= WAIT_LOW;      // PASSA PARA O PRÓXIMO ESTADO
							
						end
						
						else begin
						
							cnt <= cnt + 1'b1;
							
						end
						
					end
				
				/* É ESPERADO QUE O SENSOR ENVIE NÍVEL LÓGICO BAIXO ANTES DE ATINGIR O TEMPO LIMITE */
				WAIT_LOW:begin            
				
						if ( din == 1'b0) begin       // FOI RECEBIDO NÍVEL LÓGICO BAIXO DO SENSOR
						
							state <= WAIT_HIGH;        // PASSA PARA O PRÓXIMO ESTADO
							cnt <= 16'd0;
							
						end
						
						else begin
						
							cnt <= cnt + 1'b1;
							
							if ( cnt >= 16'd65500) begin        // ATINGIU O TEMPO LIMITE DE 65 US E O SENSOR NÃO RESPONDEU
							
								state <= ERROR;       // PASSA PARA O ESTADO DE ERRO
								cnt <= 16'd0;
								read_flag <= 1'b1;
								
							end	
							
						end
						
					end
				
				/* É ESPERADO QUE O SENSOR ENVIE NÍVEL LÓGICO ALTO ANTES DE ATINGIR O TEMPO LIMITE */
				WAIT_HIGH: begin           
				
						if ( din == 1'b1) begin        // FOI RECEBIDO NÍVEL LÓGICO ALTO DO SENSOR
						
							state <= FINAL_SYNC;        // PASSA PARA O PRÓXIMO ESTADO
							cnt <= 16'd0;
							data_cnt <= 6'd0;
							
						end
						
						else begin
						
							cnt <= cnt + 1'b1;
							
							if ( cnt >= 16'd65500) begin       // ATINGIU O TEMPO LIMITE DE 65 US E O SENSOR NÃO RESPONDEU
							
								state <= ERROR;       // PASSA PARA O ESTADO DE ERRO
								cnt <= 16'd0;
								read_flag <= 1'b1;
								
							end
							
						end
						
					end
				
				/* ÚLTIMA ETAPA DE SINCRONIZAÇÃO. É ESPERADO QUE O SENSOR ENVIE NÍVEL LÓGICO BAIXO ANTES DE ATINGIR O TEMPO LIMITE */
				FINAL_SYNC : begin          
				
						if ( din == 1'b0) begin         // FOI RECEBIDO NÍVEL LÓGICO BAIXO DO SENSOR      
						
							state <= WAIT_BIT_DATA;      // PASSA PARA O PRÓXIMO ESTADO
							cnt <= cnt + 1'b1;
							
						end
						
						else begin
						
							cnt <= cnt + 1'b1;
							 
							if ( cnt >= 16'd65500) begin       // ATINGIU O TEMPO LIMITE DE 65 US E O SENSOR NÃO RESPONDEU
							
								state <= ERROR;      // PASSA PARA O ESTADO DE ERRO
								cnt <= 16'd0;
								read_flag <= 1'b1;
								
							end			
							
						end
						
					end
				
				/* O SENSOR DEVE ENVIAR NÍVEL LÓGICO ALTO, QUE REPRESENTA UM DOS BITS DE DADOS, ANTES DO TEMPO LIMITE */
				WAIT_BIT_DATA:begin            
				
						if ( din == 1'b1) begin        // FOI RECEBIDO NÍVEL LÓGICO ALTO DO SENSOR, COMEÇANDO ENVIO DO BIT DE DADO  
						
							state <= READ_DATA;         // PASSA PARA O PRÓXIMO ESTADO
							cnt <= 16'd0;
							
						end
						
						else begin
						
							cnt <= cnt + 1'b1;
							
							if ( cnt >= 16'd65500) begin       // ATINGIU O TEMPO LIMITE DE 65 US E O SENSOR NÃO RESPONDEU
							
								state <= ERROR;      // PASSA PARA O ESTADO DE ERRO
								cnt <= 16'd0;
								read_flag <= 1'b1;
								
							end	
							
						end
						
					end
				
				/* CRONOMETRA O TEMPO EM NÍVEL LÓGICO ALTO PARA DETERMINAR QUAL O BIT ENVIADO PELO SENSOR */
				READ_DATA : begin
				
						if ( din == 1'b0) begin        // TERMINOU O ENVIO DO BIT DE DADO      
						
							data_cnt <= data_cnt + 1'b1;               // CONTABILIZANDO QUANTOS BITS JÁ FORAM LIDOS
							
							// SE TODOS OS BITS JÁ FORAM LIDOS, VAI PARA O ESTADO DE ENVIO DOS 40 BITS PARA A SAÍDA, SENÃO, CONTINUA LENDO O RESTO
							state <= (data_cnt >= 6'd39) ? COLLECT_ALL_DATA : WAIT_BIT_DATA;    
							                                                                    
							cnt <= 16'd0;
							
							if ( cnt >= 16'd60) begin        // SE O TEMPO EM NÍVEL LÓGICO ALTO FOR MAIOR QUE 60 US, FOI ENVIADO O BIT 1
							
								data_buf <= { data_buf[39:0], 1'b1};       // INSERÇÃO DO BIT DE DADO POR DESLOCAMENTO DE BIT
								
							end
							
							else begin                       // SE O TEMPO EM NÍVEL LÓGICO ALTO FOR MENOR QUE 60 US, FOI ENVIADO O BIT 0
							
								data_buf <= { data_buf[39:0], 1'b0};       // INSERÇÃO DO BIT DE DADO POR DESLOCAMENTO DE BIT
								
							end
							
						end
						
						else begin         // CONTABILIZANDO O TEMPO EM NÍVEL LÓGICO ALTO
						
							cnt <= cnt + 1'b1;
							
							if ( cnt >= 16'd65500) begin       // ATINGIU O TEMPO LIMITE DE 65 US E NÃO TERMINOU DE MANDAR O BIT DE DADO
							
								state <= ERROR;         // PASSA PARA O ESTADO DE ERRO
								cnt <= 16'd0;
								read_flag <= 1'b1;
								
							end	
							
						end
						
					end
				
				/* TRANSMITE TODOS OS DADOS LIDOS PARA A SAÍDA */
				COLLECT_ALL_DATA : begin

						data <= data_buf;      // A SAÍDA RECEBE OS 40 BITS LIDOS
						
						if ( din == 1'b1) begin       // INDICA QUE O PINO INOUT DO SENSOR ESTÁ NORMALIZADO
						
							state <= END_PROCESS;      // PASSA PARA O PRÓXIMO ESTADO
							cnt <= 16'd0;
							
						end
						
						else begin            // CONTAGEM PARA O PINO INOUT DO SENSOR SE NORMALIZAR
						
							cnt <= cnt + 1'b1;
							
							if ( cnt >= 16'd65500) begin     // ATINGIU O TEMPO LIMITE DE 65 US E NÃO NORMALIZOU
							
								state <= IDLE;         // PASSA PARA O ESTADO INICIAL
								cnt <= 16'd0;
								read_flag <= 1'b1;
								
							end
							
						end
						
					end
					
				/* FIM DE TODO O PROGRESSO DA MÁQUINA DE ESTADOS */
				END_PROCESS : begin
				
						state <= IDLE;        // PASSA PARA O ESTADO INICIAL
						cnt <= 16'd0;
						
					end
				
				/* OCORREU UM ERRO NA SINCRONIZAÇÃO COM O SENSOR OU NA COLETA DOS BITS DE DADOS */
				ERROR: begin
				
						// TODOS OS BITS DA SAÍDA, QUE INDICA OS DADOS DO SENSOR, SÃO COLOCADOS EM 1 PARA INDICAR QUE OCORREU UM ERRO
						data <= 40'b1111111111111111111111111111111111111111;   
						
						if ( din == 1'b1) begin      // INDICA QUE O PINO INOUT DO SENSOR ESTÁ NORMALIZADO
						 
							state <= END_PROCESS;        // PASSA PARA O PRÓXIMO ESTADO
							cnt <= 16'd0;
							
						end
						
						else begin             // CONTAGEM PARA O PINO INOUT DO SENSOR SE NORMALIZAR
						
							cnt <= cnt + 1'b1;
							
							if ( cnt >= 16'd65500) begin      // ATINGIU O TEMPO LIMITE DE 65 US E NÃO NORMALIZOU
							
								state <= IDLE;         // PASSA PARA O ESTADO INICIAL
								cnt <= 16'd0;
								read_flag <= 1'b1;
								
							end	
							
						end
						
				   end
				
				/* INDICANDO ESTADO PADRÃO */
				default : begin
				
						state <= IDLE;
						cnt <= 16'd0;
						
					end	
					
			endcase
			
		end		
		
	end

	
endmodule