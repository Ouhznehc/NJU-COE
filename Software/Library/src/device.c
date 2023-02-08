#include "klib.h"

char line_str[128];

void new_line(){
	putch(10);
}

void new_cmd_line(){
	putch_with_color('(', _RGB_YELLOW, _RGB_BALCK);
	putch_with_color('d', _RGB_YELLOW, _RGB_BALCK);
	putch_with_color('o', _RGB_YELLOW, _RGB_BALCK);
	putch_with_color('g', _RGB_YELLOW, _RGB_BALCK);
	putch_with_color(')', _RGB_YELLOW, _RGB_BALCK);
}

char pre_key = '\0';
int  pre_time = 0;
int kbd_key(){return inl(KEY);}	

char get_key(){
	volatile int *key = (int *)KEY;
	volatile int *clk_ms = (int *)CLK_MS;
	while (1) {
    	char now_ch = (char)*key;
		switch(now_ch)
    	if(ch){
			if(pre_ch != ch){
				pre_ch = ch;
				pre_tim = *clk_ms;
				return pre_ch;
			}
			else if(*clk_ms - pre_tim >= 300){
				pre_tim = *clk_ms;
				return pre_ch;
			}
		}
    }
}

char *shell_readline(){
	int now = 0;
    while(1){
		char ch = get_key();
		if(ch == 13){//enter
			line_str[now] = '\0';
			return line_str;
		}
		else if(ch == 8){//backspace
			if(now){
				now--;
				putch(ch);
			}
		}
		else{
			line_str[now++] = ch;
			putch(ch);
		}
	}
}

char **shell_handle_cmd(char *cmd){
	char tmp[128];
    char *fd, *argv[16];
    int argc = 0;
    strcpy(tmp, cmd);
    tmp[strlen(tmp) - 1] = '\0';
    fd = strtok(tmp, " ");
    while(argv[argc++] = strtok(NULL, " "));
}
