%{
/*********************************************
将所有的词法分析功能均放在 yylex 函数内实现，为 +、-、*、\、(、 ) 每个运算符及整数分别定义一个单词类别，在 yylex 内实现代码，能
识别这些单词，并将单词类别返回给词法分析程序。
实现功能更强的词法分析程序，可识别并忽略空格、制表符、回车等
空白符，能识别多位十进制整数。
YACC file
**********************************************/
#include<stdio.h>
#include<string.h> //引入string.h头文件，在中转后的规则里使用字符串库函数
#include<stdlib.h>
#include<ctype.h>
#ifndef YYSTYPE
#define YYSTYPE char* // 在第三问中，yacc的返回值需要是字符串类型
#endif
int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);
char numstr[128]; // 存储每一个数字符号
char idstr[128]; // 存储标识符号（除数字外）
%}

//TODO:给每个符号定义一个单词类别
%token ADD MINUS
%token MUL DIV
%token LEFTPAR RIGHTPAR
%token UMINUS
%token NUMBER ID //新增添标识符返回的单词类别ID

%left ADD MINUS
%left MUL DIV
%right UMINUS
%left LEFTPAR RIGHTPAR

%%


lines   :       lines expr ';' { printf("%s\n", $2); } //%s yacc返回一个字符串
        |       lines ';'
        |
        ;
//TODO:完善中缀表达式转后缀表达式的规则，主要利用的就是字符串库函数进行复制拼接
expr    : expr ADD expr { $$ = (char *)malloc(128*sizeof(char)); strcpy($$, $1); strcat($$, $3); strcat($$, "+"); } // 实现顺序的更换
		| expr MINUS expr { $$ = (char *)malloc(128*sizeof(char)); strcpy($$, $1); strcat($$, $3); strcat($$, "-"); }
		| expr MUL expr { $$ = (char *)malloc(128*sizeof(char)); strcpy($$, $1); strcat($$, $3); strcat($$, "*"); }
		| expr DIV expr { $$ = (char *)malloc(128*sizeof(char)); strcpy($$, $1); strcat($$, $3); strcat($$, "/"); }
		| LEFTPAR expr RIGHTPAR { $$ = (char *)malloc(128*sizeof(char)); strcpy($$, $2); }  // 注意此时的expr已经是后缀表达式
		| MINUS expr %prec UMINUS { $$ = (char*)malloc(128*sizeof(char)); strcpy($$,"\0"); strcat($$,"-");strcat($$, $2);} // 负数本身就是后缀
        | NUMBER { $$ = (char *)malloc(128*sizeof(char)); strcpy($$, $1); }  // 数字表达式
		| ID { $$ = (char *)malloc(128*sizeof(char)); strcpy($$, $1); strcat($$, "");}  // 标识符表达式
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
        }
        else if(t>='0' && t<='9'){ // 若读取到数字，则将该数字的所有位均提取进numstr数组中
            int i=0;
            while(isdigit(t)){
                numstr[i]=t;
                t=getchar();
                i++;
            }
            numstr[i] = '\0';
            ungetc(t,stdin); // 同理，放回输入流
            yylval = numstr; // 将提取到的数字字符串赋值给yylval,自动传值给NUMBER的属性
            return NUMBER;
        }
        else if(t>='a'&&t<='z' || t>='A'&&t<='Z' || t=='_'){ //标识符以英文字母或者下划线开头，遍历到时就把该符号的所有位提取入idstr数组
            int i=0;
            while(t>='a'&&t<='z' || t>='A'&&t<='Z' || t=='_'){
                idstr[i]=t;
                t=getchar();
                i++;
            }
            idstr[i] = '\0';
            ungetc(t,stdin); // 同理，放回输入流
            yylval = idstr; // 将提取到的数字字符串赋值给yylval,自动传值给ID的属性
            return ID;
        }

        else if(t=='+'){
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