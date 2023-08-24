module FPGAImplementation(
	input        i_Clock, //Clock do sistema.
  input        i_Tx_DV,  //Inicia a transmissão.
  input [7:0]  i_Tx_Byte,  //Entrada de byte para transmitir para o PC. O código envia bit a bit.
	output 		o_Tx_Serial, //Bit que é enviado via serial.
	output      o_Tx_Done,	//Bit de Stop.
	output 		o_Tx_Active, //Informa que está em transição.
  output       o_Rx_DV, //Inicia a recepção.
  output [7:0] o_Rx_Byte, //Byte recebido.        
	output wire [6:0] display2, //Display usado de exemplo
	input 		i_Rx_Serial //Bit que é enviado via serial.
);
	parameter CLKS_PER_BIT = 5209;
	wire [6:0] dir;

	
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
	
    decoder inst (
        .word(o_Rx_Byte),
        .display(display2)
    );

endmodule