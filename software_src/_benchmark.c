//BenchMarks
void stop_1()
{
    char temp_0 = time[0];
    while(1)
    {
        char temp_1 = time[0];
        if(temp_0 - temp_1 == 5 || temp_1 - temp_0 == 5)
        {
            break;
        }
    }
}

void mybenchmark()
{   
    putch('\n', 0xFFF);
    stop_1();
    benchmark_add();
    benchmark_sub();
    benchmark_mul();
    benchmark_div();
    benchmark_mod();
    return;
}

unsigned temp1 = 351432;
unsigned temp2 = 91824;

unsigned benchmark_add()
{
    char pre_sec = time[0];
    unsigned res = 0;
    volatile unsigned buf = 0;
    while(1)
    {
        char cur_sec = time[0];
        buf = temp1 + temp2;
        if(cur_sec - pre_sec == 5 || pre_sec - cur_sec == 5)
        {
            break;
        }
        res++;
    }
    char add_test_info[21] = "Add Test result is :\0";
    char uint_info[3] = "/s\n";
    putstr(add_test_info, 0x0F0);
    fpga_print_uint((int)(res / 5), 0x0F0);
    putstr(uint_info, 0x0F0);
    return buf;
}

unsigned benchmark_sub()
{
    char pre_sec = time[0];
    unsigned res = 0;
    volatile unsigned buf = 0;
    while(1)
    {
        char cur_sec = time[0];
        buf = temp1 - temp2;
        if(cur_sec - pre_sec == 5 || pre_sec - cur_sec == 5)
        {
            break;
        }
        res++;
    }
    char add_test_info[21] = "Sub Test result is :\0";
    char uint_info[3] = "/s\n";
    putstr(add_test_info, 0x0F0);
    fpga_print_uint((int)(res / 5), 0x0F0);
    putstr(uint_info, 0x0F0);
    return buf;
}

unsigned benchmark_mul()
{
    char pre_sec = time[0];
    unsigned res = 0;
    volatile unsigned buf = 0;
    while(1)
    {
        char cur_sec = time[0];
        buf = temp1 * temp2;
        if(cur_sec - pre_sec == 5 || pre_sec - cur_sec == 5)
        {
            break;
        }
        res++;
    }
    char add_test_info[21] = "Mul Test result is :\0";
    char uint_info[3] = "/s\n";
    putstr(add_test_info, 0x0F0);
    fpga_print_uint((int)(res / 5), 0x0F0);
    putstr(uint_info, 0x0F0);
    return buf;
}

unsigned benchmark_div()
{
    char pre_sec = time[0];
    unsigned res = 0;
    volatile unsigned buf = 0;
    while(1)
    {
        char cur_sec = time[0];
        buf = temp1 / temp2;
        if(cur_sec - pre_sec == 5 || pre_sec - cur_sec == 5)
        {
            break;
        }
        res++;
    }
    char add_test_info[21] = "Div Test result is :\0";
    char uint_info[3] = "/s\n";
    putstr(add_test_info, 0x0F0);
    fpga_print_uint((int)(res / 5), 0x0F0);
    putstr(uint_info, 0x0F0);
    return buf;
}

unsigned benchmark_mod()
{
    char pre_sec = time[0];
    unsigned res = 0;
    volatile unsigned buf = 0;
    while(1)
    {
        char cur_sec = time[0];
        buf = temp1 % temp2;
        if(cur_sec - pre_sec == 5 || pre_sec - cur_sec == 5)
        {
            break;
        }
        res++;
    }
    char add_test_info[21] = "Mod Test result is :\0";
    char uint_info[3] = "/s";
    putstr(add_test_info, 0x0F0);
    fpga_print_uint((int)(res / 5), 0x0F0);
    putstr(uint_info, 0x0F0);
    return buf;
}
