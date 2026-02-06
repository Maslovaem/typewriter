module connector (
    input reset,
    input clk50,
    
    input ps2_vld,
    input [7:0] ps2_data,
    
    output reg retrans_vld,
    output reg [7:0] retrans_data
);

reg [1:0] ST;
localparam IDLE  = 2'b00;
localparam WAIT_F0     = 2'b01;
localparam WAIT_PAYLOAD = 2'b10;

reg ps2_vld_r;
reg ps2_vld_rr;
wire ps2_vld_psg;

always @(posedge clk50) begin
    ps2_vld_r <= ps2_vld;
	ps2_vld_rr <= ps2_vld_r;
end
assign ps2_vld_psg = ~ps2_vld_rr & ps2_vld_r;

always @(posedge clk50 or negedge reset) begin
    if (~reset) begin
        ST <= IDLE;
        retrans_vld <= 0;
        retrans_data <= 0;
    end else begin
        retrans_vld <= 0;
            case (ST)
                IDLE: begin
                    if (ps2_vld_psg & (ps2_data != 8'hF0)) begin
                        retrans_data <= ps2_data;
                        ST <= WAIT_F0;
                    end
                end
                
                WAIT_F0: begin
                    if (ps2_vld_psg & (ps2_data == 8'hF0)) begin
                        ST <= WAIT_PAYLOAD;
                    end else begin
                        ST <= WAIT_F0;
                    end
                end
                
                WAIT_PAYLOAD: begin
                    if (ps2_vld_psg) begin
                        retrans_vld <= 1'b1;
						ST <= IDLE;
                    end else 
						ST <= WAIT_PAYLOAD;
                end
            endcase
    end
end

endmodule

