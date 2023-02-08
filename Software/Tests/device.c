#include "klib.h"

static char pre_key = '\0';
static uint32_t  pre_time = 0;

uint32_t rgb(uint32_t frontcolor, uint32_t backcolor, char ch){
	return (frontcolor << 20) | (backcolor << 8) | (uint32_t)ch;
}
uint32_t get_pos(uint32_t h, uint32_t v){
	return (((h + *line_offset) % 32) << 7) + v;
}

char get_char(uint32_t vga_data){
	return (char)(((unsigned int)vga_data) & 0xff);
}

void vga_init(){
    cursor_h = 0;
    cursor_v = 0;
    *line_offset = 0;
    for(uint32_t i = 0; i < VGA_MAXLINE; i++)
        for(uint32_t j = 0; j < VGA_MAXCOL; j++)
            vga_pixels[(i << 7) + j] = rgb(_RGB_WHITE, _RGB_BALCK, dog_animation[i * 70 + j]);
    *cursor = 71;
    while(clk_ms() <= 5000);
    for(uint32_t i = 0; i < VGA_MAXLINE; i++)
        for(uint32_t j = 0; j < VGA_MAXCOL; j++)
            vga_pixels[(i << 7) + j] = 0;
	  *cursor = 0;
}

char get_key(){
	while (1) {
    	char now_key = kbd_key();
    	if(now_key){
			if(pre_key != now_key){
				pre_key = now_key;
				pre_time = clk_ms();
				return pre_key;
			}
			else if(clk_ms() - pre_time >= 300){
				pre_time = clk_ms();
				return pre_key;
			}
		}
    }
}