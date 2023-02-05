#define VGA_START    0x00200000
#define VGA_LINE_O   0x00300000
#define VGA_MAXLINE  30
#define LINE_MASK    0x003f
#define VGA_MAXCOL   70
#define KEYBROAD     0x00400000
#define LED          0x00600000
#define HEX          0x00700000
#define SW           0x00b00000


void putstr(char* str);
void putch(char ch);

void vga_init(void);
