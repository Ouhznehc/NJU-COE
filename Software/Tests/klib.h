#ifndef _KLIB_H_
#define _KLIB_H_

#include <stddef.h>
#include <stdarg.h>
#include <stdint.h>
#include "fpga.h"
#include "dog.h"

#define true 1
#define false 0

// string.h
void  *memset    (void *s, int c, size_t n);
void  *memcpy    (void *dst, const void *src, size_t n);
void  *memmove   (void *dst, const void *src, size_t n);
int    memcmp    (const void *s1, const void *s2, size_t n);
size_t strlen    (const char *s);
char  *strcat    (char *dst, const char *src);
char  *strcpy    (char *dst, const char *src);
char  *strncpy   (char *dst, const char *src, size_t n);
int    strcmp    (const char *s1, const char *s2);
int    strncmp   (const char *s1, const char *s2, size_t n);

// stdlib.h
void   srand     (unsigned int seed);
int    rand      (void);
int    abs       (int x);
int    atoi      (const char *nptr);

// stdio.h
int    printf    (const char *format, ...);
int    sprintf   (char *str, const char *format, ...);
int    vsprintf  (char *str, const char *format, va_list ap);

//device.h
static inline uint8_t  inb(uintptr_t addr) { return *(volatile uint8_t  *)addr; }
static inline uint16_t inw(uintptr_t addr) { return *(volatile uint16_t *)addr; }
static inline uint32_t inl(uintptr_t addr) { return *(volatile uint32_t *)addr; }

static inline void outb(uintptr_t addr, uint8_t  data) { *(volatile uint8_t  *)addr = data; }
static inline void outw(uintptr_t addr, uint16_t data) { *(volatile uint16_t *)addr = data; }
static inline void outl(uintptr_t addr, uint32_t data) { *(volatile uint32_t *)addr = data; }

uint32_t rgb                (uint32_t frontcolor, uint32_t backcolor, char ch);
uint32_t get_pos            (uint32_t h, uint32_t v);
char     get_char           (uint32_t vga_data);
void     vga_init           (void);
char     get_key            (void);


uint32_t  kbd_key()   {return inl(KEY);}	
uint32_t  clk_s()     {return inl(CLK_S);}
uint32_t  clk_ms()    {return inl(CLK_MS);}

uint32_t* vga_pixels    = (uint32_t*)VGA_INFO;
uint32_t* line_offset   = (uint32_t*)VGA_LINE;
uint32_t* cursor        = (uint32_t*)CURSOR;
uint32_t  cursor_h      = 0;
uint32_t  cursor_v      = 0;


//fpga.h
void putstr             (char* str);
void putch              (char ch);
void delete_char        (void);
void new_line           (void);
void putch_with_color   (char ch, uint32_t frontcolor, uint32_t backcolor);
void putstr_with_color  (char *str, uint32_t frontcolor, uint32_t backcolor);

//shell.h
char*    shell_readline     (void);
void     shell_handle_cmd   (char *cmd);
void     new_shell_line     (void);

//function.h
void func_hello (char *argv[]);
void func_fib   (char *argv[]);
void func_time  (char *argv[]);

#endif