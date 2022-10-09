//宏定义
#define VGA_START 0x00200000        //VGA内存映射
#define VGA_LINE_O 0x00210000       //VGA行映射
#define VGA_MAXLINE 30              //VGA最大行数30
#define LINE_MASK 0x003f
#define VGA_MAXCOL 70               //VGA最大列数70
#define KEYBOARDFIFO 0x00300000     //键盘队列映射
#define FIFO_MAX 10                 //队列最大容量
#define PTRMEM 0x00400000           //队列指针映射
#define COUSOR 0x00500000           //队列游标映射
#define TIME   0x00600000           //系统时间存储映射
#define LED    0x00700000           //LED显示控制映射
#define POS    0x00800000           //终端映射

//输出字符
void putstr(char* str);             //输出字符串
void putch(char ch);                //输出单个字符
void switchline(int offset);        //滚屏
void PrintErrorCommand(void);       //未知指令输出错误指令
void PrintErrorParameter(void);     //未知参数输出错误参数
//底层函数
void Init(void);                    //初始化
void Gra_init(void);                //初始化图形界面显示
void led_init(void);                //LED灯外设初始化
void vga_init(void);                //VGA显存初始化
void LineBufInit(void);             //指令缓冲区初始化


void fifo_init(void);               //键盘队列初始化
int IsFifoEmpty(void);              //获取队列是否为空
char GetAscii(void);                //获取键盘输入的ASCII码
void Show(void);                    //将键盘输入回显到显示屏
void Flash(void);                   //光标闪烁及显示

void graph_init(void);              //简易图形背景初始化
//分支函数
void order_branch(char* order, int len);    //指令分支判断
//基本功能
int fibonacci(int x);                       //斐波那契数列计算
void hello_output();                        //打印Hello World
void PrintTime(void);                       //打印当前系统时间
void clear(void);                           //清屏

//拓展功能
//简易表达式计算
int match(char* temp, int num, int* len, int* type);                //模式匹配
void fpga_strcpy(char* str, int start, int len, const char* ref);   //字符串复制
int make_token(char* e);                                            //生成token
int check_parentheses(int p, int q);                                //检查括号是否匹配
unsigned value(unsigned p);                                         //求值
unsigned d_op(unsigned p, unsigned q);                              //获取操作符
unsigned eval(unsigned p, unsigned q, int* success);                //求值函数
unsigned expr(char* e, int* success);                               //递归调用利用巴科斯范式
//小游戏-贪吃蛇
void stop_0_25(void);       //停止游戏
void mapinit(void);         //地图初始化
void snakeinit(void);       //蛇初始化
void snake(void);           //游戏主函数
void move(void);            //移动
void showsnake(void);       //小蛇显示
void GetCommand(void);      //获取操作
void rand(void);            //随机数生成
void showfood(void);        //食物生成与显示
//简易的benchmark
void stop_1(void);                                              //停止测试
unsigned int benchmark_mod(void);                               //模运算指令测试
unsigned int benchmark_div(void);                               //除法指令测试
unsigned int benchmark_mul(void);                               //乘法指令测试
unsigned int benchmark_sub(void);                               //减法指令测试
unsigned int benchmark_add(void);                               //加法指令测试
void mybenchmark(void);                                         //benchmark调用

//支撑函数
void fpga_print_uint(int x, unsigned int color);                //打印无符号整数
int fpga_strcmp(char* str, int s, int len, const char* ref);    //字符串比较
int fpga_stoi(char* str, int s, int len);                       //字符串转数字
int if_number(char* str, int s, int e);                         //判断字符串是否表示数字
//mul & mod & div
unsigned int __mulsi3(unsigned int a, unsigned int b);          //移位实现的软乘法
unsigned int __umodsi3(unsigned int a, unsigned int b);         //移位实验的软模运算
unsigned int __udivsi3(unsigned int a, unsigned int b);         //移位实现的软除法

