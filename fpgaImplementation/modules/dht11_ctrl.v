//https://doc.embedfire.com/fpga/altera/ep4ce10_pro/zh/latest/code/dht11.html

module dht11_ctrl(sys_clk, sys_rst_n, key_flag, dht11, data_out, sign);

	input wire sys_clk; 
	input wire sys_rst_n; 
	input wire key_flag; 
	inout wire dht11;
	output reg [19:0] data_out;
	output reg sign; 
	
	////
	//\* Parameter and Internal Signal \//
	////
	//parameter define
	parameter S_WAIT_1S = 3'd1 , //1s
	S_LOW_18MS = 3'd2 , //18ms
	S_DLY1 = 3'd3 , //20-40us
	S_REPLY = 3'd4 , //DHT11 80us
	S_DLY2 = 3'd5 , //80us
	S_RD_DATA = 3'd6 ; 
	parameter T_1S_DATA = 999999 ; //1s
	parameter T_18MS_DATA = 17999 ; //18ms
	
	//reg define
	reg clk_1us ; //1us
	reg [4:0] cnt ; 
	reg [2:0] state ; 
	reg [20:0] cnt_us ; //us
	reg dht11_out ; 
	reg dht11_en ; 
	reg [5:0] bit_cnt ; 
	reg [39:0] data_tmp ; 
	reg data_flag ; 
	reg dht11_d1 ; 
	reg dht11_d2 ; 
	reg [31:0] data ; 
	reg [6:0] cnt_low ;
	
	//wire define
	wire dht11_fall; 
	wire dht11_rise; 
	////
	//\* Main Code \//
	////
	//DATA_out
	assign dht11 = (dht11_en == 1 ) ? dht11_out : 1'bz;
	assign dht11_rise = (~dht11_d2) & (dht11_d1) ;
	assign dht11_fall = (dht11_d2) & (~dht11_d1) ;
	//dht11
	always@(posedge clk_1us or negedge sys_rst_n)
		if(sys_rst_n == 1'b0)
			begin
				dht11_d1 <= 1'b0 ;
				dht11_d2 <= 1'b0 ;
			end
		else
			begin
				dht11_d1 <= dht11 ;
				dht11_d2 <= dht11_d1 ;
			end
			
	//cnt
	always@(posedge sys_clk or negedge sys_rst_n)
		if(sys_rst_n == 1'b0)
			cnt <= 5'b0;
		else if(cnt == 5'd24)
			cnt <= 5'b0;
		else
			cnt <= cnt + 1'b1;
			
	//clk_1us
	always@(posedge sys_clk or negedge sys_rst_n)
		if(sys_rst_n == 1'b0)
			clk_1us <= 1'b0;
		else if(cnt == 5'd24)
			clk_1us <= ~clk_1us;
		else
			clk_1us <= clk_1us;
			
	//bit_cnt
	always@(posedge clk_1us or negedge sys_rst_n)
		if(sys_rst_n == 1'b0)
			bit_cnt <= 6'b0;
		else if(bit_cnt == 40 && dht11_rise == 1'b1)
			bit_cnt <= 6'b0;
		else if(dht11_fall == 1'b1 && state == S_RD_DATA)
			bit_cnt <= bit_cnt + 1'b1;
			
	//data_flag
	always@(posedge sys_clk or negedge sys_rst_n)
		if(sys_rst_n == 1'b0)
			data_flag <= 1'b0;
		else if(key_flag == 1'b1)
			data_flag <= ~data_flag;
		else
			data_flag <= data_flag;
	
	
	always@(posedge clk_1us or negedge sys_rst_n)
		if(sys_rst_n == 1'b0)
			state <= S_WAIT_1S ;
		else
			case(state)
				S_WAIT_1S:
					if(cnt_us == T_1S_DATA) //1s
						state <= S_LOW_18MS ;
					else
						state <= S_WAIT_1S ;
				S_LOW_18MS:
					if(cnt_us == T_18MS_DATA)
						state <= S_DLY1 ;
					else
						state <= S_LOW_18MS ;
				S_DLY1:
					if(cnt_us == 10) //10us
						state <= S_REPLY ;
					else
						state <= S_DLY1 ;
				S_REPLY: //70us
					if(dht11_rise == 1'b1 && cnt_low >= 70)
						state <= S_DLY2 ;
					//1ms dht11
					else if(cnt_us >= 1000)
						state <= S_LOW_18MS ;
					else
						state <= S_REPLY ;
				S_DLY2: //70us
					if(dht11_fall == 1'b1 && cnt_us >= 70)
						state <= S_RD_DATA ;
					else
						state <= S_DLY2 ;
				S_RD_DATA:
					if(bit_cnt == 40 && dht11_rise == 1'b1)
						state <= S_LOW_18MS ;
					else
						state <= S_RD_DATA ;
				default:
					state <= S_WAIT_1S ;
			endcase

	//cnt_us
	always@(posedge clk_1us or negedge sys_rst_n)
		if(sys_rst_n == 1'b0)
			begin
				cnt_low <= 7'd0 ;
				cnt_us <= 21'd0 ;
			end
		else
			case(state)
				S_WAIT_1S:
					if(cnt_us == T_1S_DATA)
						cnt_us <= 21'd0 ;
					else
						cnt_us <= cnt_us + 1'b1;
				S_LOW_18MS:
					if(cnt_us == T_18MS_DATA)
						cnt_us <= 21'd0 ;
					else
						cnt_us <= cnt_us + 1'b1;
				S_DLY1:
					if(cnt_us == 10)
						cnt_us <= 21'd0 ;
					else
						cnt_us <= cnt_us + 1'b1;
				S_REPLY:
					if(dht11_rise == 1'b1 && cnt_low >= 70)
						begin
							cnt_low <= 7'd0 ;
							cnt_us <= 21'd0 ;
						end
					//dht11
					else if(dht11 == 1'b0)
						begin
							cnt_low <= cnt_low + 1'b1 ;
							cnt_us <= cnt_us + 1'b1 ;
						end
					//1ms dht11
					else if(cnt_us >= 1000)
						begin
							cnt_low <= 7'd0 ;
							cnt_us <= 21'd0 ;
						end
					else
						begin
							cnt_low <= cnt_low ;
							cnt_us <= cnt_us + 1'b1 ;
						end
				S_DLY2:
					if(dht11_fall == 1'b1 && cnt_us >= 70)
						cnt_us <= 21'd0 ;
					else
						cnt_us <= cnt_us + 1'b1;
				S_RD_DATA:
					if(dht11_fall == 1'b1 || dht11_rise == 1'b1)
						cnt_us <= 21'd0 ;
					else
						cnt_us <= cnt_us + 1'b1;
				default:
					begin
						cnt_low <= 7'd0 ;
						cnt_us <= 21'd0 ;
					end
			endcase

	always@(posedge clk_1us or negedge sys_rst_n)
		if(sys_rst_n == 1'b0)
			begin
				dht11_out <= 1'b0 ;
				dht11_en <= 1'b0 ;
			end
		else
			case(state)
				S_WAIT_1S:
					begin
						dht11_out <= 1'b0 ;
						dht11_en <= 1'b0 ;
					end
				S_LOW_18MS: //18ms
					begin
						dht11_out <= 1'b0 ;
						dht11_en <= 1'b1 ;
					end
				//DHT11
				S_DLY1:
					begin
						dht11_out <= 1'b0 ;
						dht11_en <= 1'b0 ;
					end
				S_REPLY:
					begin
						dht11_out <= 1'b0 ;
						dht11_en <= 1'b0 ;
					end
				S_DLY2:
					begin
						dht11_out <= 1'b0 ;
						dht11_en <= 1'b0 ;
					end
				S_RD_DATA:
					begin
						dht11_out <= 1'b0 ;
						dht11_en <= 1'b0 ;
					end
				default:;
			endcase

	//data_tmp: data_tmp
	always@(posedge clk_1us or negedge sys_rst_n)
		if(sys_rst_n == 1'b0)
			data_tmp <= 40'b0;
		else if(state == S_RD_DATA && dht11_fall == 1'b1 && cnt_us<=50)
			data_tmp[39-bit_cnt] <= 1'b0;
		else if(state == S_RD_DATA && dht11_fall == 1'b1 && cnt_us>50)
			data_tmp[39-bit_cnt] <= 1'b1;
		else
			data_tmp <= data_tmp;

	//data_out
	always@(posedge clk_1us or negedge sys_rst_n)
		if(sys_rst_n == 1'b0)
			data <= 32'b0;
		else if(data_tmp[7:0] == data_tmp[39:32] + data_tmp[31:24] + data_tmp[23:16] + data_tmp[15:8])
			data <= data_tmp[39:8];
		else
			data <= data;

	//data_out
	always@(posedge clk_1us or negedge sys_rst_n)
		if(sys_rst_n == 1'b0)
			data_out <= 20'b0;
		else if(data_flag == 1'b0 )
			data_out <= data[31:24] * 10; //0
		else if(data_flag == 1'b1)
			data_out <= data[15:8] * 10 + data[3:0];

	//sign
	always@(posedge clk_1us or negedge sys_rst_n)
		if(sys_rst_n == 1'b0)
			sign <= 1'b0;
		else if(data[7] == 1'b1 && data_flag == 1'b1)
			sign <= 1'b1;
		else
			sign <= 1'b0;

endmodule