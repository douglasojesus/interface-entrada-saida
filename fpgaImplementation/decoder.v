module decoder(
    input [7:0] primeroByte,
	 input [7:0] segundoByte,
    output reg [6:0] display
);

    always @(*) 
		begin
        case (segundoByte)
            8'b00110001: display <= 7'b0110000; //Caractere 1 exibe 1 no display.
				8'b01010000: display <= 7'b1100111; //Caractere P exibe P no display.
            default: display <= 7'b0000000; // Valor padrão se nenhum caso coincidir.
        endcase
		end

endmodule
