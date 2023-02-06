module vga_ascii(
    input pclk,
    input rst,
    input c_valid,
    output reg [11:0] vga_data, //!modified from 23
    input [7:0] char,
    input [3:0] h_font,
    input [3:0] v_font,
    input cursor
);
    reg [11:0] myfont[4095:0];
    wire [11:0] line;
    initial 
    begin
        $readmemh("C:/Users/Ouhznehc/Vivado/Library/General Files/font.txt", myfont, 0, 4095);    
    end

    wire [11:0] out_data;

    wire [11:0] frontcolor; //white
    wire [11:0] backcolor; //black
    wire cursorline;

    assign frontcolor = 12'hFFF;
    assign backcolor  = 12'h000;

    assign out_data = (line[h_font - 1] == 1'b1 | cursorline) ? frontcolor : backcolor; //!modified from h_font
    assign line = myfont[{char, v_font}];

    assign cursorline = cursor & (h_font == 4'd0); // i don't know why it doesn't work

    always @(posedge pclk)
    begin
        if(c_valid == 1'b1)
            vga_data <= out_data;
        else
            vga_data <= backcolor;
    end
endmodule