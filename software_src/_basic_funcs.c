//基本功能
/*斐波那契数列*/
int fibonacci(int x)
{
	if(x == 0 || x == 1) return x;
	int temp1 = 0, temp2 = 1;
	x -= 1;
	while(x > 0)
	{
		int temp = temp2;
		temp2 = temp2 + temp1;
		temp1 = temp;
		x--;
	}
	return temp2;
}

/*打印Hello World*/
void hello_output()
{   
    putch('\n');
    putch('H‘);putch('e‘);putch('l‘);putch('l‘);putch('o‘);putch(' ‘);
    putch('W‘);putch('o‘);putch('r‘);putch('l‘);putch('d‘);putch('!‘);
    return;
}

/*打印时间*/
void PrintTime()
{
    putch('\n');
    char num_0 = time[0];
    char num_1 = time[1];
    char num_2 = time[2];
    char num_3 = time[3];
    char num_4 = time[4];
    char num_5 = time[5];
    fpga_print_uint((int)num_5);
    fpga_print_uint((int)num_4);
    putch(':');
    fpga_print_uint((int)num_3);
    fpga_print_uint((int)num_2);
    putch(':');
    fpga_print_uint((int)num_1);
    fpga_print_uint((int)num_0);
}

/*清空屏幕*/
void clear()
{
    pos_cursor[0] = -1;
    pos_cursor[1] = 0;
    for(int i = 0;i < VGA_MAXLINE; i++)
        for(int j = 0;j < VGA_MAXCOL; j++)
            vga_start[(i << 7) + j] = 0;
}

void PrintErrorCommand()
{
    putch('\n');putch('U'); putch('n'); putch('k'); putch('n'); putch('o'); putch('w'); putch('n');
    putch(' '); putch('C'); putch('o'); putch('m'); putch('m'); putch('a'); putch('n'); putch('d');
}

void PrintErrorParameter()
{
    putch('\n');putch('P'); putch('a'); putch('r'); putch('a'); putch('m'); putch('e'); putch('t'); putch('e'); putch('r');
    putch(' '); putch('E'); putch('r'); putch('r'); putch('o'); putch('r');
}