`include "../Common/common.svh"
`include "cpu.sv"
`include "hex7seg.sv"
`include "keyboard.sv"
`include "clkgen.sv"
`include "data_mem.sv"
`include "instr_mem.sv"
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
//============= hex7seg ========
    output  wire    [7:0]       AN,
    output  wire    [7:0]       HEX
);


//imemclk=~clock dmemrdclk = clock dmemwrclk = ~clock;
//---------- declarations-------------
(*KEEP = "TRUE"*) wire [11:0] MemType;
(*KEEP = "TRUE"*) wire [7:0] key_code;
(*KEEP = "TRUE"*) wire key_down;
(*KEEP = "TRUE"*) wire CLK50MHZ, CLK25MHZ, CLK10MHZ, CLK1MHZ, CLK10KHZ, CLK1KHZ, CLK1HZ;
(*KEEP = "TRUE"*) wire [31:0] instr, data_addr, data_write, data_read, instr_addr;
(*KEEP = "TRUE"*) reg [31:0] clk_s, clk_ms, clk_us;
(*KEEP = "TRUE"*) reg [7:0][3:0] Hex7Seg;
(*KEEP = "TRUE"*) reg  [31:0] data;
(*KEEP = "TRUE"*) wire [2:0]  MemOp;
(*KEEP = "TRUE"*) wire MemWe;
(*KEEP = "TRUE"*) reg [31:0] errno = 32'b0;
(*KEEP = "TRUE"*) reg [31:0] vga_line;
(*KEEP = "TRUE"*) reg [7:0] vga_info [4095:0];
(*KEEP = "TRUE"*) reg reset, initialed;
(*KEEP = "TRUE"*) wire [31:0] pc;
(*KEEP = "TRUE"*) wire clk, dmemrdclk, imemclk, dmemwrclk;




//! data read
assign MemType = data_addr[31:20];
always @(posedge CLK50MHZ)
begin
    case(MemType)
        `DATA:      data = data_read;
        `VGA_LINE:  data = vga_line;
        `KBD_CODE:  data = {24'b0, key_code};
        `KBD_DOWN:  data = {31'b0, key_down};
        `HEX:       data = Hex7Seg;
        `CLK_S:     data = clk_s;
        `CLK_MS:    data = clk_ms;
        `CLK_US:    data = clk_us;
        `SW:        data = {16'b0, SW};
        //`ERROR:     data = errno;
        default:begin end    //errno = `INVALID_READ;
    endcase
end

//! data write
always @(negedge CLK50MHZ)
begin
    if(MemWe)
    begin
        case(MemType)
            `VGA_INFO:  vga_info[data_addr[11:0]] = data_write;
            `VGA_LINE:  vga_line = data_write;
            //`LED:       LED = data_write[15:0];
            //`HEX:       Hex7Seg = data_write;
            //`ERROR:     errno = data_write;
            default: begin end //   errno = `INVALID_WRITE;
        endcase
    end
end

//! clkgen
clkgen #(10000)    clkgen_10KHZ(.clkin(CLK100MHZ), .clkout(CLK10KHZ));
clkgen #(50000000) clkgen_50MHZ(.clkin(CLK100MHZ), .clkout(CLK50MHZ));
clkgen #(10000000) clkgen_10MHZ(.clkin(CLK100MHZ), .clkout(CLK10MHZ));
clkgen #(25000000) clkgen_25MHZ(.clkin(CLK100MHZ), .clkout(CLK25MHZ));
clkgen #(1000000)  clkgen_1MHZ(.clkin(CLK100MHZ), .clkout(CLK1MHZ));
clkgen #(1000)     clkgen_1KHZ(.clkin(CLK100MHZ), .clkout(CLK1KHZ));
clkgen #(1)        clkgen_1HZ(.clkin(CLK100MHZ), .clkout(CLK1HZ));

//! cpu
debounce button(CLK100MHZ, SW[0], clk);

always @(*)
begin
    Hex7Seg[3:0] = pc[15:0];
    Hex7Seg[7:4] = instr_addr[15:0];
    LED[15:0] = 16'd1;
end
initial begin
	reset = 1'b1;
	initialed = 1'b0;
end
always @(negedge CLK50MHZ) begin
	initialed <= 1'b1;
end
always @(posedge CLK50MHZ) begin
	if(initialed) reset <= 1'b0;
end

cpu my_cpu( 
    .clock(clk),
    .reset(reset),
    .imemaddr(instr_addr),
    .imemdataout(instr),
    .imemclk(imemclk),
    .dmemaddr(data_addr),
    .dmemdataout(data),
    .dmemdatain(data_write),
    .dmemrdclk(dmemrdclk),
    .dmemwrclk(dmemwrclk),
    .dmemop(MemOp),
    .dmemwe(MemWe),
    .dbgdata(pc)
);

//! instr mem
instr_mem my_imem(
    .addr(instr_addr),
    .clock(imemclk),
    .instr(instr)
);

//! data mem
data_mem my_dmem(
    .addr(data_addr),
    .dataout(data_read),
    .datain(data_write),
    .rdclk(dmemrdclk),
    .wrclk(dmemwrclk),
    .memop(MemOp),
    .we(MemType == `DATA && MemWe)
);

//! hex7seg and led
hex7seg screen(
        .clk(CLK10KHZ),
        .clr(1'b0),
        .en(8'b11111111),
        .display(Hex7Seg),
        .dots(8'b0),
        .AN(AN),
        .HEX(HEX)
    );

//! clock 
always @(posedge CLK1HZ) clk_s <= clk_s + 1;
always @(posedge CLK1KHZ) clk_ms <= clk_ms + 1;
always @(posedge CLK1MHZ) clk_us <= clk_us + 1;

//! keyboard
keyboard my_keyborad(
    .ps2_clk(PS2_CLK),
    .ps2_data(PS2_DATA),
    .clk(CLK50MHZ),
    .key_code(key_code),
    .key_down(key_down)
);

//! vga


endmodule

module debounce(clk, button, out);
    input clk;
    input button;
    output out;
    reg delay1;
    reg delay2;
    reg clk_100ms;
    reg [31:0] cnt;
    always@(clk)
    begin
        if((cnt + 1) % 5000000 == 0)
        begin
            clk_100ms <= ~clk_100ms;
            cnt <= 0;
        end
        else
            cnt <= cnt + 1;
    end
    always@(clk_100ms)
    begin
        delay1 <= button;
        delay2 <= delay1;
    end
    assign out = delay1 & delay2;
endmodule












