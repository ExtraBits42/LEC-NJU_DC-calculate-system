void fpga_strcpy(char* str, int start, int len, const char* ref)
{
    int i;
    for (i = 0; i < len; i++)
    {
        str[i] = ref[start + i];
    }
    str[len] = '\0';
}

int fpga_strcmp(char* str, int s, int len, const char* ref)
{
    for(int i = 0; i < len; i++)
    {
        if(str[s + i] != ref[i]) return 0;
    }
    return 1;
}

int fpga_stoi(char* str, int s, int len)
{
	unsigned int buf_res = 0;
	int sign = 0;
	int i = 0;
	if(str[0 + s] == '-')
	{
		sign = 1;
		i++;
	}
	while(i < len && str[i + s] != '\0')
	{   
        buf_res *= 10;    //buf_res = __mulsi3(buf_res, 10);
		buf_res += ((int)(str[i + s]) - 48);
        i++;
	}
	int res;
	res = (sign == 1) ? -((int)buf_res) : (int)buf_res;
	return res;
}

int if_number(char* str, int s, int len)
{
	int i = 0;
	if(str[0 + s] == '-') i++;
	while(i < len && str[i + s] != '\0')
	{
		int buf = (int)(str[i + s]);
		if(buf < 48 || buf > 57)
		{
			return 0;
		}
        i++;
	}
	return 1;
}

void fpga_print_uint(int x, unsigned int color)
{
    if(x == 0)
    {
        putch('0', color);
        return;
    }
	if(x < 0)
	{
		putch('-', color);
		x = -x;
	}
	unsigned int tens = 1;

	unsigned int temp = (unsigned int)x;
	unsigned int ux = (unsigned int)x;
    unsigned int len = 0;

	while(ux != 0)
	{
		ux /= 10;           //ux = __udivsi3(ux, 10);
		tens *= 10;         //tens = __mulsi3(tens, 10);
        len++;
	}
	tens = __udivsi3(tens, 10);
	while(temp != 0)
	{
		unsigned int buf = temp / tens;//__udivsi3(temp, tens);
		putch((char)(buf + 48), color);
		temp = temp % tens;//temp = __umodsi3(temp, tens);
		tens /= 10;        //tens = __udivsi3(tens, 10);
        len--;
	}
    while(len > 0)
    {
        putch('0', color);
        len--;
    }
	return;
}

void Show()
{
    if(IsFifoEmpty() == 0)
    {
        char ch = GetAscii();
        if(ch == 8) order_len = (order_len > 0) ? (order_len - 1) : 0;
        else if(ch == 10 && order_len > 0) order_branch(order_buf, order_len);
        else if(ch != 10 && ch != 0xf2 && ch != 0xf4 && ch != 0xf6 && ch != 0xf8) {order_buf[order_len] = ch; order_len++;}

        putch(ch, 0xFFF);
        if(ch == 10) Head();
    }
}