//////////////////////////////////////////////////////////////////////
// File Downloaded from http://www.nandland.com
// Adapted by Douglas Oliveira de Jesus.
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Este arquivo contém a implementação de um receptor UART. 
// Está configurado para receber 8 bits de dados seriais, um bit de start e um bit de stop. 
// Quando a recepção estiver completa, o sinal bitsEstaoRecebidos será colocado em nível alto por um ciclo de clock.
// Fonte: http://www.nandland.com ||| Adaptação feita por Douglas Oliveira de Jesus.
/////////////////////////////////////////////////////////////////////////////////////////////////////////

module uart_rx #(parameter CLKS_PER_BIT = 87)
  (
   input        clock, //Sinal de clock de entrada para sincronização.
   input        bitSerialAtual, //Sinal serial de entrada que carrega os dados a serem recebidos.
   output       bitsEstaoRecebidos, //Sinal de saída que indica que os dados foram recebidos e estão disponíveis.
   output [7:0] byteCompleto //Saída de 8 bits que contém os dados recebidos.
   );
	
	/*Definição dos estados da máquina de estados.*/
	localparam	estadoDeEspera         = 3'b000, //Estado de espera inicial. Aguardando a detecção de um bit de início.
					estadoVerificaBitInicio = 3'b001, //Estado que verifica se o bit de início ainda está baixo. 
					estadoDeEsperaBits = 3'b010, //Estado que espera para amostrar os bits de dados durante os próximos CLKS_PER_BIT - 1 ciclos de clock. 
					estadoStopBit  = 3'b011, //Estado que espera a conclusão do bit de parada (stop bit), que é logicamente alto. 
					estadoDeLimpeza      = 3'b100; //Após a recepção bem-sucedida de um byte completo, as ações de limpeza são realizadas
   
	/*Dois registros são definidos para armazenar o sinal serial de entrada. 
	*serialDeEntradaBuffer armazena o valor atual do sinal serial (registrado na borda de subida do clock), 
	*enquanto serialDeEntrada armazena o valor anterior (registrado na borda anterior do clock). 
	*Isso ajuda a lidar com problemas de metastabilidade.
	*/
	reg         serialDeEntradaBuffer = 1'b1;
	reg         serialDeEntrada   = 1'b1;
	
	reg [7:0]   contadorDeClock = 0; //Contador de ciclos de clock usado para sincronização e temporização.
	reg [2:0]   indiceDoBit   = 0; //Índice que rastreia a posição do bit atual dentro do byte recebido. 2³ possibilita a contagem até 8. 
	reg [7:0]   armazenaBits     = 0; //Registrador que armazena os bits de dados recebidos, formando um byte completo.
	reg         dadosOk       = 0; //Sinal que indica quando os dados foram recebidos e estão disponíveis para leitura.
	reg [2:0]   estadoAtual     = 0; //Registrador que mantém o estado atual da máquina de estados.
   
  /*Este bloco always é sensível à borda de subida do clock clock. 
  *Ele atualiza os registros serialDeEntradaBuffer e serialDeEntrada com o valor atual do sinal serial na borda de subida do clock. 
  *Isso ajuda a remover problemas de metastabilidade.
  */
  always @(posedge clock)
    begin
      serialDeEntradaBuffer <= bitSerialAtual;
      serialDeEntrada   <= serialDeEntradaBuffer;
    end
   
	/*Este bloco always é sensível à borda de subida do clock clock e controla a máquina de estados. 
	*Dependendo do estado atual (estadoAtual), diferentes ações são tomadas para lidar com a recepção dos dados.
	*Cada caso dentro do case corresponde a um estado específico.
	*/
   
  always @(posedge clock)
    begin
       
      case (estadoAtual)
		/*estadoDeEspera: Neste estado, o módulo está ocioso e aguardando a detecção de um bit de início (start bit). 
		*Se um bit de início for detectado, a máquina de estados transita para o estado estadoVerificaBitInicio, 
		*caso contrário, permanece em estadoDeEspera.
		*/
        estadoDeEspera :
          begin
            dadosOk       <= 1'b0;
            contadorDeClock <= 0;
            indiceDoBit   <= 0;
             
            if (serialDeEntrada == 1'b0)          // Bit start detectado
              estadoAtual <= estadoVerificaBitInicio;
            else
              estadoAtual <= estadoDeEspera;
          end
         
        /*estadoVerificaBitInicio: Este estado verifica se o bit de início ainda está baixo (indicando a primeira metade do bit de início). 
		  Quando a metade do bit de início é detectada, a máquina de estados verifica se o bit de início ainda está baixo. 
		  Se sim, a máquina de estados transita para o estado estadoDeEsperaBits.
		  */
        estadoVerificaBitInicio :
          begin
            if (contadorDeClock == (CLKS_PER_BIT-1)/2)
              begin
                if (serialDeEntrada == 1'b0)
                  begin
                    contadorDeClock <= 0;  // reset counter, found the middle
                    estadoAtual     <= estadoDeEsperaBits;
                  end
                else
                  estadoAtual <= estadoDeEspera;
              end
            else
              begin
                contadorDeClock <= contadorDeClock + 1'b1;
                estadoAtual     <= estadoVerificaBitInicio;
              end
          end // case: estadoVerificaBitInicio
         
         
        /*estadoDeEsperaBits: Neste estado, o módulo aguarda para amostrar os bits de dados nos próximos CLKS_PER_BIT - 1 ciclos de clock. 
		  *Uma vez que os 8 bits de dados são amostrados, a máquina de estados transita para o estado estadoStopBit.
		  */
        estadoDeEsperaBits :
          begin
            if (contadorDeClock < CLKS_PER_BIT-1)
              begin
                contadorDeClock <= contadorDeClock + 1'b1;
                estadoAtual     <= estadoDeEsperaBits;
              end
            else
              begin
                contadorDeClock          <= 0;
                armazenaBits[indiceDoBit] <= serialDeEntrada;
                 
                // Check if we have received all bits
                if (indiceDoBit < 7)
                  begin
                    indiceDoBit <= indiceDoBit + 1'b1;
                    estadoAtual   <= estadoDeEsperaBits;
                  end
                else
                  begin
                    indiceDoBit <= 0;
                    estadoAtual   <= estadoStopBit;
                  end
              end
          end // case: estadoDeEsperaBits
     
     
        /*estadoStopBit: Neste estado, o módulo aguarda a conclusão do bit de parada (stop bit), que é logicamente alto. 
		  *Após a espera, o sinal bitsEstaoRecebidos é ativado e a máquina de estados transita para o estado estadoDeLimpeza.
		  */

			 estadoStopBit :
          begin
            // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
            if (contadorDeClock < CLKS_PER_BIT-1)
              begin
                contadorDeClock <= contadorDeClock + 1;
                estadoAtual     <= estadoStopBit;
              end
            else
              begin
                dadosOk       <= 1'b1;
                contadorDeClock <= 0;
                estadoAtual     <= estadoDeLimpeza;
              end
          end // case: estadoStopBit
     
         
        /*estadoDeLimpeza: Neste estado, após a recepção bem-sucedida de um byte completo, as ações de limpeza são realizadas. 
		  *O sinal bitsEstaoRecebidos é ativado por um ciclo de clock, indicando que os dados estão prontos para serem lidos. 
		  *Em seguida, a máquina de estados retorna ao estado estadoDeEspera, e o sinal bitsEstaoRecebidos é desativado.
		  */
        estadoDeLimpeza :
          begin
            estadoAtual <= estadoDeEspera;
            dadosOk   <= 1'b0;
          end
         
         
        default :
          estadoAtual <= estadoDeEspera;
         
      endcase
    end   
   
  assign bitsEstaoRecebidos   = dadosOk;
  assign byteCompleto = armazenaBits;
   
endmodule