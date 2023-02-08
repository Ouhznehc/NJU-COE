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

int main(){
    device_init();
    while(1){
        char *cmd   = shell_readline();
        new_line();
        shell_handle_cmd(cmd);
        new_shell_line();

    }
    return 0;
}





