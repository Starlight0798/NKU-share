%code top{
    #include <iostream>
    #include <assert.h>
    #include "parser.h"
    #include <stack>
    extern Ast ast;
    int yylex();
    int yyerror( char const * );
    Type* lastType;
    extern int lines;
    extern int cols;
    std::stack<StmtNode*> whilestack;
    FunctionDef* funcdef;
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
%token VOID INT FLOAT BOOL
%token LPAREN RPAREN LBRACE RBRACE SEMICOLON COMMA
%token ADD SUB MUL DIV MOD OR AND LESS LESSEQUAL GREATER GREATEREQUAL EQUAL NOTEQUAL NOT ASSIGN
%token CONST
%token RETURN CONTINUE BREAK

%type<stmttype> Stmts Stmt AssignStmt BlockStmt IfStmt WhileStmt BreakStmt ContinueStmt ReturnStmt DeclStmt FuncDef ConstDefList VarDef ConstDef VarDefList BlankStmt ExprStmt
%type<exprtype> Exp AddExp Cond LOrExp PrimaryExp LVal RelExp LAndExp MulExp UnaryExp EqExp Number
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
    WHILE LPAREN Cond RPAREN {
        whilestack.push(new WhileStmt($3, nullptr));
    }
    Stmt {
        $$ = whilestack.top();
        whilestack.pop();
        ((WhileStmt*)$$)->setStmt($6);
    }
    ;
BreakStmt
    : 
    BREAK SEMICOLON { 
        if(whilestack.empty()){
            $$ = new BreakStmt(nullptr);
        }
        else{
            $$ = new BreakStmt(whilestack.top());
        }
    }
    ;
ContinueStmt
    : 
    CONTINUE SEMICOLON { 
        if(whilestack.empty()){
            $$ = new ContinueStmt(nullptr);
        }
        else{
            $$ = new ContinueStmt(whilestack.top());
        }
    }
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
        se = identifiers->nlookup($1);
        if(se != nullptr){
            fprintf(stderr, "identifier \"%s\" is redefined in line %d, col %d\n", 
                (char*)$1, lines, cols);
            delete [](char*)$1;
            exit(EXIT_FAILURE);
        }
        se = new IdentifierSymbolEntry(lastType, $1, identifiers->getLevel(), 0);
        identifiers->install($1, se);
        $$ = new DeclStmt(new Id(se), $3);
        delete []$1;
    }
    ;
VarDef
    : 
    ID {
        SymbolEntry *se;
        se = identifiers->nlookup($1);
        if(se != nullptr){
            fprintf(stderr, "identifier \"%s\" is redefined in line %d, col %d\n", 
                (char*)$1, lines, cols);
            delete [](char*)$1;
            exit(EXIT_FAILURE);
        }
        se = new IdentifierSymbolEntry(lastType, $1, identifiers->getLevel());
        identifiers->install($1, se);
        $$ = new DeclStmt(new Id(se));
        delete [](char*)$1;
    }
    | 
    ID ASSIGN Exp {
        SymbolEntry *se;
        se = identifiers->nlookup($1);
        if(se != nullptr){
            fprintf(stderr, "identifier \"%s\" is redefined in line %d, col %d\n", 
                (char*)$1, lines, cols);
            delete [](char*)$1;
            exit(EXIT_FAILURE);
        }
        se = new IdentifierSymbolEntry(lastType, $1, identifiers->getLevel());
        identifiers->install($1, se);
        $$ = new DeclStmt(new Id(se), $3);
        delete []$1;
    }
    ;
