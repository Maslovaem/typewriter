module	lcd_mvp (
	input clk50,
	input reset,
	
	input host_enable,
	input [7:0] data,
	
	output [7:0] LCD_DATA,
	output LCD_RW,
	output LCD_EN,
	output LCD_RS
);

reg	[5:0]	LUT_INDEX;
reg	[8:0]	LUT_DATA;
reg	[5:0]	mLCD_ST;
reg	[17:0]	mDLY;
reg			mLCD_Start;
reg	[7:0]	mLCD_DATA;
reg			mLCD_RS;
reg [17:0]  psg_hold;
wire		mLCD_Done;

reg [1:0] global_state; //0 - init, 1 - 1st line, 2 - 2nd line
reg cmd_counter;
reg [4:0] data_counter;
reg line; //0 - line1, 1 - line2

reg host_enable_r, host_enable_rr;
wire host_enable_psg;

localparam INIT_CMD = 5;
localparam N_CHARS_LINE = 16;

localparam INIT = 2'b00;
localparam DATA_IN = 2'b01;
localparam CHANGE_AC = 2'b10;

always @(posedge clk50) begin
	host_enable_r <= host_enable;
	host_enable_rr <= host_enable_r;
end
assign host_enable_psg = ~host_enable_rr & host_enable_r;

always @(posedge clk50) begin
	if (~reset) begin
		global_state <= 1'b0;
		cmd_counter  <= 1'b0;
		data_counter <= 1'b0;
		line 		 <= 1'b0;
		LUT_INDEX	 <=	0;
		mLCD_ST		 <=	0;
		mDLY		 <=	0;
		mLCD_Start	 <=	0;
		mLCD_DATA	 <=	0;
		mLCD_RS		 <=	0;
	end else 
	begin
		mLCD_Start	<=	0;
		case (global_state)
		INIT:   begin
					global_state <= (LUT_INDEX < 3'b101) ? INIT : DATA_IN;
					if(LUT_INDEX < 3'b101)
					begin
						case(mLCD_ST)
						0:	begin
								mLCD_DATA	<=	LUT_DATA[7:0];
								mLCD_RS		<=	LUT_DATA[8];
								mLCD_Start	<=	1;
								mLCD_ST		<=	1;
							end
						1:	begin
								if(mLCD_Done)
								begin
									mLCD_Start	<=	0;
									mLCD_ST		<=	2;					
								end
							end
						2:	begin
								if(mDLY < 18'h3FFFE)
								mDLY	<=	mDLY + 1;
								else
								begin
									mDLY	<=	0;
									mLCD_ST	<=	3;
								end
							end
						3:	begin
								LUT_INDEX	<=	LUT_INDEX + 1;
								mLCD_ST	<=	0;
							end
						endcase
					end
				end 
		DATA_IN:	begin
						global_state <= (data_counter < 5'b10000) ? DATA_IN : CHANGE_AC;
						if(data_counter < 5'b10000)
						begin
							case(mLCD_ST)
							0:	begin
									if (host_enable) begin
										mLCD_DATA	<=	data;
										mLCD_RS		<=	1'b1;
										mLCD_Start	<=	1;
										mLCD_ST		<=	1;
									end
								end
							1:	begin
									if(mLCD_Done)
									begin
										mLCD_Start	<=	0;
										mLCD_ST		<=	2;					
									end
								end
							2:	begin
									if(mDLY < 18'h3FFFE)
									mDLY	<=	mDLY + 1;
									else
									begin
										mDLY	<=	0;
										data_counter <=	data_counter + 1;
										mLCD_ST	<=	0;
									end
								end
							3:	begin
									data_counter <=	data_counter + 1;
									mLCD_ST	<=	0;
								end
							endcase
						end else if (data_counter == 5'b10000)
							data_counter <= 1'b0;
					end
		CHANGE_AC:	begin
						case(mLCD_ST)
						0:	begin
								mLCD_DATA	<=	(line) ? 8'h1 : 8'h0C0;
								mLCD_RS		<=	1'b0;
								mLCD_Start	<=	1;
								mLCD_ST		<=	1;
							end
						1:	begin
								if(mLCD_Done)
								begin
									mLCD_Start	<=	0;
									mLCD_ST		<=	2;					
								end
							end
						2:	begin
								if(mDLY < 18'h3FFFE)
								mDLY	<=	mDLY + 1;
								else
								begin
									mDLY	<=	0;
									mLCD_ST	<=	3;
								end
							end
						3:	begin
								mLCD_ST		 <=	0;
								line         <= ~line;
								global_state <= DATA_IN;
							end
						endcase
					end
		endcase
	end
end

always
begin
	case(LUT_INDEX)
	//	Initial
	0:	LUT_DATA	<=	9'h038;//параметры отображения
	1:	LUT_DATA	<=	9'h00E;//display on, cursor off, blinking off
	2:	LUT_DATA	<=	9'h001;//display clear, AC = 0
	3:	LUT_DATA	<=	9'h006;//entry mode set
	4:	LUT_DATA	<=	9'h080;
	default:		LUT_DATA	<=	9'h120;
	endcase
end

LCD_Controller 		u0	(
							.iDATA(mLCD_DATA),
							.iRS(mLCD_RS),
							.iStart(mLCD_Start),
							.oDone(mLCD_Done),
							.iCLK(clk50),
							.iRST_N(reset),
							
							.LCD_DATA(LCD_DATA),
							.LCD_RW(LCD_RW),
							.LCD_EN(LCD_EN),
							.LCD_RS(LCD_RS)	);

endmodule
