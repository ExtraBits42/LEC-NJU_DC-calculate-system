

function img2 = img2mif(~,~,~)

img=imread('picture1.jpg');
img=img(1:480,1:640,:);

height = 480-1+1;
width = 640-1+1;
s = fopen('test1.mif','wb');
fprintf(s,'%s\n','--VGA Memory Map');
fprintf(s,'---Height: %d,Width: %d\n\n',height,width);
fprintf(s,'%s\n','WIDTH=3;');
fprintf(s,'DEPTH=%d;\n',512*width);
fprintf(s,'%s\n','ADDRESS_RADIX=HEX;');
fprintf(s,'%s\n','DATA_RADIX=UNS;');

fprintf(s,'%s\n','CONTENT');
fprintf(s,'%s\n','BEGIN');
cnt = 0;
img2 =img;
for r=1 :width
    for c=1:512
        cnt = cnt+1;
        if(c<=height)
            R = img(c,r,1);
            G = img(c,r,2);
            B = img(c,r,3);
        else
            R = 15;
            G = 15;
            B = 15;
        end
        fprintf(s,'%06X: %01X;\n',cnt-1,min(min(bitand(R,240)/16,bitand(G,240)/16),bitand(B,240)/16));
    end
end
fprintf(s,'%s\n','END;');

fclose(s);
