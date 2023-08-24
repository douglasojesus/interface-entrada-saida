//////////////////////////////////////////////////////////////////////
// File Downloaded from http://www.nandland.com
// Adapted by Douglas Oliveira de Jesus.
//////////////////////////////////////////////////////////////////////
// This file contains the UART Receiver.  This receiver is able to
// receive 8 bits of serial data, one start bit, one stop bit,
// and no parity bit.  When receive is complete o_rx_dv will be
// driven high for one clock cycle.
// 
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 10 MHz Clock, 115200 baud UART
// (10000000)/(115200) = 87


/*
*i_Clock: Sinal de clock de entrada para sincronização.
*i_Rx_Serial: Sinal serial de entrada que carrega os dados a serem recebidos.
*o_Rx_DV: Sinal de saída que indica que os dados foram recebidos e estão disponíveis.
*o_Rx_Byte: Saída de 8 bits que contém os dados recebidos.
*/
  
module uart_rx 
  #(parameter CLKS_PER_BIT)
  (
   input        i_Clock,
   input        i_Rx_Serial,
   output       o_Rx_DV,
   output [7:0] o_Rx_Byte
   );
	
	/*Definição dos estados da máquina de estados.*/
  localparam s_IDLE         = 3'b000; //Estado de espera inicial. Aguardando a detecção de um bit de início.
  localparam s_RX_START_BIT = 3'b001; //Estado que verifica se o bit de início ainda está baixo. 
  localparam s_RX_DATA_BITS = 3'b010; //Estado que espera para amostrar os bits de dados durante os próximos CLKS_PER_BIT - 1 ciclos de clock. 
  localparam s_RX_STOP_BIT  = 3'b011; //Estado que espera a conclusão do bit de parada (stop bit), que é logicamente alto. 
  localparam s_CLEANUP      = 3'b100; //Após a recepção bem-sucedida de um byte completo, as ações de limpeza são realizadas
   
	/*Dois registros são definidos para armazenar o sinal serial de entrada. 
	*r_Rx_Data_R armazena o valor atual do sinal serial (registrado na borda de subida do clock), 
	*enquanto r_Rx_Data armazena o valor anterior (registrado na borda anterior do clock). 
	*Isso ajuda a lidar com problemas de metastabilidade.
	*/
  reg           r_Rx_Data_R = 1'b1;
  reg           r_Rx_Data   = 1'b1;
   
	/*r_Clock_Count: Contador de ciclos de clock usado para sincronização e temporização.
	*r_Bit_Index: Índice que rastreia a posição do bit atual dentro do byte recebido.
	*r_Rx_Byte: Registrador que armazena os bits de dados recebidos, formando um byte completo.
	*r_Rx_DV: Sinal que indica quando os dados foram recebidos e estão disponíveis para leitura.
	*r_SM_Main: Registrador que mantém o estado atual da máquina de estados.
	*/
	
  reg [7:0]     r_Clock_Count = 0;
  reg [2:0]     r_Bit_Index   = 0; //8 bits total
  reg [7:0]     r_Rx_Byte     = 0;
  reg           r_Rx_DV       = 0;
  reg [2:0]     r_SM_Main     = 0;
   
  /*Este bloco always é sensível à borda de subida do clock i_Clock. 
  *Ele atualiza os registros r_Rx_Data_R e r_Rx_Data com o valor atual do sinal serial na borda de subida do clock. 
  *Isso ajuda a remover problemas de metastabilidade.
  */
  always @(posedge i_Clock)
    begin
      r_Rx_Data_R <= i_Rx_Serial;
      r_Rx_Data   <= r_Rx_Data_R;
    end
   
	/*Este bloco always é sensível à borda de subida do clock i_Clock e controla a máquina de estados. 
	*Dependendo do estado atual (r_SM_Main), diferentes ações são tomadas para lidar com a recepção dos dados.
	*Cada caso dentro do case corresponde a um estado específico.
	*/
   
  always @(posedge i_Clock)
    begin
       
      case (r_SM_Main)
		/*s_IDLE: Neste estado, o módulo está ocioso e aguardando a detecção de um bit de início (start bit). 
		*Se um bit de início for detectado, a máquina de estados transita para o estado s_RX_START_BIT, 
		*caso contrário, permanece em s_IDLE.
		*/
        s_IDLE :
          begin
            r_Rx_DV       <= 1'b0;
            r_Clock_Count <= 0;
            r_Bit_Index   <= 0;
             
            if (r_Rx_Data == 1'b0)          // Bit start detectado
              r_SM_Main <= s_RX_START_BIT;
            else
              r_SM_Main <= s_IDLE;
          end
         
        /*s_RX_START_BIT: Este estado verifica se o bit de início ainda está baixo (indicando a primeira metade do bit de início). 
		  Quando a metade do bit de início é detectada, a máquina de estados verifica se o bit de início ainda está baixo. 
		  Se sim, a máquina de estados transita para o estado s_RX_DATA_BITS.
		  */
        s_RX_START_BIT :
          begin
            if (r_Clock_Count == (CLKS_PER_BIT-1)/2)
              begin
                if (r_Rx_Data == 1'b0)
                  begin
                    r_Clock_Count <= 0;  // reset counter, found the middle
                    r_SM_Main     <= s_RX_DATA_BITS;
                  end
                else
                  r_SM_Main <= s_IDLE;
              end
            else
              begin
                r_Clock_Count <= r_Clock_Count + 1'b1;
                r_SM_Main     <= s_RX_START_BIT;
              end
          end // case: s_RX_START_BIT
         
         
        /*s_RX_DATA_BITS: Neste estado, o módulo aguarda para amostrar os bits de dados nos próximos CLKS_PER_BIT - 1 ciclos de clock. 
		  *Uma vez que os 8 bits de dados são amostrados, a máquina de estados transita para o estado s_RX_STOP_BIT.
		  */
        s_RX_DATA_BITS :
          begin
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1'b1;
                r_SM_Main     <= s_RX_DATA_BITS;
              end
            else
              begin
                r_Clock_Count          <= 0;
                r_Rx_Byte[r_Bit_Index] <= r_Rx_Data;
                 
                // Check if we have received all bits
                if (r_Bit_Index < 7)
                  begin
                    r_Bit_Index <= r_Bit_Index + 1'b1;
                    r_SM_Main   <= s_RX_DATA_BITS;
                  end
                else
                  begin
                    r_Bit_Index <= 0;
                    r_SM_Main   <= s_RX_STOP_BIT;
                  end
              end
          end // case: s_RX_DATA_BITS
     
     
        /*s_RX_STOP_BIT: Neste estado, o módulo aguarda a conclusão do bit de parada (stop bit), que é logicamente alto. 
		  *Após a espera, o sinal o_Rx_DV é ativado e a máquina de estados transita para o estado s_CLEANUP.
		  */

			 s_RX_STOP_BIT :
          begin
            // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_RX_STOP_BIT;
              end
            else
              begin
                r_Rx_DV       <= 1'b1;
                r_Clock_Count <= 0;
                r_SM_Main     <= s_CLEANUP;
              end
          end // case: s_RX_STOP_BIT
     
         
        /*s_CLEANUP: Neste estado, após a recepção bem-sucedida de um byte completo, as ações de limpeza são realizadas. 
		  *O sinal o_Rx_DV é ativado por um ciclo de clock, indicando que os dados estão prontos para serem lidos. 
		  *Em seguida, a máquina de estados retorna ao estado s_IDLE, e o sinal o_Rx_DV é desativado.
		  */
        s_CLEANUP :
          begin
            r_SM_Main <= s_IDLE;
            r_Rx_DV   <= 1'b0;
          end
         
         
        default :
          r_SM_Main <= s_IDLE;
         
      endcase
    end   
   
  assign o_Rx_DV   = r_Rx_DV;
  assign o_Rx_Byte = r_Rx_Byte;
   
endmodule