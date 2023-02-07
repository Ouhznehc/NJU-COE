`ifndef CHAR_BUF_SV
`define CHAR_BUG_SV

module char_buf(
    input   wire    [11:0]      addr,
    input   wire    [31:0]      datain,
    output  reg     [31:0]      dataout,
    input   wire                rdclk,
    input   wire                wrclk,
    input   wire                we
);
    reg [31:0] vga [4095:0]; //{frontcolor(12'hFFF), backcolor(12'h000), char}
    initial
    begin
        vga[{7'd1, 5'b0}]  = {12'h0F0, 12'hFF0, "h"};
        vga[{7'd2, 5'b0}]  = {12'h0F0, 12'hFF0, "e"};
        vga[{7'd3, 5'b0}]  = {12'h0F0, 12'hFF0, "l"};
        vga[{7'd4, 5'b0}]  = {12'h0F0, 12'hFF0, "l"};
        vga[{7'd5, 5'b0}]  = {12'h0F0, 12'hFF0, "o"};
        vga[{7'd6, 5'b0}]  = {12'h0F0, 12'hFF0, " "};
        vga[{7'd7, 5'b0}]  = {12'h0F0, 12'hFF0, "w"};
        vga[{7'd8, 5'b0}]  = {12'h0F0, 12'hFF0, "o"};
        vga[{7'd9, 5'b0}]  = {12'h0F0, 12'hFF0, "r"};
        vga[{7'd10, 5'b0}] = {12'h0F0, 12'hFF0, "l"};
        vga[{7'd11, 5'b0}] = {12'h0F0, 12'hFF0, "d"};
        vga[{7'd12, 5'b0}] = {12'h0F0, 12'hFF0, "!"};

    end
    always @(posedge rdclk)
        dataout <= vga[addr];
    always @(posedge wrclk)
        if(we) vga[addr] <= datain;

endmodule
`endif