//snake
#define NULL 0
typedef struct Node
{
    int x;
    int y;
    int flag;
} Node;

Node node[50];
int snakelen;
int running;
unsigned food_x = 25;
unsigned food_y = 5;

void showfood()
{
    vga_start[(food_y<<7)+food_x] = '+';
}

void snakeinit()
{   
    for(int i = 0; i < 50; i++){
        node[i].x = 0;
        node[i].y = 0;
        node[i].flag = 0;
    }

    node[0].x = 10; node[0].y = 10; node[0].flag = 6;
    node[1].x = 11; node[1].y = 10; node[1].flag = 6;
    node[2].x = 12; node[2].y = 10; node[2].flag = 6;
    snakelen = 3;
    return;
}

void showsnake()
{
    if(node[snakelen-1].x <= 0 || node[snakelen-1].x >= 69)
    {
        running = 0;
        return;
    }
    if(node[snakelen-1].y <= 0 || node[snakelen-1].y >= 29)
    {
        running = 0;
        return;
    }
    for(int i = 0; i < snakelen; i++)
    {
        vga_start[(node[i].y<<7)+node[i].x] = '*';
        if(i == snakelen-1) vga_start[(node[i].y<<7)+node[i].x] = '@';
    }
    return;
}

void GetCommand()
{
    if(IsFifoEmpty() == 0)
    {
        char ch = GetAscii();
        int temp = node[snakelen-1].flag;
        switch (ch)
        {
        case 0xf2:if(temp == 4 || temp == 6) node[snakelen-1].flag = 2;break;
        case 0xf4:if(temp == 2 || temp == 8) node[snakelen-1].flag = 4;break;
        case 0xf6:if(temp == 2 || temp == 8) node[snakelen-1].flag = 6;break;
        case 0xf8:if(temp == 4 || temp == 6) node[snakelen-1].flag = 8;break;
        default:break;
        }
    }
}

void move()
{   
    int pre_x = node[snakelen-1].x;
    int pre_y = node[snakelen-1].y;
    int pre_flag = node[snakelen-1].flag;
    switch (node[snakelen-1].flag)
    {
    case 6:node[snakelen-1].x += 1;break;
    case 4:node[snakelen-1].x -= 1;break;
    case 2:node[snakelen-1].y += 1;break;
    case 8:node[snakelen-1].y -= 1;break;
    default:node[snakelen-1].flag = 0; break;
    }
    if(node[snakelen-1].x == food_x && node[snakelen-1].y == food_y)//吃到了食物
    {
        rand();
        node[snakelen].x = node[snakelen-1].x;
        node[snakelen].y = node[snakelen-1].y;
        node[snakelen].flag = node[snakelen-1].flag;
        node[snakelen-1].x = pre_x;
        node[snakelen-1].y = pre_y;
        snakelen++;
    }
    else                                                            //未吃到食物
    {
        vga_start[(node[0].y<<7)+node[0].x] = 0;
        int i;
        for(i = 0; i < snakelen - 2; i++)
        {
            node[i] = node[i + 1];
        }
        node[i].x = pre_x;
        node[i].y = pre_y;
        node[i].flag = pre_flag;
    }
    showsnake();
}

void mapinit()
{   
    pos_cursor[0] = 0;
    pos_cursor[1] = 0;
    for(int i = 0;i < VGA_MAXLINE; i++)
        for(int j = 0;j < VGA_MAXCOL; j++)
            vga_start[(i << 7) + j] = 0;
    for(int i = 0; i < 70; i++) vga_start[i] = 219;
    for(int i = 0; i < 70; i++) vga_start[(29<<7)+i] = 219;
    for(int i = 0; i < 30; i++) vga_start[(i<<7)] =  219;
    for(int i = 0; i < 30; i++) vga_start[(i<<7)+69] = 219;

}

void stop_0_25()
{
    int temp_0 = cursor[0];
    int temp_1;
    while(1)
    {
        temp_1 = cursor[0];
        if(temp_1 != temp_0)
            break;
    }
}

void rand()
{
    food_x = (((food_x&0x1)^((food_x&0x2)>>1)^((food_x&0x8)>>3)^((food_x&0x10)>>4))<<31)+((food_x&0xfffffffe)>>1); 
    food_x = food_x%68+1;
    food_y = (((food_y&0x1)^((food_y&0x2)>>1)^((food_y&0x8)>>3)^((food_y&0x10)>>4))<<31)+((food_y&0xfffffffe)>>1); 
    food_y = food_y%28+1;
}

void snake()
{   
    running = 1;
    mapinit();
    snakeinit();
    while(running)
    {   
        stop_0_25();
        move();
        showfood();
        GetCommand();
    }
    clear();    
}

