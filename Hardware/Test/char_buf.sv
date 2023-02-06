`ifndef CHAR_BUF_SV
`define CHAR_BUG_SV

module char_buf(
    input   wire    [11:0]      addr,
    input   wire    [7:0]       datain,
    output  reg     [7:0]       dataout,
    input   wire                rdclk,
    input   wire                wrclk,
    input   wire                we
);
    reg [7:0] vga [4095:0];
    initial
    begin
        vga[{7'd1, 5'b0}] = "h";
        vga[{7'd2, 5'b0}] = "e";
        vga[{7'd3, 5'b0}] = "l";
        vga[{7'd4, 5'b0}] = "l";
        vga[{7'd5, 5'b0}] = "o";
        vga[{7'd6, 5'b0}] = " ";
        vga[{7'd7, 5'b0}] = "w";
        vga[{7'd8, 5'b0}] = "o";
        vga[{7'd9, 5'b0}] = "r";
        vga[{7'd10, 5'b0}] = "l";
        vga[{7'd11, 5'b0}] = "d";
        vga[{7'd12, 5'b0}] = "!";

    end
    always @(posedge rdclk)
        dataout <= vga[addr];
    always @(posedge wrclk)
        if(we) vga[addr] <= datain;

endmodule
`endif