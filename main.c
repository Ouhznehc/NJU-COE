#include "fpga.h"
#include "klib.h"
int main();

//setup the entry point
void entry()
{
    asm("lui sp, 0x00120"); //set stack to high address of the dmem
    asm("addi sp, sp, -4");
    main();
}
new_line();
new_shell_line(){
    new_line();
    putstr("(dog):");
}

cursor_move_left(){

}

int main()
{
    device_init();
    while(1){
        char *cmd   = shell_readline();
        char **argv = shell_handle_cmd(cmd);
        new_line();
        shell_run_cmd(argv[0], argv);
        new_shell_line();

    }
    return 0;
}

readline(){
    char *cmd[128];

    while(1){
        char key = kbd_read();
        switch(key){
            
        }
    }
}