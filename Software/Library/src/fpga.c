#include "fpga.h"
#include "dog.h"

int* vga_start = (int*) VGA_START;
int* vga_line_offest = (int *)VGA_LINE_O;
int   vga_line = 0;
int   vga_ch = 0;
int* cur = (int *)CUR;
char hello[]="Hello World 2023!\n";

int rgb(int frontcolor, int backcolor, char ch){
	return (frontcolor << 20) | (backcolor << 8) | (int)ch;
}

void vga_init(){
    vga_line = 0;
    vga_ch = 0;
    *vga_line_offest = 0;
    for(int i=0;i<VGA_MAXLINE;i++)
        for(int j=0;j<VGA_MAXCOL;j++)
            vga_start[ (i<<7)+j ] = rgb(_RGB_WHITE, _RGB_BALCK, Dog[i * 70 + j]);
    *cur = 71;
    volatile int *clk_ms = (int *)CLK_MS;
    while(*clk_ms <= 5000);
    for(int i=0;i<VGA_MAXLINE;i++)
        for(int j=0;j<VGA_MAXCOL;j++)
            vga_start[ (i<<7)+j ] = 0;
	*cur = 0;
}

void print(int tmp){
	
}

void func1(){
	putstr(hello);
}

void func2(){
	volatile int *clk_ms = (int *)CLK_MS;
	print(*clk_ms);
}

void func3(int n){
	int f1 = 1, f2 = 1, f3 = 1;
	for(int i = 1; i < n; i++){
		f3 = f2 + f1;
		f1 = f2;
		f2 = f3;
	}
	print(f3);
}

//char line_now[75];

//void deal_line(){
//	int now = 0;
//	while(line_now[now] == ' ')
//		now++;
//}

int getpos(int line, int ch){
	return (((line + *vga_line_offest) % 32)<<7) + ch;
}

char getchar(int vga_data){
	return vga_data & 0xff;
}

void putch(char ch) {
  if(ch==8) //backspace
  {
      if(vga_ch > 0){
      	vga_ch--;
      	vga_start[getpos(vga_line, vga_ch)] = 0;
	  }
	  else{
	  	if(vga_line != 0){
			vga_line --;
			vga_ch = VGA_MAXCOL - 1;
			while(getchar(vga_start[getpos(vga_line, vga_ch)]) == 0)
				vga_ch --;
			vga_ch ++;
		}
	  }
	  *cur = (vga_line<<7)+vga_ch;
      return;
  }
  if(ch==13 || ch==10) //enter
  {
  	  if(vga_line == 29)
  	  	*vga_line_offest = *vga_line_offest + 1;
  	  else vga_line ++;
      vga_ch = 0;
      for(int i=0;i<VGA_MAXCOL;i++)
	    vga_start[getpos(vga_line, i)] = 0;
	  *cur = (vga_line<<7);
      return;
  }
  if(vga_ch == VGA_MAXCOL)
  {
     putch(13);
  }
  vga_start[getpos(vga_line, vga_ch)] = rgb(_RGB_WHITE, _RGB_BALCK, ch);
  vga_ch++;
  *cur = (vga_line<<7)+vga_ch;
  return;
}

void putstr(char *str){
    for(char* p=str;*p!=0;p++)
      putch(*p);
}

