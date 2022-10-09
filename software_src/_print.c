void putstr(char *str, unsigned int color)
{
    for(char* p=str;*p!=0;p++)
        putch(*p, color);
}

void putch(char ch, unsigned int color)
{
    if(ch == 8) {//backspace
        if(pos_cursor[1] != 10 || vga_start[(pos_cursor[0]<<7)+9] != '$'){
            pos_cursor[0] = (pos_cursor[1] == 0) ? (pos_cursor[0] - 1) : pos_cursor[0];
            pos_cursor[1] = (pos_cursor[1] == 0) ? 69 : (pos_cursor[1] - 1);
            color_start[(pos_cursor[0]<<7)+pos_cursor[1]] = 0xFFF;
            vga_start[(pos_cursor[0]<<7)+pos_cursor[1]] = 0;
        } 
        return;
    }
    if(ch == 10) {//enter
        pos_cursor[0]++;
        if(pos_cursor[0] == 30) switchline(2);
        pos_cursor[1] = 0;
        return;
    }
    if(ch == 0xf8){//上
        if(pos_cursor[0] > 0) pos_cursor[0]--;
        else{
            switchline(-1);
        }
        return;
    }
    if(ch == 0xf2){//下
        if(pos_cursor[0] < 29) pos_cursor[0]++;
        else{
            switchline(1);
        }
        return;
    }
    if(ch == 0xf4){//左
        if(pos_cursor[1] != 10 || vga_start[(pos_cursor[0]<<7)+9] != '$'){
            if(pos_cursor[1] > 0) pos_cursor[1]--;
            else{
                if(pos_cursor[0] > 0) pos_cursor[0]--;
                pos_cursor[1] = 69;
            }
        } 
        return;
    }
    if(ch == 0xf6){//右
        if(pos_cursor[1] < 69) pos_cursor[1]++;
        else{
            if(pos_cursor[0] < 29) pos_cursor[0]++;
            pos_cursor[1] = 0;
        }
        return;
    }
    color_start[(pos_cursor[0]<<7)+pos_cursor[1]] = (color & 0xFFF);
    vga_start[(pos_cursor[0]<<7)+pos_cursor[1]] = ch;
    pos_cursor[1]++;
    if(pos_cursor[1] >= VGA_MAXCOL){
        pos_cursor[1] = 0;
        pos_cursor[0]++;
    }
}

