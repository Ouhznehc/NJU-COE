#include "klib.h"

void delete_char(){
    if(cursor_v > 0){
        cursor_v--;
        vga_pixels[get_pos(cursor_h, cursor_v)] = 0;
	  }
	  else{
	      if(cursor_h != 0){
			      cursor_h --;
			      cursor_v = VGA_MAXCOL - 1;
			      while(get_char(vga_pixels[getpos(cursor_h, cursor_v)]) == 0) cursor_v--;
			      cursor_v ++;
		    }
	  }
	  *cursor = (cursor_h << 7) + cursor_v;
}

void new_line(){
    if(cursor_h == 29)
  	  	*line_offset = *line_offset + 1;
  	else cursor_h++;
    cursor_v = 0;
    for(uint32_t i = 0; i < VGA_MAXCOL; i++)
	    vga_pixels[get_pos(cursor_h, i)] = 0;
	  *cursor = (cursor_h << 7);
    return;
}

void putch(char ch) {
  if(ch == _KEY_ENDL || cursor_v == VGA_MAXCOL){return new_line();}
  vga_pixels[get_pos(cursor_h, cursor_v)] = rgb(_RGB_WHITE, _RGB_BALCK, ch);
  cursor_v++;
  *cursor = (cursor_h << 7) + cursor_v;
  return;
}

void putstr(char *str){
    for(char* p = str; *p != 0; p++) putch(*p);
}

void putch_with_color(char ch, uint32_t frontcolor, uint32_t backcolor){
  if(ch == _KEY_ENDL || cursor_v == VGA_MAXCOL){return new_line();}
  vga_pixels[get_pos(cursor_h, cursor_v)] = rgb(frontcolor, backcolor, ch);
  cursor_v++;
  *cursor = (cursor_h << 7) + cursor_v;
  return;
}

void putstr_with_color(char *str, uint32_t frontcolor, uint32_t backcolor){
    for(char* p = str; *p != 0; p++) putch_with_color(*p, frontcolor, backcolor);
}

