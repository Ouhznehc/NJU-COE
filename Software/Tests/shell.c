#include "klib.h"

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




//shell

void new_shell_line(){
    new_line();
    putstr_with_color("(dog)", _RGB_YELLOW, _RGB_BALCK);
    return;
}

void shell_run_cmd(char *filename, char *argv[]){
    for(int i = 0; i < file_table_size(); i++)
        if(strcmp(file_table[i].fileName, filename) == 0){
            file_table[i].funcName(argv);
            return;
        }
    printf("command not found: %s\n", filename);
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

