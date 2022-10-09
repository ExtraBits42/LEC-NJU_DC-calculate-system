#include "sys.h"
//内存映射
char* cursor     = (char*) COUSOR;
char* time       = (char*) TIME;
char* fifo_start = (char*) KEYBOARDFIFO;
char* ptr        = (char*) PTRMEM;
char* vga_start  = (char*) VGA_START;
char* color_start = (short*) COLOR_START;
char* led        = (char*) LED;
char* pos_cursor = (char*) POS;
int* if_graph = (int*)IF_GRAPH;

//指令缓冲
char order_buf[70];
int order_len = 0;

void Head()
{
    color_start[(pos_cursor[0] << 7) + 0] = 0xF00; vga_start[(pos_cursor[0] << 7) + 0] = 'R';
    color_start[(pos_cursor[0] << 7) + 0] = 0xF00; vga_start[(pos_cursor[0] << 7) + 1] = 'o';
    color_start[(pos_cursor[0] << 7) + 0] = 0xF00; vga_start[(pos_cursor[0] << 7) + 2] = 'o';
    color_start[(pos_cursor[0] << 7) + 0] = 0xF00; vga_start[(pos_cursor[0] << 7) + 3] = 't';
    color_start[(pos_cursor[0] << 7) + 0] = 0xFFF; vga_start[(pos_cursor[0] << 7) + 4] = '@';
    color_start[(pos_cursor[0] << 7) + 0] = 0x0F0; vga_start[(pos_cursor[0] << 7) + 5] = 'L';
    color_start[(pos_cursor[0] << 7) + 0] = 0x0F0; vga_start[(pos_cursor[0] << 7) + 6] = 'a';
    color_start[(pos_cursor[0] << 7) + 0] = 0x0F0; vga_start[(pos_cursor[0] << 7) + 7] = 'b';
    color_start[(pos_cursor[0] << 7) + 0] = 0x0F0; vga_start[(pos_cursor[0] << 7) + 8] = ':';
    color_start[(pos_cursor[0] << 7) + 0] = 0x0F0; vga_start[(pos_cursor[0] << 7) + 9] = '$';
    pos_cursor[1] = 10;
}

//显示缓冲区--纯软件实现
char FrontLineBuf[70*5];
int FrontPtr;
char BehindLineBuf[70*5];
int BehindPtr;

void LineBufInit()
{
    FrontPtr = 0;
    BehindPtr = 0;
    for(int i = 0; i < 350; i++){
        FrontLineBuf[i] = 0;
        BehindLineBuf[i] = 0;
    }
}