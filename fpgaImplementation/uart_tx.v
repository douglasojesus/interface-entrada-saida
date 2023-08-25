/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Este arquivo contém a implementação de um transmissor UART. 
// Está configurado para transmitir 8 bits de dados seriais, um bit de start e um bit de stop. 
// Quando a transmissão estiver completa, o sinal bitsEstaoEnviados será colocado em nível alto por um ciclo de clock.
// Fonte: http://www.nandland.com ||| Adaptação feita por Douglas Oliveira de Jesus.
/////////////////////////////////////////////////////////////////////////////////////////////////////////

module uart_tx #(parameter CLOKS_POR_BIT = 87)
  (
   input       clock, //Sinal de clock de entrada para sincronização.
   input       haDadosParaTransmitir, //Um sinal de dados válido que indica quando há dados para serem transmitidos.
   input [7:0] byteASerTransmitido, //Entrada de 8 bits que contém os dados totais recebidos.
   output      indicaTransmissao, //Indica se a transmissão está ativa.
   output reg  bitSerialAtual, //O sinal serial que é transmitido.
   output      bitsEstaoEnviados //Sinal de saída que indica que os dados foram enviados.
   );
  
	localparam	estadoDeEspera			= 3'b000,
					estadoEnviaBitInicio = 3'b001,
					estadoEnviaBits		= 3'b010,
					estadoEnviaBitFinal  = 3'b011,
					estadoDeLimpeza      = 3'b100;
   
	reg [2:0]   estadoAtual					= 0;
	reg [7:0]   contadorDeClock			= 0;
	reg [2:0]   indiceDoBitTransmitido  = 0;
	reg [7:0]   dadosASeremTransmitidos = 0;
	reg         transmissaoConcluida    = 0;
	reg         transmissaoEmAndamento  = 0;
     
	always @(posedge clock)
		begin
			case (estadoAtual)
				estadoDeEspera :
					begin
						bitSerialAtual   <= 1'b1;         // Drive Line High for Idle
						transmissaoConcluida     <= 1'b0;
						contadorDeClock <= 0;
						indiceDoBitTransmitido   <= 0;
						if (haDadosParaTransmitir == 1'b1)
							begin
								transmissaoEmAndamento <= 1'b1;
								dadosASeremTransmitidos   <= byteASerTransmitido;
								estadoAtual   <= estadoEnviaBitInicio;
							end
						else
						estadoAtual <= estadoDeEspera;
					end // case: estadoDeEspera
		
        // Send out Start Bit. Start bit = 0
				estadoEnviaBitInicio :
					begin
						bitSerialAtual <= 1'b0;
						// Wait CLOKS_POR_BIT-1 clock cycles for start bit to finish
						if (contadorDeClock < CLOKS_POR_BIT-1)
							begin
								contadorDeClock <= contadorDeClock + 1;
								estadoAtual     <= estadoEnviaBitInicio;
							end
						else
							begin
								contadorDeClock <= 0;
								estadoAtual     <= estadoEnviaBits;
							end
					end // case: estadoEnviaBitInicio
		
        // Wait CLOKS_POR_BIT-1 clock cycles for data bits to finish         
				estadoEnviaBits :
					begin
						bitSerialAtual <= dadosASeremTransmitidos[indiceDoBitTransmitido];

						if (contadorDeClock < CLOKS_POR_BIT-1)
							begin
								contadorDeClock <= contadorDeClock + 1;
								estadoAtual     <= estadoEnviaBits;
							end
						else
							begin
								contadorDeClock <= 0;
								// Check if we have sent out all bits
								if (indiceDoBitTransmitido < 7)
									begin
										indiceDoBitTransmitido <= indiceDoBitTransmitido + 1;
										estadoAtual   <= estadoEnviaBits;
									end
								else
									begin
										indiceDoBitTransmitido <= 0;
										estadoAtual   <= estadoEnviaBitFinal;
									end
							end
					end // case: estadoEnviaBits

        // Send out Stop bit.  Stop bit = 1
				estadoEnviaBitFinal :
					begin
						bitSerialAtual <= 1'b1;
						// Wait CLOKS_POR_BIT-1 clock cycles for Stop bit to finish
						if (contadorDeClock < CLOKS_POR_BIT-1)
							begin
								contadorDeClock <= contadorDeClock + 1;
								estadoAtual     <= estadoEnviaBitFinal;
							end
						else
							begin
								transmissaoConcluida     <= 1'b1;
								contadorDeClock <= 0;
								estadoAtual     <= estadoDeLimpeza;
								transmissaoEmAndamento   <= 1'b0;
							end
					end // case: estadoEnviaBitFinal

        // Stay here 1 clock
				estadoDeLimpeza :
					begin
						transmissaoConcluida <= 1'b1;
						estadoAtual <= estadoDeEspera;
					end

				default :
					estadoAtual <= estadoDeEspera;
         
			endcase
		end
 
	assign indicaTransmissao = transmissaoEmAndamento;
	assign bitsEstaoEnviados   = transmissaoConcluida;
   
endmodule