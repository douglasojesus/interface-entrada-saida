/*
	description : dht11 control
*/
module dht11_control(
	input	sys_clk		,	//system clock
	input	sys_rst_n	,	//system reset negedge

	inout	dht11_data	,	//dht11 inout port

	output	reg	[39:0]	t_h_data
);

//---------state code
parameter	WAIT			=	6'b000_001,//wait state 2s
			START			=	6'b000_010,//make bus low 20ms
			WAIT_RES		=	6'b000_100,//wait respond
			RES_LOW			=	6'b001_000,//respond low
			RES_HIGH		=	6'b010_000,//respong high
			REC_DATA		=	6'b100_000;//receive datas
//---------time parameter
//parameter	CNT_2S_MAX		=	100	,
//			CNT_20MS_MAX	=	1_0	,
//			CNT_1US_MAX		=	50	;
parameter	CNT_2S_MAX		=	100_000_000	,
			CNT_20MS_MAX	=	1_000_000	,
			CNT_1US_MAX		=	50			;
//---------state define
reg	[5:0] 	state_cur;//current state
reg [5:0] 	state_nex;//next state
//---------flag define
wire		end_2s		;	//wait 2s end
wire		end_20ms    ;	//wait 20ms end
wire		res_ok      ;	//respond ok
wire		res_no      ;	//no respond
wire		end_res_low ;	//wait respond low end 83us
wire		end_res_high;	//wait respond high end 87us
wire		end_rec     ;	//data receive end 40bits
//---------dht11_data regist
reg			dht11_data_r1;
reg			dht11_data_r2;
wire		dht11_posedge;
wire		dht11_negedge;
reg			data;
reg			output_en;
wire		check;			//the datas is correct or wrong ?
reg	[39:0]	t_h_data_temp;//temperature and huminity data
//---------counter define
reg	[26:0]	cnt_2s;
reg [19:0]	cnt_20ms;
reg	[6:0]	cnt_nus;
reg	[5:0]	cnt_1us;
reg			cnt_us_rst;
reg	[5:0]	cnt_bit;
//---------flag assignments
assign	end_2s 			= (state_cur == WAIT && cnt_2s == CNT_2S_MAX - 1'b1) ? 1'b1 : 1'b0;
assign	end_20ms 		= (state_cur == START && cnt_20ms == CNT_20MS_MAX - 1'b1) ? 1'b1 : 1'b0;
assign	res_ok 			= (state_cur == WAIT_RES && cnt_nus < 20 && dht11_negedge) ? 1'b1 : 1'b0;
assign 	res_no 			= (state_cur == WAIT_RES && cnt_nus > 20) ? 1'b1 : 1'b0;
assign 	end_res_low 	= (state_cur == RES_LOW && cnt_nus > 70 && dht11_posedge) ? 1'b1 : 1'b0;
assign 	end_res_high 	= (state_cur == RES_HIGH && cnt_nus > 70 && dht11_negedge) ? 1'b1 : 1'b0;
assign	end_rec 		= (state_cur == REC_DATA && cnt_bit >= 40) ? 1'b1 : 1'b0;
//---------dht11 assignments
assign dht11_posedge = dht11_data_r1 & ~dht11_data_r2;
assign dht11_negedge = ~dht11_data_r1 & dht11_data_r2;
assign dht11_data = output_en ? data : 1'bz;
assign check = (t_h_data_temp[39:32]+t_h_data_temp[31:24]+
					t_h_data_temp[23:16]+t_h_data_temp[15:8] == t_h_data_temp[7:0])
					? 1'b1 : 1'b0;//the datas is correct or wrong ?
//*********posedge and negedge detect
always@(posedge sys_clk or negedge sys_rst_n)begin
	if(~sys_rst_n)begin
		dht11_data_r1 <= 1'b0;
		dht11_data_r2 <= 1'b0;
	end
	else begin
		dht11_data_r1 <= dht11_data;
		dht11_data_r2 <= dht11_data_r1;
	end
end
//*********counter
always@(*)begin
	case(state_cur)
		WAIT		:	cnt_us_rst = 1'b1;
	    START		:	cnt_us_rst = 1'b1;
	    WAIT_RES	:	begin
			if(res_ok)
				cnt_us_rst = 1'b1;
			else
				cnt_us_rst = 1'b0;
		end
	    RES_LOW		:	begin
			if(end_res_low)
				cnt_us_rst = 1'b1;
			else
				cnt_us_rst = 1'b0;
		end
	    RES_HIGH	:	begin
			if(end_res_high)
				cnt_us_rst = 1'b1;
			else
				cnt_us_rst = 1'b0;
		end
	    REC_DATA	:	begin
			if(dht11_posedge || dht11_negedge)
				cnt_us_rst = 1'b1;
			else
				cnt_us_rst = 1'b0;
		end
		default		:cnt_us_rst = 1'b1;
	endcase
end
//---------cnt_2s
always@(posedge sys_clk or negedge sys_rst_n)begin
	if(~sys_rst_n)begin
		cnt_2s <= 27'd0;
	end
	else begin
		if(state_cur == WAIT)begin
			if(cnt_2s <= CNT_2S_MAX - 1'b1)
				cnt_2s <= cnt_2s + 1'b1;
			else
				cnt_2s <= cnt_2s;
		end
		else if(state_cur == REC_DATA)begin
			cnt_2s <= 27'd0;
		end
		else begin
			cnt_2s <= cnt_2s;
		end
	end
end
//---------cnt_20ms
always@(posedge sys_clk or negedge sys_rst_n)begin
	if(~sys_rst_n)begin
		cnt_20ms <= 20'd0;
	end
	else begin
		if(state_cur == START)begin
			if(cnt_20ms <= CNT_20MS_MAX - 1'b1)
				cnt_20ms <= cnt_20ms + 1'b1;
			else
				cnt_20ms <= cnt_20ms;
		end
		else if(state_cur == REC_DATA)begin
			cnt_20ms <= 20'd0;
		end
		else begin
			cnt_20ms <= cnt_20ms;
		end
	end
end
//---------cnt_1us
always@(posedge sys_clk or negedge sys_rst_n)begin
	if(~sys_rst_n)begin
		cnt_1us <= 6'd0;
	end
	else begin
		if(cnt_1us == CNT_1US_MAX - 1'b1)
			cnt_1us <= 6'd0;
		else if(cnt_us_rst)
			cnt_1us <= 6'd0;
		else
			cnt_1us <= cnt_1us + 1'b1;
	end
end
//---------cnt_nus
always@(posedge sys_clk or negedge sys_rst_n)begin
	if(~sys_rst_n)begin
		cnt_nus <= 7'd0;
	end
	else begin
		if(cnt_us_rst)
			cnt_nus <= 7'd0;
		else if(cnt_1us == CNT_1US_MAX - 1'b1)
			cnt_nus <= cnt_nus + 1'b1;
		else
			cnt_nus <= cnt_nus;
	end
end
always@(posedge sys_clk or negedge sys_rst_n)begin
	if(~sys_rst_n)begin
		cnt_bit <= 6'd0;
	end
	else begin
		if(state_cur == REC_DATA)begin
			if(dht11_negedge)
				cnt_bit <= cnt_bit + 1'b1;
			else
				cnt_bit <= cnt_bit;
		end
		else begin
			cnt_bit <= 6'd0;
		end
	end
end
//*********three stages state machine
//---------the first stage : state transmission
always@(posedge sys_clk or negedge sys_rst_n)begin
	if(~sys_rst_n)
		state_cur <= WAIT;
	else
		state_cur <= state_nex;
end
//---------the second stage : conditions
always@(*)begin
	case(state_cur)
		WAIT	:begin
			if(end_2s)
				state_nex = START;	//count 2s finish
			else
				state_nex = WAIT;
		end
		START	:begin
			if(end_20ms)
				state_nex = WAIT_RES;//count 20ms finish
			else
				state_nex = START;
		end
		WAIT_RES:begin
			if(res_ok)				//respond
				state_nex = RES_LOW;
			else if(res_no)			//no respond
				state_nex = WAIT;
			else
				state_nex = WAIT_RES;
		end
		RES_LOW	:begin
			if(end_res_low)
				state_nex = RES_HIGH;
			else
				state_nex = RES_LOW;
		end
		RES_HIGH:begin
			if(end_res_high)
				state_nex = REC_DATA;
			else
				state_nex = RES_HIGH;
		end
		REC_DATA:begin
			if(end_rec)
				state_nex = WAIT;
			else
				state_nex = REC_DATA;
		end
		default	:begin
			state_nex = WAIT;
		end
	endcase
end
//---------the third stage : outputs
always@(posedge sys_clk or negedge sys_rst_n)begin
	if(~sys_rst_n)begin
		output_en <= 1'b0;
		data <= 1'b0;
	end
	else begin
		case(state_cur)
			WAIT	 :begin
				output_en <= 1'b1;//output
				data <= 1'b1;
			end
		    START	 :begin
				output_en <= 1'b1;//output
				data <= 1'b0;
				if(end_20ms)
					data <= 1'b1;
			end
		    WAIT_RES :begin
				output_en <= 1'b0;//input
				data <= 1'b0;
			end
		    RES_LOW	 :begin
				output_en <= 1'b0;//input
				data <= 1'b0;
			end
		    RES_HIGH :begin
				output_en <= 1'b0;//input
				data <= 1'b0;
			end
		    REC_DATA :begin
				output_en <= 1'b0;//input
				data <= 1'b0;
			end
			default  :begin
				output_en <= 1'b0;//input
				data <= 1'b0;
			end
		endcase
	end
end
always@(posedge sys_clk or negedge sys_rst_n)begin
	if(~sys_rst_n)begin
		t_h_data_temp <= 40'd0;
	end
	else begin
		if(state_cur == REC_DATA)begin
			if(cnt_nus > 50 && dht11_negedge)
				t_h_data_temp[39 - cnt_bit] <= 1'b1;
			else if(cnt_nus < 50 && dht11_negedge)
				t_h_data_temp[39 - cnt_bit] <= 1'b0;
			else
				t_h_data_temp <= t_h_data_temp;
		end
		else begin
			t_h_data_temp <= t_h_data_temp;
		end
	end
end
always@(posedge sys_clk or negedge sys_rst_n)begin
	if(~sys_rst_n)begin
		t_h_data <= 40'd0;
	end
	else begin
		if(state_cur == REC_DATA)begin
			if(end_rec && check)
				t_h_data <= t_h_data_temp;
			else
				t_h_data <= t_h_data;
		end
		else begin
			t_h_data <= t_h_data;
		end
	end
end
endmodule 

//作者：Eliezer_Z https://www.bilibili.com/read/cv18461860/ 出处：bilibili
