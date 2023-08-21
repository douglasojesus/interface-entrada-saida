module FPGAImplementation(
	input        i_Clock,
  input        i_Reset,          // Exemplo de sinal de reset
  input        i_Tx_Data_Valid,  // Exemplo de sinal de dados válidos para transmitir
  input [7:0]  i_Tx_Data,        // Exemplo de dados a serem transmitidos
  output       o_Rx_Data_Valid,  // Exemplo de sinal de dados válidos recebidos
  output [7:0] o_Rx_Data          // Exemplo de dados recebidos
);
	parameter CLKS_PER_BIT = 87;
	
	uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) uart_tx_inst (
      .i_Clock(i_Clock),
      .i_Tx_DV(i_Tx_DV),
      .i_Tx_Byte(i_Tx_Byte),
      .o_Tx_Active(o_Tx_Active),
      .o_Tx_Serial(o_Tx_Serial),
      .o_Tx_Done(o_Tx_Done)
	);
	
	uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) uart_rx_inst (
      .i_Clock(i_Clock),
      .i_Rx_Serial(i_Rx_Serial), 
      .o_Rx_DV(o_Rx_DV),         
      .o_Rx_Byte(o_Rx_Byte)      
    );

endmodule