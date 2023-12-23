%code top{
    #include <iostream>
    #include <assert.h>
    #include "parser.h"
    extern Ast ast;
    int yylex();
    int yyerror( char const * );
    Type* lastType;
    extern int lines;
    extern int cols;
}

%code requires {
    #include "Ast.h"
    #include "SymbolTable.h"
    #include "Type.h"
}

%union {
    int itype;
    char* strtype;
    float ftype;
    StmtNode* stmttype;
    ExprNode* exprtype;
    FuncParams* funcparamtype;
    CallParams* callparamtype;
    Type* type;
}

%start Program
%token <strtype> ID 
%token <itype> INTEGER
%token <ftype> FLOATVALUE
%token IF ELSE WHILE
%token VOID INT FLOAT CHAR BOOL
%token LPAREN RPAREN LBRACE RBRACE SEMICOLON COMMA
%token ADD SUB MUL DIV MOD OR AND LESS LESSEQUAL GREATER GREATEREQUAL EQUAL NOTEQUAL NOT ASSIGN
%token CONST
%token RETURN CONTINUE BREAK

%type<stmttype> Stmts Stmt AssignStmt BlockStmt IfStmt WhileStmt BreakStmt ContinueStmt ReturnStmt DeclStmt FuncDef ConstDefList VarDef ConstDef VarDefList BlankStmt ExprStmt
%type<exprtype> Exp AddExp Cond LOrExp PrimaryExp LVal RelExp LAndExp MulExp UnaryExp Number
%type<funcparamtype> FuncFParams
%type<callparamtype> FuncRParams
%type<type> Type

%precedence THEN
%precedence ELSE
%%
Program
    : Stmts {
        ast.setRoot($1);
    }
    ;
Type
    : 
    INT {
        lastType = TypeSystem::intType;
        $$ = TypeSystem::intType;
    }
    | 
    VOID {
        lastType = TypeSystem::voidType;
        $$ = TypeSystem::voidType;
    }
    | 
    CHAR {
        lastType = TypeSystem::charType;
        $$ = TypeSystem::charType;
    }
    | 
    FLOAT {
        lastType = TypeSystem::floatType;
        $$ = TypeSystem::floatType;
    }
    |
    BOOL {
        lastType = TypeSystem::boolType;
        $$ = TypeSystem::boolType;
    }
    ;
Stmts
    : 
    Stmt { $$=$1;}
    | 
    Stmts Stmt{
        $$ = new SeqNode($1, $2);
    }
    ;
Stmt
    :
    AssignStmt {$$=$1;}
    | BlockStmt {$$=$1;}
    | IfStmt {$$=$1;}
    | ReturnStmt {$$=$1;}
    | DeclStmt {$$=$1;}
    | FuncDef {$$=$1;}
    | WhileStmt {$$=$1;}
    | BreakStmt {$$=$1;}
    | ContinueStmt {$$=$1;}
    | ExprStmt {$$=$1;}
    ;
BlankStmt
    :
    SEMICOLON {
        $$ = new BlankStmt();
    }
    ;
AssignStmt
    :
    LVal ASSIGN Exp SEMICOLON {
        $$ = new AssignStmt($1, $3);
    }
    ;
BlockStmt
    :   
    LBRACE {identifiers = new SymbolTable(identifiers);} 
    Stmts RBRACE 
    {
        $$ = new CompoundStmt($3);
        SymbolTable *top = identifiers;
        identifiers = identifiers->getPrev();
        delete top;
    }
    |
    LBRACE RBRACE 
    {
        $$ = new CompoundStmt(nullptr);
    }
    |
    BlankStmt { $$=$1;} 
    ;
IfStmt
    : 
    IF LPAREN Cond RPAREN Stmt %prec THEN {
        $$ = new IfStmt($3, $5);
    }
    | 
    IF LPAREN Cond RPAREN Stmt ELSE Stmt {
        $$ = new IfElseStmt($3, $5, $7);
    }
    ;
