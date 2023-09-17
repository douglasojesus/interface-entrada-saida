module divisor_de_clock(clock_SYS, clock_1MHZ);

	input clock_SYS;
	output reg clock_1MHZ;
	
	reg [5:0] contador_clock;
	
	//clock 5MHz to 1MHz
	always @ (posedge clock_SYS) 
		begin
			if (contador_clock < 6'd50)
				begin
					contador_clock <= contador_clock + 1'b1;
					clock_1MHZ = 1'b0;
				end
			else 
				begin
					contador_clock <= 6'd0;
					clock_1MHZ <= ~clock_1MHZ;
				end
		end

endmodule