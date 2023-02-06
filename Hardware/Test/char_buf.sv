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
    always @(posedge rdclk)
        dataout <= vga[addr];
    always @(posedge wrclk)
        if(we) vga[addr] <= datain;

endmodule
`endif