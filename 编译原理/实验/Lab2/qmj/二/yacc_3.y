%{
/*********************************************
将所有的词法分析功能均放在 yylex 函数内实现，为 +、-、*、\、(、 ) 每个运算符及整数分别定义一个单词类别，在 yylex 内实现代码，能
识别这些单词，并将单词类别返回给词法分析程序。
实现功能更强的词法分析程序，可识别并忽略空格、制表符、回车等
空白符，能识别多位十进制整数。
YACC file
**********************************************/
#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#include<string.h>

#ifndef YYSTYPE
#define YYSTYPE char*   //使用C风格字符串

#endif
int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);

// 判断是否为字母或下划线
#define IS_ID_CHAR(t) ((t >= 'a' && t <= 'z') || (t >= 'A' && t <= 'Z') || t == '_')

%}

//TODO:给每个符号定义一个单词类别
%token ADD SUB
%token MUL DIV
%token UMINUS
%token NUMBER  
%token ID
%token LBCKT RBCKT

%left ADD SUB
%left MUL DIV
%right UMINUS         
%left LBCKT RBCKT       

%%


lines   :       lines expr ';' { printf("%s\n", $2); }
        |       lines ';'
        |
        ;
//TODO:完善表达式的规则 
expr    :       expr ADD expr { $$ = (char*)malloc(64*sizeof(char)); strcpy($$, $1); strcat($$, $3); strcat($$, "+"); } //加法
		|       expr SUB expr { $$ = (char*)malloc(64*sizeof(char)); strcpy($$, $1); strcat($$, $3); strcat($$, "-"); } //减法
		|       expr MUL expr { $$ = (char*)malloc(64*sizeof(char)); strcpy($$, $1); strcat($$, $3); strcat($$, "*"); } //乘法
		|       expr DIV expr { $$ = (char*)malloc(64*sizeof(char)); strcpy($$, $1); strcat($$, $3); strcat($$, "/"); } //除法
		|       SUB expr %prec UMINUS {$$ = (char*)malloc(64*sizeof(char)); $$[0] = '-'; strcpy($$+1, $2); } //相反数
        |       LBCKT expr RBCKT { $$ = (char*)malloc(64*sizeof(char)); strcpy($$, $2); }   //括号
		|       NUMBER { $$ = (char*)malloc(64*sizeof(char)); strcpy($$, $1); }  //数字
		|       ID { $$ = (char*)malloc(64*sizeof(char)); strcpy($$, $1); }  //标识符
		;

%%

// programs section

int yylex()
{
    int t;
    while(1){
        t=getchar();
        if(t==' '||t=='\t'||t=='\n'){
            //do noting
        }else if(isdigit(t)){
            //TODO:解析多位数字返回数字类型 
            yylval = (char*)malloc(64*sizeof(char)); //初始化yylval为空字符串
            int p = 0;  //作为指针
            while(isdigit(t)){
                yylval[p++] = t;  //数字依次填入yylval字符列表中
                t = getchar();
            }
            yylval[p] = '\0';
            ungetc(t, stdin);   //将最后一个字符放回缓冲区，以便下一次读取
            return NUMBER;
        }else if(IS_ID_CHAR(t)){
            //TODO 解析标识符
            yylval = (char*)malloc(64*sizeof(char)); //同上
            int p = 0;
            while(IS_ID_CHAR(t)){
                yylval[p++] = t; 
                t = getchar();
            }
            yylval[p] = '\0';
            ungetc(t, stdin);   //同上
            return ID;
        }else if(t=='+'){
            return ADD;
        }else if(t=='-'){
            return SUB;
        }//TODO:识别其他符号
        else if(t=='*'){
            return MUL;     //乘法
        }else if(t=='/'){
            return DIV;     //除法
        }else if(t=='('){
            return LBCKT;   //左括号
        }else if(t==')'){
            return RBCKT;   //右括号
        }
        else{
            return t;       //分号或其他符号
        }
    }
}

int main(void)
{
    yyin=stdin;
    do{
        yyparse();
    }while(!feof(yyin));
    return 0;
}
void yyerror(const char* s){
    fprintf(stderr,"Parse error: %s\n",s);
    exit(1);
}