ReturnStmt
    :
    RETURN Exp SEMICOLON{
        $$ = new ReturnStmt($2);
    }
    |
    RETURN SEMICOLON{
        $$ = new ReturnStmt(nullptr);
    }
    ;
DeclStmt
    :
    Type VarDefList SEMICOLON { $$ = $2;}
    |
    CONST Type ConstDefList SEMICOLON { $$ = $3;}
    ;
WhileStmt
    : 
    WHILE LPAREN Cond RPAREN Stmt {
        $$ = new WhileStmt($3, $5);
    }
    ;
BreakStmt
    : 
    BREAK SEMICOLON { $$ = new BreakStmt();}
    ;
ContinueStmt
    : 
    CONTINUE SEMICOLON { $$ = new ContinueStmt();}
    ;
ExprStmt
    :
    Exp SEMICOLON { $$ = new ExprStmt($1);}
    ;
VarDefList
    :
    VarDefList COMMA VarDef {
        $$ = new SeqNode($1, $3);
    } 
    | 
    VarDef {$$ = $1;}
    ;
ConstDefList
    : 
    ConstDefList COMMA ConstDef {
        $$ = new SeqNode($1, $3);
    }
    | 
    ConstDef { $$ = $1; }
    ;
ConstDef
    : 
    ID ASSIGN Exp {
        SymbolEntry *se;
        se = new IdentifierSymbolEntry(lastType, $1, identifiers->getLevel());
        identifiers->install($1, se);
        $$ = new DeclStmt(new Id(se), $3);
        delete []$1;
    }
    ;
VarDef
    : 
    ID {
        SymbolEntry *se;
        se = new IdentifierSymbolEntry(lastType, $1, identifiers->getLevel());
        identifiers->install($1, se);
        $$ = new DeclStmt(new Id(se));
        delete []$1;
    }
    | 
    ID ASSIGN Exp {
        SymbolEntry *se;
        se = new IdentifierSymbolEntry(lastType, $1, identifiers->getLevel());
        identifiers->install($1, se);
        $$ = new DeclStmt(new Id(se), $3);
        delete []$1;
    }
    ;
FuncDef
    :
    Type ID {
        Type *funcType;
        funcType = new FunctionType($1,{});
        assert(globals->lookup($2) == nullptr);
        SymbolEntry *se = new IdentifierSymbolEntry(funcType, $2, globals->getLevel());
        globals->install($2, se);
        identifiers = new SymbolTable(identifiers);
    }
    LPAREN FuncFParams RPAREN 
    BlockStmt
    {
        SymbolEntry *se;
        se = globals->lookup($2);
        assert(se != nullptr);
        $$ = new FunctionDef(se, $5, $7);
        SymbolTable *top = identifiers;
        identifiers = identifiers->getPrev();
        delete top;
        delete []$2;
    }
    ;
FuncFParams
    :
    Type ID { 
        SymbolEntry *se;
        $$ = new FuncParams();
        se = new IdentifierSymbolEntry($1, $2, identifiers->getLevel());
        identifiers->install($2, se);
        DeclStmt* decl = new DeclStmt(new Id(se));
        $$->append($1, decl);
        delete []$2;
    }
    | 
    FuncFParams COMMA Type ID {
        $$ = $1;
        SymbolEntry *se;
        se = new IdentifierSymbolEntry($3, $4, identifiers->getLevel());
        identifiers->install($4, se);
        DeclStmt* decl = new DeclStmt(new Id(se));
        $$->append($3, decl);
    }
    |
    %empty { $$ = new FuncParams(); }
    ;
Exp
    :
    AddExp {$$ = $1;}
    ;
Cond
    :
    LOrExp {$$ = $1;}
    ;
LVal
    : ID {
        SymbolEntry *se;
        se = identifiers->lookup($1);
        if(se == nullptr)
        {
            fprintf(stderr, "identifier \"%s\" is undefined\n", (char*)$1);
            delete [](char*)$1;
            assert(se != nullptr);
        }
        $$ = new Id(se);
        delete []$1;
    }
    ;
