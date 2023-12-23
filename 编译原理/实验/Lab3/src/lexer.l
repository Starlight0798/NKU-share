%option noyywrap
%option nounput
%option noinput
%top{
    #include <stdarg.h>
    #include "common.h"
    #include <map>
    #include <stack>
    #include <string>
    #include <iostream>
    using namespace std;
}
%{
    int lines = 0, cols = 0; // 定义行，列计数器

    extern dump_type_t dump_type;

    inline void dump_tokens(const char* format, ...){
        va_list args;
        va_start(args, format);
        if (dump_type == TOKENS)
            vfprintf(yyout, format, args);
        va_end(args);
    }

    /* Your code here, if desired (lab3). */

    class SymbolTableEntry {
    public:
        string lexeme;  // 标识符的词素
        int scope;      // 标识符的作用域
        SymbolTableEntry(string lex, int sc) : lexeme(lex), scope(sc) {}
    };

    class SymbolTable {
    private:
        stack<map<string, SymbolTableEntry*>> scopes;  // 用于存储作用域的栈
        int currentScope;                              // 当前的作用域等级

    public:
        SymbolTable() {
            currentScope = -1;  
            enterScope();      // 初始化时进入全局作用域
        }

        // 进入一个新的作用域
        void enterScope() {
            map<string, SymbolTableEntry*> newScope;
            scopes.push(newScope);
            currentScope++;
        }

        // 退出当前作用域
        void exitScope() {
            if (!scopes.empty()) {
                scopes.pop();
                currentScope--;
            }
        }

        // 插入一个新的标识符
        void insert(string lexeme) {
            SymbolTableEntry* entry = new SymbolTableEntry(lexeme, currentScope);
            scopes.top()[lexeme] = entry;
        }

        // 查询一个标识符
        SymbolTableEntry* lookup(string lexeme) {
            stack<map<string, SymbolTableEntry*>> tempStack = scopes;  // 创建一个临时栈来遍历

            while (!tempStack.empty()) {
                map<string, SymbolTableEntry*>& currentMap = tempStack.top();
                if (currentMap.find(lexeme) != currentMap.end()) {
                    if(currentMap[lexeme]->scope == currentScope){
                        return currentMap[lexeme];
                    }
                }
                tempStack.pop();
            }
            return nullptr;  // 如果在所有作用域中都找不到该标识符，则返回 nullptr
        }
    };

    SymbolTable symTable;
%}

/* definitions section */
DECIMAL ([1-9][0-9]*|0)
ID [[:alpha:]_][[:alpha:][:digit:]_]*
EOL (\r\n|\n|\r)
WHITE [\t ]
/*  Your code here (lab3). */

DECFLOAT [0-9]*(\.[0-9]+)?([eE][-+]?[0-9]+)?
HEXFLOAT (0[xX](([0-9A-Fa-f]*[.][0-9a-fA-F]*)([Pp][+-]?[0-9]+)?)|(([0-9a-fA-F]+)([Pp][+-]?[0-9]+)))
OCTAL 0[0-7]+
HEXADECIMAL 0[xX][0-9a-fA-F]+
COMMENTBEGIN "//"
COMMENTELEMENT .
MLCOMMENTBEGIN "/*"
MLCOMMENTELEMENT .|\n
MLCOMMENTEND "*/"

%x COMMENT 
%x MLCOMMENT

%%
    /* rules section */
"int" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "INT", yytext, lines, cols);
    cols += yyleng;
}

"float" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "FLOAT", yytext, lines, cols);
    cols += yyleng;
}

"void" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "VOID", yytext, lines, cols);
    cols += yyleng;
}

"char" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "CHAR", yytext, lines, cols);
    cols += yyleng;
}

"const" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "CONST", yytext, lines, cols);
    cols += yyleng;
}

"break" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "BREAK", yytext, lines, cols);
    cols += yyleng;
}

"continue" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "CONTINUE", yytext, lines, cols);
    cols += yyleng;
}

"switch" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "SWITCH", yytext, lines, cols);
    cols += yyleng;
}

"case" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "CASE", yytext, lines, cols);
    cols += yyleng;
}

"default" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "DEFAULT", yytext, lines, cols);
    cols += yyleng;
}

"while" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "WHILE", yytext, lines, cols);
    cols += yyleng;
}

"sizeof" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "SIZEOF", yytext, lines, cols);
    cols += yyleng;
}

"if" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "IF", yytext, lines, cols);
    cols += yyleng;
}

"else" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "ELSE", yytext, lines, cols);
    cols += yyleng;
}

"return" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "RETURN", yytext, lines, cols);
    cols += yyleng;
}

    /*运算符*/
"+" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "ADD", yytext, lines, cols);
    cols += yyleng;
}

"-" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "MINUS", yytext, lines, cols);
    cols += yyleng;
}

"*" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "MUL", yytext, lines, cols);
    cols += yyleng;
}

