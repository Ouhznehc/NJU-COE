`include "../Common/common.svh"
`include "../CPU/SingleCycleCPU/cpu.sv"
`include "../Devices/Hex7seg/hex7seg.sv"
`include "../Devices/Keyboard/keyboard.sv"
`include "../Devices/Timer/clkgen.sv"
`include "../Memory/data_mem.sv"
`include "../Memory/instr_mem.sv"
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
(*KEEP = "TRUE"*) wire [31:0] instr, data_addr, data_write, data_read, next_pc;
(*KEEP = "TRUE"*) reg [31:0] clk_s, clk_ms, clk_us;
(*KEEP = "TRUE"*) reg [7:0][3:0] Hex7Seg;
(*KEEP = "TRUE"*) reg  [31:0] data;
(*KEEP = "TRUE"*) wire [2:0]  MemOp;
(*KEEP = "TRUE"*) wire MemWe;
(*KEEP = "TRUE"*) reg [31:0] errno = 32'b0;
(*KEEP = "TRUE"*) reg [31:0] vga_line;
(*KEEP = "TRUE"*) reg [7:0] vga_info [4095:0];



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
            `HEX:       Hex7Seg = data_write;
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
always @(*)
    LED = next_pc[15:0];
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













