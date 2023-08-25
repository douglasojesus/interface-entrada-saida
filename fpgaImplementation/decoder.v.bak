module decoder(
    input [7:0] word, //Para 1 byte
	 //input [15:0] doubleWord, //Para 2 bytes
    output reg [6:0] display
);

    always @(*) begin
        case (word)
            8'b00110001: display <= 7'b0110000; //Caractere 1 exibe 1 no display.
				8'b01010000: display <= 7'b1100111; //Caractere P exibe P no display.
            default: display <= 7'b0000000; // Valor padrão se nenhum caso coincidir.
        endcase
		  //case (doubleWord)
		//		16'b0011000100110001: display <= 7'b1011011; //Caractere 11 exibe S no display.
			//	default: display <= 7'b0000000; // Valor padrão se nenhum caso coincidir.
			//endcase
    end

endmodule
