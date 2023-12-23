#ifndef __AST_H__
#define __AST_H__

#include <fstream>
#include "Operand.h"

#ifndef INFINITE
#define INFINITE 0x3f3f3f3f
#endif

extern int lines, cols; // from lexer
extern SymbolTable *globals;
extern FILE *yyout;

class SymbolEntry;
class Unit;
class Function;
class BasicBlock;
class Instruction;
class IRBuilder;

class Node
{
private:
    static int counter;
    int seq;
protected:
    std::vector<BasicBlock**> true_list;
    std::vector<BasicBlock**> false_list;
    static IRBuilder *builder;
    void backPatch(std::vector<BasicBlock**> &list, BasicBlock*target);
    std::vector<BasicBlock**> merge(std::vector<BasicBlock**> &list1, std::vector<BasicBlock**> &list2);

public:
    Node();
    int getSeq() const {return seq;};
    static void setIRBuilder(IRBuilder*ib) {builder = ib;};
    virtual void output(int level) = 0;
    virtual void typeCheck() = 0;
    virtual void genCode() = 0;
    std::vector<BasicBlock**>& trueList() {return true_list;}
    std::vector<BasicBlock**>& falseList() {return false_list;}
    int line, col;
};

// 表达式
class ExprNode : public Node
{
protected:
    SymbolEntry *symbolEntry;
    Operand *dst;   // The result of the subtree is stored into dst.
public:
    ExprNode(SymbolEntry *symbolEntry) : symbolEntry(symbolEntry){
        line = lines;
        col = cols;
    };
    Operand* getOperand() {return dst;};
    void setOperand(Operand* op) {dst = op;};
    SymbolEntry* getSymPtr() {return symbolEntry;};

    virtual void genBranch() = 0;
    virtual int getValue() = 0;
    IRBuilder *getBuilder() { return builder; }
};

// 二元表达式
class BinaryExpr : public ExprNode
{
private:
    int op;
    ExprNode *expr1, *expr2;
public:
    enum {ADD,SUB,MUL,DIV,MOD,OR,AND,LESS,LESSEQUAL,GREATER,GREATEREQUAL,EQUAL,NOTEQUAL};
    BinaryExpr(SymbolEntry *se, int op, ExprNode*expr1, ExprNode*expr2) : ExprNode(se), op(op), expr1(expr1), expr2(expr2){dst = new Operand(se);};
    void output(int level);
    void typeCheck();
    void genCode();
    void genBranch();
    int getValue();
};

// 常量表达式
class Constant : public ExprNode
{
public:
    Constant(SymbolEntry *se) : ExprNode(se){dst = new Operand(se);};
    void output(int level);
    void typeCheck();
    void genCode();
    void genBranch();
    int getValue();
};

// 标识符
class Id : public ExprNode
{
public:
    Id(SymbolEntry *se) : ExprNode(se){
        SymbolEntry *temp = new TemporarySymbolEntry(se->getType(), SymbolTable::getLabel()); 
        dst = new Operand(temp);
    }
    void output(int level);
    void typeCheck();
    void genCode();
    void genBranch();
    int getValue();
    void setValue(int value);
    bool isConst() const;
};

class StmtNode : public Node
{
public:
    StmtNode() {
        line = lines;
        col = cols;
    }
};

class CompoundStmt : public StmtNode
{
private:
    StmtNode *stmt;
public:
    CompoundStmt(StmtNode *stmt) : stmt(stmt) {};
    void output(int level);
    void typeCheck();
    void genCode();
};

// 语句序列
class SeqNode : public StmtNode
{
private:
    StmtNode *stmt1, *stmt2;
public:
    SeqNode(StmtNode *stmt1, StmtNode *stmt2) : stmt1(stmt1), stmt2(stmt2){};
    void output(int level);
    void typeCheck();
    void genCode();
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
    void typeCheck();
    void genCode();
    SymbolEntry* getSymPtr() {return id->getSymPtr();};
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
    void typeCheck();
    void genCode();
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
    void typeCheck();
    void genCode();
};