PrimaryExp
    :
    LPAREN Exp RPAREN { $$ = $2; }
    |
    LVal { $$ = $1; }
    | 
    Number { $$ = $1; } 
    |
    ID LPAREN FuncRParams RPAREN {
        SymbolEntry* se = globals->lookup($1);
        assert(se != nullptr);
        $$ = new CallExpr(se, $3);
        delete []$1;
    }
    ;
Number
    :
    INTEGER { 
        SymbolEntry *se = new ConstantSymbolEntry(TypeSystem::intType, $1); 
        $$ = new Constant(se);
    }
    |
    FLOATVALUE { 
        SymbolEntry *se = new ConstantSymbolEntry(TypeSystem::floatType, $1);
        $$ = new Constant(se);
    }
    ;
UnaryExp
    :
    PrimaryExp { $$ = $1; }
    |
    ADD UnaryExp {
        SymbolEntry* se = new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$ = new UnaryExpr(se, UnaryExpr::ADD, $2);
    }
    |
    SUB UnaryExp {
        SymbolEntry* se = new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$ = new UnaryExpr(se, UnaryExpr::SUB, $2);
    }
    |
    NOT UnaryExp {
        SymbolEntry* se = new TemporarySymbolEntry(TypeSystem::boolType, SymbolTable::getLabel());
        $$ = new UnaryExpr(se, UnaryExpr::NOT, $2);
    }
    ;
FuncRParams
    :
    Exp { 
        $$ = new CallParams();
        $$->append($1);
    }
    |
    FuncRParams COMMA Exp { 
        $$ = $1;
        $$->append($3);
    }
    |
    %empty { $$ = new CallParams(); }
    ;
MulExp
    :
    UnaryExp { $$ = $1;}
    |
    MulExp MUL UnaryExp
    {
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::MUL, $1, $3);
    }
    |
    MulExp DIV UnaryExp
    {
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::DIV, $1, $3);
    }
    |
    MulExp MOD UnaryExp
    {
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::MOD, $1, $3);
    }
    ;
AddExp
    :
    MulExp { $$ = $1;}
    |
    AddExp ADD MulExp
    {
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::ADD, $1, $3);
    }
    |
    AddExp SUB MulExp
    {
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::SUB, $1, $3);
    }
    ;
RelExp
    :
    AddExp {$$ = $1;}
    |
    RelExp LESS AddExp
    {
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::boolType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::LESS, $1, $3);
    }
    |
    RelExp LESSEQUAL AddExp {
        SymbolEntry* se = new TemporarySymbolEntry(TypeSystem::boolType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::LESSEQUAL, $1, $3);
    }
    | 
    RelExp GREATER AddExp {
        SymbolEntry* se = new TemporarySymbolEntry(TypeSystem::boolType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::GREATER, $1, $3);
    }
    | 
    RelExp GREATEREQUAL AddExp {
        SymbolEntry* se = new TemporarySymbolEntry(TypeSystem::boolType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::GREATEREQUAL, $1, $3);
    }
    | 
    RelExp EQUAL AddExp {
        SymbolEntry* se = new TemporarySymbolEntry(TypeSystem::boolType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::EQUAL, $1, $3);
    }
    | 
    RelExp NOTEQUAL AddExp {
        SymbolEntry* se = new TemporarySymbolEntry(TypeSystem::boolType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::NOTEQUAL, $1, $3);
    }
    ;
LAndExp
    :
    RelExp { $$ = $1;}
    |
    LAndExp AND RelExp
    {
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::boolType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::AND, $1, $3);
    }
    ;
LOrExp
    :
    LAndExp { $$ = $1;}
    |
    LOrExp OR LAndExp
    {
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::boolType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::OR, $1, $3);
    }
    ;
%%

int yyerror(const char *message) {
    std::cerr << "Error at line " << lines << ", column " << cols << ": " << message << std::endl;
    return -1;
}
