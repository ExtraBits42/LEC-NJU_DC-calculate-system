void fifo_init()
{
    ptr[0] = 0;//read
    ptr[1] = 0;//write
}

int IsFifoEmpty()
{
    if(ptr[0] == ptr[1])
        return 1;
    else
        return 0;
}

char GetAscii()
{
    char res;
    res = fifo_start[(unsigned)ptr[0]];
    ptr[0] = ptr[0] + 1;
    if(ptr[0] == 8) ptr[0] = 0;
    
    return res;
}