// 返回语句
class ReturnStmt : public StmtNode
{
private:
    ExprNode *retValue;
public:
    ReturnStmt(ExprNode*retValue) : retValue(retValue) {};
    void output(int level);
    void typeCheck();
    void genCode();
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
    void typeCheck();
    void genCode();
};


// 函数形参
class FuncParams : public Node
{
private:
    std::vector<Type*> types;
    std::vector<DeclStmt*> decls;
public:
    FuncParams(){}
    void append(Type* t, DeclStmt* s);
    std::vector<Type*> getTypes() const {return types;};
    std::vector<DeclStmt*> getDecls() const {return decls;}
    void output(int level);
    void typeCheck();
    void genCode();
};


// 函数定义
class FunctionDef : public StmtNode
{
private:
    SymbolEntry *se;
    FuncParams *params;
    StmtNode *stmt;
public:
    FunctionDef(SymbolEntry *se, FuncParams *params, StmtNode *stmt) : se(se), params(params), stmt(stmt){};
    void output(int level);
    void typeCheck();
    void genCode();
    void setStmt(StmtNode* stmt) {this->stmt = stmt;}
};

// TODO: 新增语句 -------------------------------------
// BREAK语句
class BreakStmt : public StmtNode
{
private:
    StmtNode* whileStmt;
public:
    BreakStmt(StmtNode* whileStmt):whileStmt(whileStmt){};
    void output(int level);
    void typeCheck();
    void genCode();
};

// CONTINUE语句
class ContinueStmt : public StmtNode
{
private:
    StmtNode* whileStmt;
public:
    ContinueStmt(StmtNode* whileStmt):whileStmt(whileStmt){};
    void output(int level);
    void typeCheck();
    void genCode();
};

// WHILE语句
class WhileStmt : public StmtNode
{
private:
    ExprNode* cond;
    StmtNode* stmt;
    BasicBlock* cond_bb;
    BasicBlock* stmt_bb;
    BasicBlock* end_bb;
public:
    WhileStmt(ExprNode *cond, StmtNode *stmt) : cond(cond), stmt(stmt) {};
    BasicBlock* getCondBB() {return cond_bb;}
    BasicBlock* getStmtBB() {return stmt_bb;}
    BasicBlock* getEndBB() {return end_bb;}
    void setStmt(StmtNode* stmt) {this->stmt = stmt;}
    void output(int level);
    void typeCheck();
    void genCode();
};

// 空白语句
class BlankStmt : public StmtNode {
public:
    BlankStmt(){};
    void output(int level);
    void typeCheck();
    void genCode();
};


// 函数实参
class CallParams : public Node
{
private:
    std::vector<ExprNode*> params;
public:
    CallParams(){}
    void append(ExprNode* expr);
    std::vector<ExprNode*> getParams() const {return params;}
    std::vector<Type*> getTypes() const;
    void output(int level);
    void typeCheck();
    void genCode();
};


// 调用表达式
class CallExpr : public ExprNode {
private:
    CallParams* params;
public:
    CallExpr(SymbolEntry* se, CallParams* params) : ExprNode(se), params(params) {
        dst = new Operand(new TemporarySymbolEntry(
            ((FunctionType *)(symbolEntry->getType()))->getRetType(), 
            SymbolTable::getLabel()));
    }
    void output(int level);
    void typeCheck();
    void genCode();
    void genBranch();
    int getValue();
};

// 一元运算语句
class UnaryExpr : public ExprNode {
private:
    int op;
    ExprNode* expr;
public:
    enum { ADD, SUB, NOT};
    UnaryExpr(SymbolEntry* se, int op, ExprNode* expr) : ExprNode(se), op(op), expr(expr) {dst = new Operand(se);}
    void output(int level);
    void typeCheck();
    void genCode();
    void genBranch();
    int getValue();
};

// 表达式语句
class ExprStmt : public StmtNode {
private:
    ExprNode* expr;
public:
    ExprStmt(ExprNode* expr) : expr(expr) {}
    void output(int level);
    void typeCheck();
    void genCode();
};


class Ast
{
private:
    Node* root;
public:
    Ast() {root = nullptr;}
    void setRoot(Node*n) {root = n;}
    void output();
    void typeCheck();
    void genCode(Unit *unit);
};

#endif
