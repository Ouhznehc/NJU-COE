module Top(
//============= CLK ============
    input   wire                CLK100MHZ,
//============== SW =============
    input   wire    [15:0]      SW,
//============== LED ============
    output  reg    [15:0]      LED,
//============= VGA =============
    output  wire    [3:0]       VGA_B,
    output  wire    [3:0]       VGA_G,
    output  wire    [3:0]       VGA_R,
    output  wire                VGA_HS,
    output  wire                VGA_VS,
//============= PS2 ===========
    input   wire                PS2_CLK,
    input   wire                PS2_DATA,
//============= bcdseg7 ========
    output  wire    [7:0]       AN,
    output  wire    [7:0]       HEX
);

///////////// declarations ////////////////////
wire [31:0] instr;

//imemclk=~clock dmemrdclk = clock dmemwrclk = ~clock;

//clock
clkgen #(10000)    clkgen_10KHZ(.clkin(CLK100MHZ), .clkout(CLK10KHZ));
clkgen #(50000000) clkgen_50MHZ(.clkin(CLK100MHZ), .clkout(CLK50MHZ));
clkgen #(10000000) clkgen_10MHZ(.clkin(CLK100MHZ), .clkout(CLK10MHZ));
clkgen #(25000000) clkgen_25MHZ(.clkin(CLK100MHZ), .clkout(CLK25MHZ));
clkgen #(1000000)  clkgen_1MHZ(.clkin(CLK100MHZ), .clkout(CLK1MHZ));
clkgen #(1000)     clkgen_1KHZ(.clkin(CLK100MHZ), .clkout(CLK1KHZ));
clkgen #(1)        clkgen_1HZ(.clkin(CLK100MHZ), .clkout(CLK1HZ));

//! cpu
cpu my_cpu( 
    .clock(CLK50MHZ),
    .instr(instr),
    .data_addr(data_addr),
    .data_read(data),
    .data_write(data_write),
    .MemOp(MemOp),
    .MemWe(MemWe),
    .next_pc(next_pc)
);

//! instr mem
instr_mem my_imem(
    .addr(next_pc),
    .clock(~CLK50MHZ),
    .instr(instr)
);

//! data mem
data_mem my_dmem(
    .addr(data_addr),
    .dataout(data_read),
    .datain(data_write),
    .rdclk(CLK50MHZ),
    .wrclk(~CLK50MHZ),
    .memop(MemOp),
    .we(MemType == `DATA && MemOp)
);

// hex7seg
wire [7:0][3:0] screen_display;
hex7seg screen(
        .clk(CLK10KHZ),
        .clr(1'b0),
        .en(8'b11111111),
        .display(screen_display),
        .dots(8'b0),
        .AN(AN),
        .HEX(HEX)
    );













