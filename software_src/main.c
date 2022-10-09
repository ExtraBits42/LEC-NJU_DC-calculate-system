#include "sys.h"

int main();

//setup the entry point
void entry()
{
    asm("lui sp, 0x00120"); //set stack to high address of the dmem
    asm("addi sp, sp, -4");
    main();
}

int main()
{   
    Init();
    while(1)
        if(IsFifoEmpty() == 0) Show();      //处理键盘的输入流
    return 0;
}