//功能分支
void order_branch(char* order, int len)
{
    order_len = 0;//清空缓冲区
    if(fpga_strcmp(order, 0, 4, "fib ") == 1)   //斐波那契
    {
        len = len - 4;
        if(if_number(order, 4, len) == 1)
        {
            int x = fpga_stoi(order, 4, len);
            int res = fibonacci(x);
            putch('\n', 0x0F0);
            fpga_print_uint(res, 0x0F0);
        }
        else
        {
            PrintErrorParameter(); 
        }
    }
    else if(fpga_strcmp(order, 0, 4, "help") == 1 && len == 4)
    {
        putch('\n', 0x0F0);
        putstr("Cmommand List:\n", 0x0F0);
        putstr("1.fib [num]\n", 0x0F0);
        putstr("2.hello\n", 0x0F0);
        putstr("3.time\n", 0x0F0);
        putstr("4.cal [expr]\n", 0x0F0);
        putstr("5.clear\n", 0x0F0);
        putstr("6.led on [n]\n", 0x0F0);
        putstr("7.led off [n]\n", 0x0F0);
        putstr("8.snake\n", 0x0F0);
        putstr("9.benchmark", 0x0F0);
    }
    else if(fpga_strcmp(order, 0, 5, "hello") == 1 && len == 5)
    {
        hello_output();
    }
    else if(fpga_strcmp(order, 0, 4, "time") == 1 && len == 4)
    {
        PrintTime();
    }
    else if(fpga_strcmp(order, 0, 4, "cal ") == 1)
    {
        len = len - 4;
        unsigned int flag = 1;
        unsigned val = 0;
        char temp[50];
        fpga_strcpy(temp, 4, len, order);
        val = expr(temp ,&flag);
        if(flag == 1)
        {
            putch('\n', 0xFFF);
            fpga_print_uint(val, 0x0F0);
        }
        else
        {
            PrintErrorParameter();
        }
    }
    else if(fpga_strcmp(order, 0, 5, "clear") == 1 && len == 5)
    {
        clear();
    }
    else if(fpga_strcmp(order, 0, 7, "led on ") == 1)
    {
        len = len - 7;
        if(if_number(order, 7, len) == 1)
        {
            int x = fpga_stoi(order, 7, len);
            if(x >= 0 && x <= 9) led[x] = 1;
            else PrintErrorParameter();
        }
        else
        {
            PrintErrorParameter(); 
        }
    }
    else if(fpga_strcmp(order, 0, 8, "led off ") == 1)
    {
        len = len - 8;
        if(if_number(order, 8, len) == 1)
        {
            int x = fpga_stoi(order, 8, len);
            if(x >= 0 && x <= 9) led[x] = 0;
            else PrintErrorParameter();
        }
        else
        {
            PrintErrorParameter(); 
        }
    }
    else if(fpga_strcmp(order, 0, 5, "snake") == 1 && len == 5)
    {
        snake();
    }
    else if(fpga_strcmp(order, 0, 9, "benchmark") == 1 && len == 9)
    {
        mybenchmark();
    }
    else
    {
        PrintErrorCommand();
    }
}