"/" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "DIV", yytext, lines, cols);
    cols += yyleng;
}

"%" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "MOD", yytext, lines, cols);
    cols += yyleng;
}

"++" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "INC", yytext, lines, cols);
    cols += yyleng;
}

"--" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "DEC", yytext, lines, cols);
    cols += yyleng;
}

"=" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "ASSIGN", yytext, lines, cols);
    cols += yyleng;
}

"==" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "EQUAL", yytext, lines, cols);
    cols += yyleng;
}

"<" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "LESS", yytext, lines, cols);
    cols += yyleng;
}

"<=" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "LE", yytext, lines, cols);
    cols += yyleng;
}

">" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "GREATER", yytext, lines, cols);
    cols += yyleng;
}

">=" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "GE", yytext, lines, cols);
    cols += yyleng;
}

"!=" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "NE", yytext, lines, cols);
    cols += yyleng;
}

"!" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "NOT", yytext, lines, cols);
    cols += yyleng;
}

"&&" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "AND", yytext, lines, cols);
    cols += yyleng;
}

"||" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "OR", yytext, lines, cols);
    cols += yyleng;
}

";" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "SEMICOLON", yytext, lines, cols);
    cols += yyleng;
}

"(" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "LPAREN", yytext, lines, cols);
    cols += yyleng;
}

")" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "RPAREN", yytext, lines, cols);
    cols += yyleng;
}

"[" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "LBRACKET", yytext, lines, cols);
    cols += yyleng;
}

"]" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "RBRACKET", yytext, lines, cols);
    cols += yyleng;
}

"{" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "LBRACE", yytext, lines, cols);
    cols += yyleng;
    symTable.enterScope();
}

"}" {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "RBRACE", yytext, lines, cols);
    cols += yyleng;
    symTable.exitScope();
}

"," {
    dump_tokens("%-10s %-10s %-5d %-5d\n", "COMMA", yytext, lines, cols);
    cols += yyleng;
}

{DECIMAL} {
    int decimal;
    decimal = atoi(yytext);
    dump_tokens("%-10s %-10s %-5d %-5d %-10d\n", "DECIMAL", yytext, lines, cols, decimal);
    cols += yyleng;
}


{OCTAL} {
    int octvalue;
    sscanf(yytext, "%o", &octvalue);
    dump_tokens("%-10s %-10s %-5d %-5d %-10d\n", "OCTAL", yytext, lines, cols, octvalue);
    cols += yyleng;
}

{HEXADECIMAL} {
    int hexvalue;
    sscanf(yytext, "%x", &hexvalue);
    dump_tokens("%-10s %-10s %-5d %-5d %-10d\n", "HEX", yytext, lines, cols, hexvalue);
    cols += yyleng;
}

{DECFLOAT} {
    float fvalue;
    sscanf(yytext, "%f", &fvalue);
    dump_tokens("%-10s %-10s %-5d %-5d %-10f\n", "DECFLOAT", yytext, lines, cols, fvalue);
    cols += yyleng;
}

{HEXFLOAT} {
    float fvalue;
    sscanf(yytext, "%f", &fvalue);
    dump_tokens("%-10s %-10s %-5d %-5d %-10f\n", "HEXFLOAT", yytext, lines, cols, fvalue);
    cols += yyleng;
}


{ID} {
    SymbolTableEntry* entry = symTable.lookup(yytext);
    if (!entry) {
        symTable.insert(yytext);
        entry = symTable.lookup(yytext);
    }
    dump_tokens("%-10s %-10s %-5d %-5d %-15p\n", "ID", yytext, lines, cols, entry);
    cols += yyleng;
}

{COMMENTBEGIN} { 
    /*fprintf(yyout, "----begin a single-line comment----\n");*/
    cols += yyleng;
    BEGIN COMMENT; 
}
{MLCOMMENTBEGIN} { 
    /*fprintf(yyout, "----begin a mul-line comment----\n");*/
    cols += yyleng;
    BEGIN MLCOMMENT; 
}

<COMMENT>{COMMENTELEMENT} {
    /*fprintf(yyout, "%s", yytext);*/
    cols += yyleng;
}

<COMMENT>{EOL} {
    /*fprintf(yyout, "\n----single-line comment End----\n");*/
    lines++;
    cols = 0;
    BEGIN INITIAL;
}

<MLCOMMENT>{MLCOMMENTELEMENT} {
    /*fprintf(yyout, "%s", yytext);*/
    cols += yyleng;
    if(*yytext == '\n') {
        cols = 0;
        lines++;
    }
}

<MLCOMMENT>{MLCOMMENTEND} {
    /*fprintf(yyout, "\n----mul-line comment End----\n");*/
    cols += yyleng;
    BEGIN INITIAL;
}


{EOL} {
    lines++;
    cols = 0;
}

{WHITE} { cols += yyleng; }

    /*  Your code here (lab3). */
%%
/* user code section */
