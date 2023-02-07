
//device map
#define VGA_START    0x00200000
#define VGA_LINE_O   0x00300000
#define VGA_MAXLINE  30
#define LINE_MASK    0x003f
#define VGA_MAXCOL   70
#define KEY          0x00400000
#define SW           0x00500000
#define LED          0x00600000
#define HEX          0x00700000
#define CLK_S        0x00800000
#define CLK_MS       0x00900000
#define CUR          0x00d00000


// rgb color
#define _RGB_BALCK  0x00000000
#define _RGB_WHITE  0x00000FFF
#define _RGB_GREEN  0x000000F0
#define _RGB_BLUE   0x000000FF
#define _RGB_RED    0x00000F00
#define _RGB_PURPLE 0x00000F0F
#define _RGB_YELLOW 0x00000FF0


//fpga
void putstr(char* str);
void putch(char ch);
void vga_init(void);