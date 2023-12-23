%option noyywrap
%option nounput
%option noinput
%top{
    #include <stdarg.h>
    #include "common.h"
    #include "parser.h"
    #include <iostream>
    using namespace std;
}
%{
    int lines = 1, cols = 1; 
    extern FILE *yyin; 
    extern FILE *yyout;

    /* Your code here, if desired (lab3). */
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
    cols += yyleng;
    return INT;
}

"float" {
    cols += yyleng;
    return FLOAT;
}

"void" {
    cols += yyleng;
    return VOID;
}

"char" {
    cols += yyleng;
    return CHAR;
}

"const" {
    cols += yyleng;
    return CONST;
}

"break" {
    cols += yyleng;
    return BREAK;
}

"continue" {
    cols += yyleng;
    return CONTINUE;
}

"while" {
    cols += yyleng;
    return WHILE;
}

"if" {
    cols += yyleng;
    return IF;
}

"else" {
    cols += yyleng;
    return ELSE;
}

"return" {
    cols += yyleng;
    return RETURN;
}

    /*运算符*/
"+" {
    cols += yyleng;
    return ADD;
}

"-" {
    cols += yyleng;
    return SUB;
}

"*" {
    cols += yyleng;
    return MUL;
}

"/" {
    cols += yyleng;
    return DIV;
}

"%" {
    cols += yyleng;
    return MOD;
}

"=" {
    cols += yyleng;
    return ASSIGN;
}

"==" {
    cols += yyleng;
    return EQUAL;
}

"<" {
    cols += yyleng;
    return LESS;
}

"<=" {
    cols += yyleng;
    return LESSEQUAL;
}

">" {
    cols += yyleng;
    return GREATER;
}

">=" {
    cols += yyleng;
    return GREATEREQUAL;
}

"!=" {
    cols += yyleng;
    return NOTEQUAL;
}

"!" {
    cols += yyleng;
    return NOT;
}

"&&" {
    cols += yyleng;
    return AND;
}

"||" {
    cols += yyleng;
    return OR;
}

";" {
    cols += yyleng;
    return SEMICOLON;
}

"(" {
    cols += yyleng;
    return LPAREN;
}

")" {
    cols += yyleng;
    return RPAREN;
}

"{" {
    cols += yyleng;
    return LBRACE;
}

"}" {
    cols += yyleng;
    return RBRACE;
}

"," {
    cols += yyleng;
    return COMMA;
}

{DECIMAL} {
    int decimal;
    decimal = atoi(yytext);
    cols += yyleng;
    yylval.itype = decimal;
    return INTEGER;
}


{OCTAL} {
    int octvalue;
    sscanf(yytext, "%o", &octvalue);
    cols += yyleng;
    yylval.itype = octvalue;
    return INTEGER;
}

{HEXADECIMAL} {
    int hexvalue;
    sscanf(yytext, "%x", &hexvalue);
    cols += yyleng;
    yylval.itype = hexvalue;
    return INTEGER;
}

{DECFLOAT} {
    float fvalue;
    sscanf(yytext, "%f", &fvalue);
    cols += yyleng;
    yylval.ftype = fvalue;
    return FLOATVALUE;
}

{HEXFLOAT} {
    float fvalue;
    sscanf(yytext, "%f", &fvalue);
    cols += yyleng;
    yylval.ftype = fvalue;
    return FLOATVALUE;
}

{WHITE} { cols += yyleng; }

"putint" {
    char *lexeme;
    lexeme = new char[strlen(yytext) + 1];
    strcpy(lexeme, yytext);
    yylval.strtype = lexeme;
    Type* rettype = TypeSystem::voidType;
    std::vector<Type*> paramstype = {TypeSystem::intType};
    Type* funcType = new FunctionType(rettype, paramstype);
    SymbolEntry* se = new IdentifierSymbolEntry(funcType, yytext, globals->getLevel());
    globals->install(yytext, se);
    return ID;
}

"getint" {
    char *lexeme;
    lexeme = new char[strlen(yytext) + 1];
    strcpy(lexeme, yytext);
    yylval.strtype = lexeme;
    Type* rettype = TypeSystem::intType;
    std::vector<Type*> paramstype = {};
    Type* funcType = new FunctionType(rettype, paramstype);
    SymbolEntry* se = new IdentifierSymbolEntry(funcType, yytext, globals->getLevel());
    globals->install(yytext, se);
    return ID;
}

"getfloat" {
    char *lexeme;
    lexeme = new char[strlen(yytext) + 1];
    strcpy(lexeme, yytext);
    yylval.strtype = lexeme;
    Type* rettype = TypeSystem::floatType;
    std::vector<Type*> paramstype = {};
    Type* funcType = new FunctionType(rettype, paramstype);
    SymbolEntry* se = new IdentifierSymbolEntry(funcType, yytext, globals->getLevel());
    globals->install(yytext, se);
    return ID;
}

"putch" {
    char *lexeme;
    lexeme = new char[strlen(yytext) + 1];
    strcpy(lexeme, yytext);
    yylval.strtype = lexeme;
    Type* rettype = TypeSystem::voidType;
    std::vector<Type*> paramstype = {TypeSystem::intType};
    Type* funcType = new FunctionType(rettype, paramstype);
    SymbolEntry* se = new IdentifierSymbolEntry(funcType, yytext, globals->getLevel());
    globals->install(yytext, se);
    return ID;
}

"getch" {
    char *lexeme;
    lexeme = new char[strlen(yytext) + 1];
    strcpy(lexeme, yytext);
    yylval.strtype = lexeme;
    Type* rettype = TypeSystem::intType;
    std::vector<Type*> paramstype = {};
    Type* funcType = new FunctionType(rettype, paramstype);
    SymbolEntry* se = new IdentifierSymbolEntry(funcType, yytext, globals->getLevel());
    globals->install(yytext, se);
    return ID;
}

{ID} {
    cols += yyleng;
    char *lexeme;
    lexeme = new char[strlen(yytext) + 1];
    strcpy(lexeme, yytext);
    yylval.strtype = lexeme;
    return ID;
}

{COMMENTBEGIN} { 
    cols += yyleng;
    BEGIN COMMENT; 
}
{MLCOMMENTBEGIN} { 
    cols += yyleng;
    BEGIN MLCOMMENT; 
}

<COMMENT>{COMMENTELEMENT} {
    cols += yyleng;
}

<COMMENT>{EOL} {
    lines++;
    cols = 0;
    BEGIN INITIAL;
}

<MLCOMMENT>{MLCOMMENTELEMENT} {
    cols += yyleng;
    if(*yytext == '\n') {
        cols = 0;
        lines++;
    }
}

<MLCOMMENT>{MLCOMMENTEND} {
    cols += yyleng;
    BEGIN INITIAL;
}


{EOL} {
    lines++;
    cols = 0;
}

    /*  Your code here (lab3). */
%%
/* user code section */
