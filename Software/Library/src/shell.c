#include "klib.h"

typedef void (*Function) (char *argv[]);
typedef struct {
  char *fileName;
  Function funcName;
} Finfo;

enum {FD_HELLO, FD_FIB, FD_TIME};

static Finfo file_table[] __attribute__((used)) = {
  [FD_HELLO]  = {"hello", func_hello},
  [FD_FIB]    = {"fib",     func_fib},
  [FD_TIME]   = {"time",   func_time}
};
int file_table_size(){return sizeof(file_table) / sizeof(Finfo);}




//shell
void shell_run_cmd(char *filename, char *argv[]){
    for(int i = 0; i < file_table_size(); i++)
        if(strcmp(file_table[i].filename, filename) == 0){
            file_table[i].funcName(argv);
            return;
        }
    printf("command not found: %s\n", filename);
    return;
}








//functions

void func_hello(char *argv[]){
    if(strcmp(argv[0], "hello") != 0){printf("don't match!\n"); return;}
    if(argv[1] != NULL){printf("Too many Arguments!\n"); return;}
    printf("Hello World!\n"); return;
}

void func_fib(char *argv[]){
    if(strcmp(argv[0], "fib") != 0){printf("don't match!\n"); return;}
    if(argv[2] != NULL){printf("Too many Arguments!\n"); return;}
    int n = atoi(argv[1]);
	int f1 = 1, f2 = 1, f3 = 1;
	for(int i = 1; i < n; i++){
		f3 = f2 + f1;
		f1 = f2;
		f2 = f3;
	}
	printf("fib %d is : %d\n", n, f3);
}

void func_time(char *argv[]){
    if(strcmp(argv[0], "time") != 0){printf("don't match!\n"); return;}
    if(argv[1] != NULL){printf("Too many Arguments!\n"); return;}
    printf("Now time is %dms\n", get_time_ms()); return;
}