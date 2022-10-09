#define NR_REGEX 8
enum
{
    NOTYPE = 256,
    NUM,
};

typedef struct token
{
    int type;
    int len;
    char str[32];
} Token;

Token tokens[32];
unsigned int nr_token;

int match(char* temp, int num, int* len, int* type)
{
    *len = 0;
    if (num == 1)
    {
        if (temp[*len] == '(')
        {
            *type = '(';
            *len = 1;
            return 1;
        }
        else
        {
            *type = NOTYPE;
            *len = 0;
            return 0;
        }
    }
    else if (num == 2)
    {
        if (temp[*len] == ')')
        {
            *type = ')';
            *len = 1;
            return 1;
        }
        else
        {
            *type = NOTYPE;
            *len = 0;
            return 0;
        }
    }
    else if (num == 3)
    {
        if (temp[*len] == '+')
        {
            *type = '+';
            *len = 1;
            return 1;
        }
        else
        {
            *type = NOTYPE;
            *len = 0;
            return 0;
        }
    }
    else if (num == 4)
    {
        if (temp[*len] == '-')
        {
            *type = '-';
            *len = 1;
            return 1;
        }
        else
        {
            *type = NOTYPE;
            *len = 0;
            return 0;
        }
    }
    else if (num == 5)
    {
        if (temp[*len] == '*')
        {
            *type = '*';
            *len = 1;
            return 1;
        }
        else
        {
            *type = NOTYPE;
            *len = 0;
            return 0;
        }
    }
    else if (num == 6)
    {
        if (temp[*len] == '/')
        {
            *type = '/';
            *len = 1;
            return 1;
        }
        else
        {
            *type = NOTYPE;
            *len = 0;
            return 0;
        }
    }
    else if (num == 7)
    {
        if (temp[*len] >= 48 && temp[*len] <= 57)
        {
            *type = NUM;
            *len = 1;
            while (temp[*len] >= 48 && temp[*len] <= 57) *len = *len + 1;
                
            return 1;
        }
        else
        {
            *type = NOTYPE;
            *len = 0;
            return 0;
        }
    }
    else if (num == 8)
    {
        *type = NOTYPE;
        *len = 0;
        return 0;
    }
    return 0;
}


int make_token(char* e)
{
    int len;
    int type;
    int position = 0;
    int i;
    nr_token = 0;

    while (e[position] != '\0')
    {
        for (i = 1; i <= NR_REGEX; i++)
        {
            if (match(e + position, i, &len, &type) == 1)
            {
                tokens[nr_token].type = type;
                tokens[nr_token].len = len;
                fpga_strcpy(tokens[nr_token].str, position, len, e);
                position = position + len;
                break;
            }
        }

        if (i >= NR_REGEX)//匹配失败
        {
            return 0;
        }
        nr_token++;
    }
    return 1;
}

int check_parentheses(int p, int q) 
{
    int flag = 0;
    int num = 0;
    if (tokens[p].type == '(' && tokens[q].type == ')') {
        flag = 1;
        for (int i = p; i < q; i++) {
            if (tokens[i].type == '(') num++;
            if (tokens[i].type == ')') num--;
            if (num == 0) flag = 0;
        }
    }
    return flag;
}

unsigned value(unsigned p) 
{
    unsigned val = 0;

    switch (tokens[p].type) {
    case NUM: val = fpga_stoi(tokens[p].str, 0, tokens[p].len); break;
    default: val = 0; break;
    }
    return val;
}

unsigned d_op(unsigned p, unsigned q) 
{
    unsigned op = p;
    unsigned level = 5;
    unsigned num = 0;
    int flag = 0;
    for (int i = p; i <= q; i++) {
        if (!flag && (tokens[i].type == '*' || tokens[i].type == '/' || tokens[i].type == '+' || tokens[i].type == '-'))
        {
            unsigned temp;
            switch (tokens[i].type) {
            case '+': temp = 3; break;
            case '-': temp = 3;	break;
            case '*': temp = 4; break;
            case '/': temp = 4; break;
            default: break;
            }
            if (level >= temp && temp != 5)
            {
                op = i;
                level = temp;
            }
        }
        if (tokens[i].type == '(' || tokens[i].type == ')') {
            if (tokens[i].type == '(') num++;
            if (tokens[i].type == ')') num--;
            flag = (num == 0) ? 0 : 1;
        }
    }
    return op;
}

unsigned eval(unsigned p, unsigned q, int* success)
{

    if (p > q)
    {
        *success = 0;
    }
    else if (p == q)
    {
        return value(p);
    }
    else if (check_parentheses(p, q) == 1)
    {
        return eval(p + 1, q - 1, success);
    }
    else
    {
        unsigned op = d_op(p, q);
        unsigned val1 = 0;
        unsigned val2 = 0;
        val1 = eval(p, op - 1, success);
        val2 = eval(op + 1, q, success);

        switch (tokens[op].type)
        {
        case '+': return val1 + val2;
        case '-': return val1 - val2;
        case '*': return val1 * val2; //__mulsi3(val1, val2);
        case '/': return val1 / val2; //__udivsi3(val1, val2);
        default: return 0;
        }
    }
    return 0;
}

unsigned expr(char* e, int* success)
{
    if (!make_token(e))
    {
        *success = 0;
        return 0;
    }
    return eval(0, nr_token - 1, success);
}