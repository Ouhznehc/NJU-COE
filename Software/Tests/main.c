#include "klib.h"
//setup the entry point
void entry()
{
    asm("lui sp, 0x00120"); //set stack to high address of the dmem
    asm("addi sp, sp, -4");
    main();
}

int main(){
    vga_init();
    while(1){
        char *cmd = shell_readline();
        new_line();
        //shell_handle_cmd(cmd);
        new_shell_line();
    }
    return 0;
}
 //device.c
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
            vga_pixels[(i << 7) + j] = rgb(_RGB_YELLOW, _RGB_BALCK, dog_animation[i * 70 + j]);
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

//fpga.c

void delete_char(){
    if(cursor_v > 0){
        cursor_v--;
        vga_pixels[get_pos(cursor_h, cursor_v)] = 0;
	  }
	  else{
	      if(cursor_h != 0){
			      cursor_h --;
			      cursor_v = VGA_MAXCOL - 1;
			      while(get_char(vga_pixels[get_pos(cursor_h, cursor_v)]) == 0) cursor_v--;
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


//function.c
// void func_hello(char *argv[]){
//     if(strcmp(argv[0], "hello") != 0){printf("don't match!\n"); return;}
//     if(argv[1] != NULL){printf("Too many Arguments!\n"); return;}
//     printf("Hello World!\n"); return;
// }

// void func_fib(char *argv[]){
//     if(strcmp(argv[0], "fib") != 0){printf("don't match!\n"); return;}
//     if(argv[2] != NULL){printf("Too many Arguments!\n"); return;}
//     int n = atoi(argv[1]);
// 	int f1 = 1, f2 = 1, f3 = 1;
// 	for(int i = 1; i < n; i++){
// 		f3 = f2 + f1;
// 		f1 = f2;
// 		f2 = f3;
// 	}
// 	printf("fib %d is : %d\n", n, f3);
// }

// void func_time(char *argv[]){
//     if(strcmp(argv[0], "time") != 0){printf("don't match!\n"); return;}
//     if(argv[1] != NULL){printf("Too many Arguments!\n"); return;}
//     printf("Now time is %dms\n", clk_ms()); return;
// }


//mul.c
unsigned int __mulsi3(unsigned int a, unsigned int b) {
    unsigned int res = 0;
    while (a) {
        if (a & 1) res += b;
        a >>= 1;
        b <<= 1;
    }
    return res;
}

unsigned int __umodsi3(unsigned int a, unsigned int b) {
    unsigned int bit = 1;
    unsigned int res = 0;

    while (b < a && bit && !(b & (1UL << 31))) {
        b <<= 1;
        bit <<= 1;
    }
    while (bit) {
        if (a >= b) {
            a -= b;
            res |= bit;
        }
        bit >>= 1;
        b >>= 1;
    }
    return a;
}

unsigned int __udivsi3(unsigned int a, unsigned int b) {
    unsigned int bit = 1;
    unsigned int res = 0;

    while (b < a && bit && !(b & (1UL << 31))) {
        b <<= 1;
        bit <<= 1;
    }
    while (bit) {
        if (a >= b) {
            a -= b;
            res |= bit;
        }
        bit >>= 1;
        b >>= 1;
    }
    return res;
}

static char cmd[128];
enum {FD_HELLO, FD_FIB, FD_TIME};
typedef void (*Function) (char *argv[]);
typedef struct {
  char *fileName;
  Function funcName;
} Finfo;

static Finfo file_table[] __attribute__((used)) = {
  [FD_HELLO]  = {"hello", func_hello},
  [FD_FIB]    = {"fib",     func_fib},
  [FD_TIME]   = {"time",   func_time}
};
int file_table_size(){return sizeof(file_table) / sizeof(Finfo);}





//shell.c
void new_shell_line(){
    new_line();
    putstr_with_color("(dog)", _RGB_YELLOW, _RGB_BALCK);
    return;
}


char *shell_readline(){
	uint32_t pos = 0;
    while(1){
		char key = get_key();
        switch (key){
        case _KEY_ENTER:
            cmd[pos] = '\0';
			return cmd;
        case _KEY_BACKSPACE:
            pos--;
            delete_char();
        default:
            cmd[pos++] = key;
            putch(key);
            break;
        }
	}
}

void shell_handle_cmd(char *cmd){
	// char tmp[128];
    // char *fd, *argv[16];
    // uint32_t argc = 0;
    // strcpy(tmp, cmd);
    // tmp[strlen(tmp) - 1] = '\0';
    // fd = strtok(tmp, " ");
    // while(argv[argc++] = strtok(NULL, " "));
}









