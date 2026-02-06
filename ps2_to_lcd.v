module ps2_to_lcd (
    input clk50,
    input reset,
    
    input ps2_clk,
    input ps2_dat,
    
    output [7:0] LCD_DATA,
    output LCD_RW,
    output LCD_EN,
    output LCD_RS
);

wire ps2_vld;
wire [7:0] ps2_data;

wire conn_vld;
wire [7:0] conn_data;

wire ascii_vld;
wire [7:0] ascii_data;

ps2_controller_mvp ps2_dut (
    .reset(reset),
    .clk50(clk50),
    .ps2_clk(ps2_clk),
    .ps2_dat(ps2_dat),
    .vld(ps2_vld),
    .data(ps2_data)
);

connector connector_dut (
    .reset(reset),
    .clk50(clk50),
    .ps2_vld(ps2_vld),
    .ps2_data(ps2_data),
    .retrans_vld(conn_vld),
    .retrans_data(conn_data)
);

retranslator retrans_dut (
    .reset(reset),
    .clk50(clk50),
    .scan_vld(conn_vld),
    .scan_data(conn_data),
    .ASCII_vld(ascii_vld),
    .ASCII_data(ascii_data)
);

lcd_mvp lcd_dut (
    .clk50(clk50),
    .reset(reset),
    .host_enable(ascii_vld),
    .data(ascii_data),
    .LCD_DATA(LCD_DATA),
    .LCD_RW(LCD_RW),
    .LCD_EN(LCD_EN),
    .LCD_RS(LCD_RS)
);

endmodule