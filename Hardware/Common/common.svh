// Device map
`ifndef COMMON_SVH
`define COMMON_SVH

`define CODE      12'h000
`define DATA      12'h001
`define VGA_INFO  12'h002
`define VGA_LINE  12'h003
`define KBD_CODE  12'h004
`define KBD_DOWN  12'h005
`define LED       12'h006   // [15:0]
`define HEX       12'h007   // [31:0]
`define CLK_S     12'h008
`define CLK_MS    12'h009
`define CLK_US    12'h00a
`define SW        12'h00b   // [15:0]
`define ERROR     12'h00c

//errno
`define INVALID_READ    32'd1
`define INVALID_WRITE   32'd2

`endif