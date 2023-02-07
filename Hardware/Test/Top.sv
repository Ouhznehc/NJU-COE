`include "../Common/common.svh"
`include "cpu.sv"
`include "hex7seg.sv"
`include "keyboard.sv"
`include "clkgen.sv"
`include "data_mem.sv"
`include "instr_mem.sv"
`include "debounce.sv"
`include "vga_ascii.sv"
`include "vga_ctrl.sv"
`include "char_buf.sv"

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
(*KEEP = "TRUE"*) wire [7:0] kbd_ascii;
(*KEEP = "TRUE"*) wire CLK50MHZ, CLK25MHZ, CLK2MHZ, CLK1MHZ, CLK10KHZ, CLK1KHZ, CLK1HZ;
(*KEEP = "TRUE"*) wire [31:0] instr, data_addr, data_write, data_read, instr_addr;
(*KEEP = "TRUE"*) reg [31:0] clk_s, clk_ms, clk_us;
(*KEEP = "TRUE"*) reg [7:0][3:0] Hex7Seg;
(*KEEP = "TRUE"*) reg  [31:0] data;
(*KEEP = "TRUE"*) wire [2:0]  MemOp;
(*KEEP = "TRUE"*) wire MemWe;
(*KEEP = "TRUE"*) reg [31:0] errno = 32'b0;


(*KEEP = "TRUE"*) reg reset, initialed;
(*KEEP = "TRUE"*) wire [31:0] pc;
(*KEEP = "TRUE"*) wire clk, dmemrdclk, imemclk, dmemwrclk;

(*KEEP = "TRUE"*) wire [9:0] h_addr;
(*KEEP = "TRUE"*) wire [9:0] v_addr;
(*KEEP = "TRUE"*) wire [11:0] vga_data;
(*KEEP = "TRUE"*) wire valid;
(*KEEP = "TRUE"*) wire [6:0] h_char; 
(*KEEP = "TRUE"*) wire [4:0] v_char;
(*KEEP = "TRUE"*) wire [3:0] h_font;
(*KEEP = "TRUE"*) wire [3:0] v_font;
(*KEEP = "TRUE"*) reg [6:0] h_cur;
(*KEEP = "TRUE"*) reg [4:0] v_cur; 

(*KEEP = "TRUE"*) wire [7:0] current_char;
(*KEEP = "TRUE"*) wire [11:0] frontcolor, backcolor;
(*KEEP = "TRUE"*) wire cursor;
(*KEEP = "TRUE"*) wire [11:0] char_addr;
(*KEEP = "TRUE"*) wire [11:0] char_wr_addr;
(*KEEP = "TRUE"*) wire [11:0] char_rd_addr;
(*KEEP = "TRUE"*) reg [4:0] line_offset;
(*KEEP = "TRUE"*) reg [31:0] char_buf_data;



//! data read
assign MemType = data_addr[31:20];
always @(*)
begin
    if(!MemWe)
    case(MemType)
        `DATA:       data = data_read;
        `VGA_LINE:   data = {27'b0, line_offset};
        `VGA_INFO:   data = char_buf_data;
        `CURSOR:     data = {20'b0, v_cur, h_cur};
        `KBD_ASCII:  data = {24'b0, kbd_ascii};
        `SW:         data = {16'b0, SW};
        `LED:        data = {16'b0, LED};
        `HEX:        data = Hex7Seg;
        `CLK_S:      data = clk_s;
        `CLK_MS:     data = clk_ms;
        `CLK_US:     data = clk_us;
        //`ERROR:     data = errno;
        //default:   errno = `INVALID_READ;
    endcase
end

//! data write
always @(posedge dmemwrclk)
begin
    if(MemWe)
    begin
        case(MemType)
            `VGA_LINE:  line_offset = data_write[4:0];
            `CURSOR:    {v_cur, h_cur} = data_write[11:0];
            `LED:       LED = data_write[15:0];
            `HEX:       Hex7Seg = data_write;
            //`ERROR:     errno = data_write;
            //default:    errno = `INVALID_WRITE;
        endcase
    end
end

//! clkgen
clkgen #(50000000) clkgen_50MHZ(.clkin(CLK100MHZ), .clkout(CLK50MHZ));
clkgen #(25000000) clkgen_25MHZ(.clkin(CLK100MHZ), .clkout(CLK25MHZ));
clkgen #(2000000)  clkgen_2MHZ(.clkin(CLK100MHZ), .clkout(CLK2MHZ));
clkgen #(1000000)  clkgen_1MHZ(.clkin(CLK100MHZ), .clkout(CLK1MHZ));
clkgen #(10000)    clkgen_10KHZ(.clkin(CLK100MHZ), .clkout(CLK10KHZ));
clkgen #(1000)     clkgen_1KHZ(.clkin(CLK100MHZ), .clkout(CLK1KHZ));
clkgen #(1)        clkgen_1HZ(.clkin(CLK100MHZ), .clkout(CLK1HZ));

//! cpu
//----- debug signal -----

//debounce button(CLK100MHZ, SW[0], clk);
// always @(*)
// begin
//     Hex7Seg[7:6] = kbd_ascii;
// end

//----- end debug ---

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
    .clock(CLK1MHZ),
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
    .addr({2'b0, instr_addr[31:2]}),
    .clock(imemclk),
    .instr(instr)
);

//! data mem
data_mem my_dmem(
    .addr({12'b0, data_addr[19:0]}),
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
    .clk(~CLK50MHZ),
    .ascii_key(kbd_ascii)
);

//! vga
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

vga_ascii my_vga_ascii(
    .pclk(CLK50MHZ), 
    .c_valid(valid), 
    .frontcolor(frontcolor),
    .backcolor(backcolor),
    .vga_data(vga_data), 
    .char(current_char), 
    .h_font(h_font), 
    .v_font(v_font), 
    .cursor(cursor)
);


char_buf my_char_buf(
    .rdaddr(char_rd_addr),
    .wraddr(char_wr_addr),
    .wrclk(dmemwrclk),            
    .rdclk(~CLK50MHZ), 
    .datain(data_write), 
    .we(MemType == `VGA_INFO && MemWe), 
    .dataout({frontcolor, backcolor, current_char}),
    .data_read(char_buf_data)
);


assign char_rd_addr = {h_char, (v_char + line_offset)};

assign char_wr_addr = {data_addr[8:2], data_addr[13:9]};

assign cursor = (h_char == h_cur) & (v_char == v_cur) & CLK1HZ;
endmodule












