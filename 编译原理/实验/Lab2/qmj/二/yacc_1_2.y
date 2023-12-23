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
#ifndef YYSTYPE
#define YYSTYPE double
#endif

int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);
%}

//TODO:给每个符号定义一个单词类别
%token ADD SUB
%token MUL DIV
%token UMINUS
%token NUMBER
%token LBCKT RBCKT
%token ID

%left ADD SUB
%left MUL DIV
%right UMINUS         
%left LBCKT RBCKT

%%


lines   :       lines expr ';' { printf("%f\n", $2); }
        |       lines ';'
        |
        ;
//TODO:完善表达式的规则
expr    :       expr ADD expr   { $$=$1+$3; }   //加法
        |       expr SUB expr   { $$=$1-$3; }   //减法
        |       expr MUL expr   { $$=$1*$3; }   //乘法
        |       expr DIV expr   { $$=$1/$3; }   //除法
        |       LBCKT expr RBCKT  { $$=$2; }    //括号
        |       SUB expr %prec UMINUS   {$$=-$2;} //相反数
        |       NUMBER  {$$=$1;}  //数字
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
            yylval = 0; //置零，用于下面累加数值
            while(isdigit(t)){
                yylval = 10 * yylval + t - '0'; //将读入字符数字转为数值
                t = getchar();
            }
            ungetc(t, stdin);   //将最后一个字符放回缓冲区，以便下一次读取
            return NUMBER;
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