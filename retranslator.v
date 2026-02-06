module retranslator (
	input reset,
	input clk50,
	input scan_vld,
	input [7:0] scan_data,
	
	output ASCII_vld,
	output [7:0] ASCII_data
);

reg scan_vld_r, scan_vld_rr;
wire scan_vld_posedge;

reg [7:0] ASCII_data_r;

always @(posedge clk50) begin
	if (~reset)
		scan_vld_r <= 1'b0;
	else begin
		scan_vld_r <= scan_data;
		scan_vld_rr <= scan_vld_r;
	end
end

always @* begin
	//if (~reset) begin
	//	ASCII_data_r <= 1'b0;
	/*end else */ if (ASCII_vld) begin
		case(scan_data)
			8'h45: ASCII_data_r = 8'h30;   // 0
			8'h16: ASCII_data_r = 8'h31;   // 1
			8'h1e: ASCII_data_r = 8'h32;   // 2
			8'h26: ASCII_data_r = 8'h33;   // 3
			8'h25: ASCII_data_r = 8'h34;   // 4
			8'h2e: ASCII_data_r = 8'h35;   // 5
			8'h36: ASCII_data_r = 8'h36;   // 6
			8'h3d: ASCII_data_r = 8'h37;   // 7
			8'h3e: ASCII_data_r = 8'h38;   // 8
			8'h46: ASCII_data_r = 8'h39;   // 9
			8'h1c: ASCII_data_r = 8'h41;   // A
			8'h32: ASCII_data_r = 8'h42;   // B
			8'h21: ASCII_data_r = 8'h43;   // C
			8'h23: ASCII_data_r = 8'h44;   // D
			8'h24: ASCII_data_r = 8'h45;   // E
			8'h2b: ASCII_data_r = 8'h46;   // F
			8'h34: ASCII_data_r = 8'h47;   // G
			8'h33: ASCII_data_r = 8'h48;   // H
			8'h43: ASCII_data_r = 8'h49;   // I
			8'h3b: ASCII_data_r = 8'h4A;   // J
			8'h42: ASCII_data_r = 8'h4B;   // K
			8'h4b: ASCII_data_r = 8'h4C;   // L
			8'h3a: ASCII_data_r = 8'h4D;   // M
			8'h31: ASCII_data_r = 8'h4E;   // N
			8'h44: ASCII_data_r = 8'h4F;   // O
			8'h4d: ASCII_data_r = 8'h50;   // P
			8'h15: ASCII_data_r = 8'h51;   // Q
			8'h2d: ASCII_data_r = 8'h52;   // R
			8'h1b: ASCII_data_r = 8'h53;   // S
			8'h2c: ASCII_data_r = 8'h54;   // T
			8'h3c: ASCII_data_r = 8'h55;   // U
			8'h2a: ASCII_data_r = 8'h56;   // V
			8'h1d: ASCII_data_r = 8'h57;   // W
			8'h22: ASCII_data_r = 8'h58;   // X
			8'h35: ASCII_data_r = 8'h59;   // Y
			8'h1a: ASCII_data_r = 8'h5A;   // Z
			8'h0e: ASCII_data_r = 8'h7E;   // ~
			8'h4e: ASCII_data_r = 8'h5F;   // _
			8'h55: ASCII_data_r = 8'h2B;   // +
			8'h54: ASCII_data_r = 8'h7B;   // {
			8'h5b: ASCII_data_r = 8'h7D;   // }
			8'h5d: ASCII_data_r = 8'h7C;   // |
			8'h4c: ASCII_data_r = 8'h3A;   // :
			8'h52: ASCII_data_r = 8'h22;   // "
			8'h41: ASCII_data_r = 8'h3C;   // <
			8'h49: ASCII_data_r = 8'h3E;   // >
			8'h4a: ASCII_data_r = 8'h3F;   // ?
			8'h29: ASCII_data_r = 8'h20;   // space
			8'h5a: ASCII_data_r = 8'h0D;   // enter
			8'h66: ASCII_data_r = 8'h08;   // backspace
			8'h0D: ASCII_data_r = 8'h09;   // horizontal tab	
			
			default: ASCII_data_r = 8'h2A; // *
		endcase
	end
end

assign scan_vld_posedge = scan_vld/*scan_vld_r & ~scan_vld_rr*/;
assign ASCII_vld = scan_vld_posedge;
assign ASCII_data = ASCII_data_r;
endmodule