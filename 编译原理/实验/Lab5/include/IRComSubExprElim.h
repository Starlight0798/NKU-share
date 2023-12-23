#ifndef __IRCOMSUBEXPRELIM_H__
#define __IRCOMSUBEXPRELIM_H__

#include "Unit.h"

struct Expr
{
    Instruction *inst;
    Expr(Instruction *inst) : inst(inst){};
    // 用于调用find函数
    bool operator==(const Expr &other) const
    {
        // TODO: 判断两个表达式是否相同
        // 两个表达式相同 <==> 两个表达式对应的指令的类型和操作数均相同
        return false;
    };
};

class IRComSubExprElim
{
private:
    Unit *unit;

    std::vector<Expr> exprVec;
    std::map<Instruction *, int> ins2Expr;
    std::map<BasicBlock *, std::set<int>> genBB;
    std::map<BasicBlock *, std::set<int>> killBB;
    std::map<BasicBlock *, std::set<int>> inBB;
    std::map<BasicBlock *, std::set<int>> outBB;

    // 跳过无需分析的指令
    bool skip(Instruction *);

    // 局部公共子表达式消除
    bool localCSE(Function *);

    // 全局公共子表达式消除
    bool globalCSE(Function *);
    void calGenKill(Function*);
    void calInOut(Function*);
    bool removeGlobalCSE(Function*);

public:
    IRComSubExprElim(Unit *unit);
    ~IRComSubExprElim();
    void pass();
};

#endif