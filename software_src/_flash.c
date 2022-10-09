//软件光标
void Flash()
{   
    vga_start[(pos_cursor[0]<<7)+pos_cursor[1]] = (cursor[0] == 0) ? 0 : '|';
}

void switchline(int offset)
{   
    if(offset == 2){//回车
        //FrontLineBuf
        for(int i = FrontPtr; i >= 1; i--){
            for(int j = 0; j < 70; j++){
                int pos = i * 70 + j;
                FrontLineBuf[pos] = FrontLineBuf[pos - 70];
            }
        }
        for(int j = 0; j < 70; j++){
            FrontLineBuf[j] = vga_start[j];
        }
        FrontPtr++;
        if(FrontPtr == 5) FrontPtr = 1;
        //FrontLineBuf
        for(int i = 0;i < VGA_MAXLINE - 1;i++){
            for(int j = 0; j < VGA_MAXCOL;j++){
                int pos = (i<<7)+j;
                vga_start[pos] = vga_start[pos + 128];
            }
        }
        for(int k = 0; k < VGA_MAXCOL; k++)
            vga_start[(29<<7)+k] = 0;
        pos_cursor[0] = 29;
    }
    else if(offset == -1){//向上
        if(FrontPtr > 0){
            //BehindLineBuf
            for(int i = BehindPtr; i >= 1; i--){
                for(int j = 0; j < 70; j++){
                    int pos = i * 70 + j;
                    BehindLineBuf[pos] = BehindLineBuf[pos - 70];
                }
            }
            for(int j = 0; j < 70; j++){
                BehindLineBuf[j] = vga_start[(29<<7)+j];
            }
            BehindPtr++;
            if(BehindPtr == 5) BehindPtr = 1;
            //BehindLineBuf
            for(int i = VGA_MAXLINE - 1; i > 0; i--){
                for(int j = 0; j < VGA_MAXCOL;j++){
                    int pos = (i<<7)+j;
                    vga_start[pos] = vga_start[pos - 128];
                }
            }
            for(int k = 0; k < VGA_MAXCOL; k++){
                vga_start[k] = FrontLineBuf[k];
            }
            //FrontLineBuf
            for(int i = 0; i < FrontPtr; i++){
                for(int j = 0; j < VGA_MAXCOL; j++){
                    int pos = i * 70 + j;
                    FrontLineBuf[pos] = FrontLineBuf[pos + 70];
                }
            }
            FrontPtr--;
            //FrontLineBuf
        }
    }
    else if(offset == 1){//向上
        if(BehindPtr > 0){
            //FrontLineBuf
            for(int i = FrontPtr; i >= 1; i--){
                for(int j = 0; j < 70; j++){
                    int pos = i * 70 + j;
                    FrontLineBuf[pos] = FrontLineBuf[pos - 70];
                }
            }
            for(int j = 0; j < 70; j++){
                FrontLineBuf[j] = vga_start[j];
            }
            FrontPtr++;
            if(FrontPtr == 5) FrontPtr = 1;
            //FrontLineBuf
            for(int i = 0;i < VGA_MAXLINE - 1;i++){
                for(int j = 0; j < VGA_MAXCOL;j++){
                    int pos = (i<<7)+j;
                    vga_start[pos] = vga_start[pos + 128];
                }
            }
            for(int k = 0; k < VGA_MAXCOL; k++){
                vga_start[(29<<7)+k] = BehindLineBuf[k];
            }
            //BehindLineBuf
            for(int i = 0; i < BehindPtr; i++){
                for(int j = 0; j < VGA_MAXCOL; j++){
                    int pos = i * 70 + j;
                    BehindLineBuf[pos] = BehindLineBuf[pos + 70];
                }
            }
            BehindPtr--;
            //BehindLineBuf
        }
    }
    else{
        return;
    }
}