FuncDef
    :
    Type ID {
        identifiers = new SymbolTable(identifiers);
    }
    LPAREN FuncFParams RPAREN {
        std::vector<Type*> deftypes = ((FuncParams*)$5)->getTypes();
        Type *funcType = new FunctionType($1, deftypes);
        SymbolEntry *se = globals->lookup($2);
        if(se != nullptr){
            bool redef = true;
            IdentifierSymbolEntry* currfunc = (IdentifierSymbolEntry*)se;
            // 遍历所有重载函数
            while(true){
                //检查是否满足可重定义条件, 不满足则redef为false
                std::vector<Type*> types = ((FunctionType*)currfunc->getType())->getParamsType();
                if(types.size() == deftypes.size()){
                    bool allsame = true;
                    for(unsigned int i = 0; i < types.size(); i++){
                        if(types[i] != deftypes[i]){
                            allsame = false;
                            break;
                        }
                    }
                    if(allsame){
                        redef = false;
                        break;
                    }
                }
                // 检查下一个重载函数
                if(currfunc->getNextFunc())
                    currfunc = currfunc->getNextFunc();
                else break;
            } 

            // 可重定义
            if(redef){
                assert(currfunc->getNextFunc() == nullptr);
                currfunc->setNextFunc(new IdentifierSymbolEntry(funcType, $2, globals->getLevel()));
                funcdef = new FunctionDef(currfunc->getNextFunc(), $5, nullptr);
            }
            // 不可重定义
            else{
                fprintf(stderr, "Function \"%s\" is redefined in line %d, col %d\n"
                    , (char*)$2, lines, cols);
                delete [](char*)$2;
                exit(EXIT_FAILURE);
            }
        }
        else{
            se = new IdentifierSymbolEntry(funcType, $2, globals->getLevel());
            globals->install($2, se);
            funcdef = new FunctionDef(se, $5, nullptr);
        }
    }
    BlockStmt
    {
        $$ = (StmtNode*)funcdef;
        ((FunctionDef*)$$)->setStmt($8);
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
            fprintf(stderr, "identifier \"%s\" is undefined in line %d, col %d\n"
                    , (char*)$1, lines, cols);
            delete [](char*)$1;
            exit(EXIT_FAILURE);
        }
        $$ = new Id(se);
        delete [](char*)$1;
    }
    ;
PrimaryExp
    :
    LVal { $$ = $1; }
    | 
    Number { $$ = $1; } 
    |
    LPAREN Exp RPAREN { $$ = $2; }
    ;
Number
    :
    INTEGER { 
        SymbolEntry *se = new ConstantSymbolEntry(TypeSystem::intType, $1); 
        $$ = new Constant(se);
    }
    |
    FLOATVALUE { 
        SymbolEntry *se = new ConstantSymbolEntry(TypeSystem::intType, 0);
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
    |
    ID LPAREN FuncRParams RPAREN {
        SymbolEntry* se = globals->lookup($1);
        if(se == nullptr){
            fprintf(stderr, "Function \"%s\" is undefined in line %d, col %d\n"
                    , (char*)$1, lines, cols);
            delete [](char*)$1;
            exit(EXIT_FAILURE);
        }
        else{
            // 检查函数重载，并找出对应的函数
            std::vector<Type*> calltypes = ((CallParams*)$3)->getTypes();
            IdentifierSymbolEntry* currfunc = (IdentifierSymbolEntry*)se;
            bool found = false;
            while(true){
                std::vector<Type*> types = ((FunctionType*)currfunc->getType())->getParamsType();
                if(types.size() == calltypes.size()){
                    bool allsame = true;
                    for(unsigned int i = 0; i < types.size(); i++){
                        Type *t = calltypes[i];
                        if(t->isFunc()){
                            t = ((FunctionType*)t)->getRetType();
                        }
                        if(types[i] != t){
                            allsame = false;
                            break;
                        }
                    }
                    if(allsame){
                        found = true;
                        break;
                    }
                }
                if(currfunc->getNextFunc())
                    currfunc = currfunc->getNextFunc();
                else break;
            }
            // found为true，说明找到了对应的重载函数
            if(found){
                $$ = new CallExpr((SymbolEntry*)currfunc, $3);
                delete [](char*)$1;
            }
            // found为false，说明没有找到对应的重载函数, 报错
            else{
                fprintf(stderr, "Function \"%s\" is undefined in line %d, col %d\n"
                    , (char*)$1, lines, cols);
                delete [](char*)$1;
                exit(EXIT_FAILURE);
            }
        }
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
    ;
EqExp
    :
    RelExp {$$ = $1;}
    |
    EqExp EQUAL RelExp {
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::boolType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::EQUAL, $1, $3);
    }
    |
    EqExp NOTEQUAL RelExp {
        SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::boolType, SymbolTable::getLabel());
        $$ = new BinaryExpr(se, BinaryExpr::NOTEQUAL, $1, $3);
    }
    ;
LAndExp
    :
    EqExp { $$ = $1;}
    |
    LAndExp AND EqExp
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
    std::cerr << "Parser error at line " << lines << ", column " << cols << ": " << message << std::endl;
    return -1;
}
