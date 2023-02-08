#include "klib.h"

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
    printf("Now time is %dms\n", clk_ms()); return;
}