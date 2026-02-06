module ps2_controller_mvp (
    input reset,
    input clk50,
    input ps2_clk,
    input ps2_dat,

    output vld,
    output [7:0] data
);

reg [10:0] shift_reg;
reg [4:0] bit_counter;

//для пересинхронизации
reg [7:0] data_sync0;
reg [7:0] data_sync1;
wire [7:0] data_in;

reg vld_sync0;
reg vld_sync1;
reg dat_ready;

always @(negedge ps2_clk or negedge reset) begin
	if (~reset)
		shift_reg <= 1'b0;
	else 
		shift_reg <= {ps2_dat, shift_reg[10:1]};
end

always @(negedge ps2_clk or negedge reset) begin
	if (~reset)
		bit_counter <= 1'b0;
    else if (bit_counter < 4'b1010)
        bit_counter <= bit_counter + 1'b1;
    else
        bit_counter <= 1'b0;
end

always @(negedge ps2_clk) begin
	if (~reset)
		dat_ready <= 1'b0;
	else if (bit_counter == 4'b1010)
		dat_ready <= 1'b1;
	else 
		dat_ready <= 1'b0;
end

assign data_in = shift_reg[8:1];

//пересинхронизация 
always @(posedge clk50) begin
	data_sync0 <= data_in;
	data_sync1 <= data_sync0;
end

always @(posedge clk50) begin
	vld_sync0 <= dat_ready;
	vld_sync1 <= vld_sync0;
end

assign data = data_sync1;
assign vld = vld_sync1;

endmodule
