
//device map
#define VGA_START    0x00200000
#define VGA_LINE   0x00300000
#define VGA_MAXLINE  30
#define VGA_MAXCOL   70
#define KEY          0x00400000
#define SW           0x00500000
#define LED          0x00600000
#define HEX          0x00700000
#define CLK_S        0x00800000
#define CLK_MS       0x00900000
#define CLK_US       0x00a00000
#define CURSOR       0x00d00000
#define BLINK        0x00e00000



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

static inline uint8_t  inb(uintptr_t addr) { return *(volatile uint8_t  *)addr; }
static inline uint16_t inw(uintptr_t addr) { return *(volatile uint16_t *)addr; }
static inline uint32_t inl(uintptr_t addr) { return *(volatile uint32_t *)addr; }

static inline void outb(uintptr_t addr, uint8_t  data) { *(volatile uint8_t  *)addr = data; }
static inline void outw(uintptr_t addr, uint16_t data) { *(volatile uint16_t *)addr = data; }
static inline void outl(uintptr_t addr, uint32_t data) { *(volatile uint32_t *)addr = data; }