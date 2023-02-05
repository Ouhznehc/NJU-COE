#include "sys.h"


char* vga_start = (char*) VGA_START;
int* vga_line_start = (int *)VGA_LINE_O;
int   vga_line=0;
int   vga_ch=0;


void vga_init(){
    vga_line = 0;
    vga_ch =0;
    *vga_line_start = 0;
    for(int i=0;i<VGA_MAXLINE;i++)
        for(int j=0;j<VGA_MAXCOL;j++)
            vga_start[ (i<<7)+j ] = 0;
}

void putch(char ch) {
  if(ch==8) //backspace
  {
      if(vga_ch > 0){
      	vga_start[ (vga_line<<7)+vga_ch] = 0;
	  	vga_ch--;
	  }
	  else{
	  	if(vga_line != *vga_line_start){
			vga_line = (vga_line + 63) % 64;
			vga_ch = VGA_MAXCOL;
			while(vga_start[ (vga_line<<7)+vga_ch] == 0)
				vga_ch --;
		}
	  }
      return;
  }
  if(ch==10) //enter
  {
      vga_line = (vga_line + 1) % 64;
      vga_ch = 0;
      for(int i=0;i<VGA_MAXCOL;i++)
	    vga_start[ (vga_line<<7)+i ] = 0;
      if((vga_line + 64 - *vga_line_start) % 64 > 29){
	  	*vga_line_start = (*vga_line_start + 1) % 64;
	  }
      return;
  }
  vga_start[ (vga_line<<7)+vga_ch] = ch;
  vga_ch++;
  if(vga_ch>=VGA_MAXCOL)
  {
     putch(10);
  }
  return;
}

void putstr(char *str){
    for(char* p=str;*p!=0;p++)
      putch(*p);
}
