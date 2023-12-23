#ifndef __AST_H__
#define __AST_H__

#include <fstream>
#include <iostream>
#include <vector>
#include "Type.h"
extern FILE *yyout;

class SymbolEntry;

class Node
{
private:
    static int counter;
    int seq;
public:
    Node();
    int getSeq() const {return seq;};
    virtual void output(int level) = 0;
};

// 表达式
class ExprNode : public Node
{
protected:
    SymbolEntry *symbolEntry;
public:
    SymbolEntry *getSymbolEntry() {return symbolEntry;};
    ExprNode(SymbolEntry *symbolEntry) : symbolEntry(symbolEntry){};
};

// 二元表达式
class BinaryExpr : public ExprNode
{
private:
    int op;
    ExprNode *expr1, *expr2;
public:
    enum {ADD,SUB,MUL,DIV,MOD,OR,AND,LESS,LESSEQUAL,GREATER,GREATEREQUAL,EQUAL,NOTEQUAL};
    BinaryExpr(SymbolEntry *se, int op, ExprNode*expr1, ExprNode*expr2) : ExprNode(se), op(op), expr1(expr1), expr2(expr2){};
    void output(int level);
};

// 常量表达式
class Constant : public ExprNode
{
public:
    Constant(SymbolEntry *se) : ExprNode(se){};
    void output(int level);
};

// 标识符
class Id : public ExprNode
{
public:
    Id(SymbolEntry *se) : ExprNode(se){};
    void output(int level);
};

class StmtNode : public Node
{};

class CompoundStmt : public StmtNode
{
private:
    StmtNode *stmt;
public:
    CompoundStmt(StmtNode *stmt) : stmt(stmt) {};
    void output(int level);
};

// 语句序列
class SeqNode : public StmtNode
{
private:
    StmtNode *stmt1, *stmt2;
public:
    SeqNode(StmtNode *stmt1, StmtNode *stmt2) : stmt1(stmt1), stmt2(stmt2){};
    void output(int level);
};

// 声明语句
class DeclStmt : public StmtNode
{
private:
    Id *id;
    ExprNode *expr;
public:
    DeclStmt(Id *id) : id(id), expr(nullptr){};
    DeclStmt(Id *id, ExprNode *expr) : id(id), expr(expr){};
    void output(int level);
};

// IF语句
class IfStmt : public StmtNode
{
private:
    ExprNode *cond;
    StmtNode *thenStmt;
public:
    IfStmt(ExprNode *cond, StmtNode *thenStmt) : cond(cond), thenStmt(thenStmt){};
    void output(int level);
};

// IFELSE语句
class IfElseStmt : public StmtNode
{
private:
    ExprNode *cond;
    StmtNode *thenStmt;
    StmtNode *elseStmt;
public:
    IfElseStmt(ExprNode *cond, StmtNode *thenStmt, StmtNode *elseStmt) : cond(cond), thenStmt(thenStmt), elseStmt(elseStmt) {};
    void output(int level);
};

// BREAK语句
class BreakStmt : public StmtNode
{
public:
    BreakStmt(){};
    void output(int level);
};

// CONTINUE语句
class ContinueStmt : public StmtNode
{
public:
    ContinueStmt(){};
    void output(int level);
};

// WHILE语句
class WhileStmt : public StmtNode
{
private:
    ExprNode* cond;
    StmtNode* stmt;
public:
    WhileStmt(ExprNode *cond, StmtNode *stmt) : cond(cond), stmt(stmt) {};
    void output(int level);
};

// 返回语句
class ReturnStmt : public StmtNode
{
private:
    ExprNode *retValue;
public:
    ReturnStmt(ExprNode* retValue) : retValue(retValue) {};
    void output(int level);
};

// 赋值语句
class AssignStmt : public StmtNode
{
private:
    ExprNode *lval;
    ExprNode *expr;
public:
    AssignStmt(ExprNode *lval, ExprNode *expr) : lval(lval), expr(expr) {};
    void output(int level);
};

// 函数定义
class FuncParams;
class FunctionDef : public StmtNode
{
private:
    SymbolEntry *se;
    FuncParams *params;
    StmtNode *stmt;
public:
    FunctionDef(SymbolEntry *se, FuncParams *params, StmtNode *stmt) : se(se), params(params), stmt(stmt) {};
    void output(int level);
};

// 空白语句
class BlankStmt : public StmtNode {
public:
    BlankStmt(){};
    void output(int level);
};

// 调用语句
class CallParams;
class CallExpr : public ExprNode {
private:
    CallParams* params;
public:
    CallExpr(SymbolEntry* se, CallParams* params) : ExprNode(se), params(params) {}
    void output(int level);
};

// 一元运算语句
class UnaryExpr : public ExprNode {
private:
    int op;
    ExprNode* expr;
public:
    enum { ADD, SUB, NOT};
    UnaryExpr(SymbolEntry* se, int op, ExprNode* expr) : ExprNode(se), op(op), expr(expr) {}
    void output(int level);
};

// 表达式语句
class ExprStmt : public StmtNode {
private:
    ExprNode* expr;
public:
    ExprStmt(ExprNode* expr) : expr(expr) {}
    void output(int level);
};

// 函数形参
class FuncParams : public Node
{
private:
    std::vector<Type *> types;
    std::vector<DeclStmt*> decls;
public:
    FuncParams(){}
    void append(Type* t, DeclStmt* s) {
        types.push_back(t);
        decls.push_back(s);
    }
    std::vector<Type *> getTypes() const {return types;};
    std::vector<DeclStmt*> getDecls() const {return decls;}
    void output(int level) {
        for (std::size_t i = 0; i < types.size(); i++) {
            fprintf(yyout, "%*cFuncParams\n", level, ' ');
            if (decls[i]) decls[i]->output(level);
        }
    }
};

// 函数实参
class CallParams : public Node
{
protected:
    std::vector<ExprNode*> params;
public:
    CallParams(){}
    void append(ExprNode* expr){
        params.push_back(expr);
    }
    void output(int level){
        for (std::size_t i = 0; i < params.size(); i++) {
            fprintf(yyout, "%*cCallParams\n", level, ' ');
            if (params[i]) params[i]->output(level + 4);
        }
    }
};

class Ast
{
private:
    Node* root;
public:
    Ast() {root = nullptr;}
    void setRoot(Node*n) {root = n;}
    void output();
};

#endif
