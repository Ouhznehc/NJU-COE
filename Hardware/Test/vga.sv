`ifndef VGA_SV
`define VGA_SV

`include "clkgen.sv"
`include "vga_ascii.sv"
`include "vga_ctrl.sv"
`include "char_buf.sv"


module vga_test(
    input CLK100MHZ,
    output [3:0] VGA_B,
    output [3:0] VGA_G,
    output VGA_HS,
    output [3:0] VGA_R,
    output VGA_VS
);
wire CLK50MHZ, CLK25MHZ, CLK1HZ;
clkgen #(50000000) clkgen_50MHZ(.clkin(CLK100MHZ), .clkout(CLK50MHZ));
clkgen #(25000000) clkgen_25MHZ(.clkin(CLK100MHZ), .clkout(CLK25MHZ));
clkgen #(1)        clkgen_1HZ(.clkin(CLK100MHZ), .clkout(CLK1HZ));
wire [9:0] h_addr;
wire [9:0] v_addr;
wire [11:0] vga_data;
wire valid;
wire [6:0] h_char; //char 70 per line  //now display char positon in the screen, used in vga
wire [4:0] v_char; //char 30 lines     //now display char positon in the screen, used in vga
wire [3:0] h_font; //font 9 point horizontal //now display font position in the char
wire [3:0] v_font; //font 16 point vertical  //now display font position in the char

wire [7:0] current_char; //current character;

wire cursor;
wire char_wr;//always be 1 in the posedge of VGA_CLK
wire [11:0] char_addr;
wire [11:0] char_wr_addr; //[h_cur, v_cur], higher 7 bit is h_cur, lower 5 bit is v_cur
wire [11:0] char_rd_addr;
wire [7:0] char_buf_data; //data to write in the screen(ascii_key)
wire [4:0] line_offset; //for rolling pages

vga_ctrl my_vga(
    .pclk(CLK25MHZ), 
    .vga_data(vga_data), 
    .h_addr(h_addr), 
    .v_addr(v_addr), 
    .hsync(VGA_HS), 
    .vsync(VGA_VS), 
    .valid(valid), 
    .vga_r(VGA_R), 
    .vga_g(VGA_G), 
    .vga_b(VGA_B), 
    .h_char(h_char), 
    .v_char(v_char), 
    .h_font(h_font), 
    .v_font(v_font)
    );

vga_ascii ascii(
    .pclk(CLK50MHZ), 
    .c_valid(valid), 
    .vga_data(vga_data), 
    .char(current_char), 
    .h_font(h_font), 
    .v_font(v_font), 
    .cursor(cursor)
    );

char_buf mybuf(
    .addr(char_addr),
    .wrclk(CLK100MHZ),            
    .rdclk(~CLK50MHZ), 
    .datain(char_buf_data), 
    .we(CLK25MHZ), 
    .dataout(current_char)
);

assign char_addr = (CLK25MHZ) ? char_wr_addr : char_rd_addr; // posedge to write, negedge to read

assign char_rd_addr = {h_char, (v_char + line_offset)}; // always read now position in the screen

assign cursor = (h_char == 7'b0) & (v_char == 5'b0) & CLK1HZ;// when showing position is now positon, cursor is blink 1s a time

endmodule

`endif