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
%token ADD MINUS
%token MUL DIV
%token UMINUS // 取相反数
%token LEFTPAR RIGHTPAR
%token NUMBER

%left ADD MINUS
%left MUL DIV
%right UMINUS
%left LEFTPAR RIGHTPAR

%%


lines   :       lines expr ';' { printf("%f\n", $2); }
        |       lines ';'
        |
        ;
//TODO:完善表达式的规则
expr    :       expr ADD expr   { $$=$1+$3; } // 加法
        |       expr MINUS expr   { $$=$1-$3; } // 减法
        |       expr MUL expr   { $$=$1*$3; } // 乘法
        |       expr DIV expr   { $$=$1/$3; } // 除法
        |       LEFTPAR expr RIGHTPAR { $$ = $2; } // 左右括号
        |       MINUS expr %prec UMINUS   {$$=-$2;} //负号
        |       NUMBER  {$$=$1;} // 数字
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
			yylval = 0;  // yylval 是一个特殊的变量，它被定义为一个与词法规则相关联的联合体（union）
			while (isdigit(t))
			{
				yylval = yylval * 10 + t - '0';
				t = getchar();
			}
            //跳出时t为一个非数字的字符，因此要重新放回
			ungetc(t, stdin); // 将字符 t 放回输入流，防止对后续字符流的分析造成破坏
			return NUMBER;

        }else if(t=='+'){
            return ADD;
        }else if(t=='-'){
            return MINUS;
        }//TODO:识别其他符号
        else if(t=='*'){
            return MUL;
        }
        else if(t=='/'){
            return DIV;
        }
        else if(t=='('){
            return LEFTPAR;
        }
        else if(t==')'){
            return RIGHTPAR;
        }
        else{
            return t;
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