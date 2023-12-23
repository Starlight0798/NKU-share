#include "IRComSubExprElim.h"
#include <queue>

IRComSubExprElim::IRComSubExprElim(Unit *unit)
{
    this->unit = unit;
}

IRComSubExprElim::~IRComSubExprElim()
{
}

bool IRComSubExprElim::skip(Instruction *inst)
{
    /**
     * 判断当前指令是否可以当成一个表达式
     * 当前只将二元运算指令当作表达式
     * 纯函数及一些一元指令也可当作表达式
     */
    if (dynamic_cast<BinaryInstruction *>(inst) != nullptr)
        return false;
    return true;
}

bool IRComSubExprElim::localCSE(Function *func)
{
    bool result = true;
    std::vector<Expr> exprs;
    for (auto block = func->begin(); block != func->end(); block++)
    {
        exprs.clear();
        for (auto inst = (*block)->begin(); inst != (*block)->end(); inst = inst->getNext())
        {
            if (skip(inst))
                continue;
            auto preInstIt = std::find(exprs.begin(), exprs.end(), Expr(inst));
            if (preInstIt != exprs.end())
            {
                // TODO: 把对当前指令的def的use改成对于preInst的def的use，并删除当前指令。

            }
            else
                exprs.emplace_back(inst);
            /**
             * 这里不需要考虑表达式注销的问题
             * 因为ir是ssa形式的代码，目前来说应该不会有这样的情况，这种是错的
             * a = b + c
             * b = d + f
             */
        }
    }
    return result;
}

bool IRComSubExprElim::globalCSE(Function *func)
{
    exprVec.clear();
    ins2Expr.clear();
    genBB.clear();
    killBB.clear();
    inBB.clear();
    outBB.clear();

    bool result = true; 
    calGenKill(func);
    calInOut(func);
    result = removeGlobalCSE(func);
    return result;
}

void IRComSubExprElim::calGenKill(Function *func)
{
    // 计算gen
    for (auto block = func->begin(); block != func->end(); block++)
    {
        for (auto inst = (*block)->begin(); inst != (*block)->end(); inst = inst->getNext())
        {
            if (skip(inst))
                continue;
            Expr expr(inst);
            // 对于表达式a + b，我们只需要全局记录一次，重复出现的话，用同一个id即可
            auto it = find(exprVec.begin(), exprVec.end(), expr);
            int ind = it - exprVec.begin();
            if (it == exprVec.end())
            {
                exprVec.push_back(expr);
            }
            ins2Expr[inst] = ind;
            genBB[*block].insert(ind);
            /*
                一个基本块内不会出现这种 t1 = t2 + t3
                                       t2 = ...
                所以这里，之后gen的表达式不会kill掉已经gen的表达式
                就算是phi指令，也是并行取值，所以问题不大哦
            */
        }
    }
    // 计算kill
    for (auto block = func->begin(); block != func->end(); block++)
    {
        for (auto inst = (*block)->begin(); inst != (*block)->end(); inst = inst->getNext())
        {
            if (inst->getDef() != nullptr)
            {
                for (auto useInst : inst->getDef()->getUse())
                {
                    if (!skip(useInst))
                        killBB[*block].insert(ins2Expr[useInst]);
                }
            }
        }
    }
}

void IRComSubExprElim::calInOut(Function *func)
{
    std::set<int> U;
    for (size_t i = 0; i < exprVec.size(); i++)
        U.insert(i);
    auto entry = func->getEntry();
    inBB[entry].clear();
    outBB[entry] = genBB[entry];
    // 初始化除entry外的基本块的out为U
    std::set<BasicBlock *> workList;
    for (auto block = func->begin(); block != func->end(); block++)
    {
        if (*block != entry) {
            outBB[*block] = U;
            workList.insert(*block);
        }
    }
    // 不断迭代直到收敛
    while (!workList.empty())
    {
        auto block = *workList.begin();
        workList.erase(workList.begin());
        // 计算in[block] = U outBB[predBB];
        std::set<int> in[2];
        if (block->getNumOfPred() > 0)
            in[0] = outBB[*block->pred_begin()];
        auto it = block->pred_begin();
        it++;
        int turn = 1;
        for (; it != block->pred_end(); it++)
        {
            in[turn].clear();
            std::set_intersection(outBB[*it].begin(), outBB[*it].end(), in[turn ^ 1].begin(), in[turn ^ 1].end(), inserter(in[turn], in[turn].begin()));
            turn ^= 1;
        }
        inBB[block] = in[turn ^ 1];
        // 计算outBB[block] = (inBB[block] - killBB[block]) U genBB[block];
        std::set<int> midDif;
        std::set<int> out;
        std::set_difference(inBB[block].begin(), inBB[block].end(), killBB[block].begin(), killBB[block].end(), inserter(midDif, midDif.begin()));
        std::set_union(genBB[block].begin(), genBB[block].end(), midDif.begin(), midDif.end(), inserter(out, out.begin()));
        if (out != outBB[block])
        {
            outBB[block] = out;
            for (auto succ = block->succ_begin(); succ != block->succ_end(); succ++)
                workList.insert(*succ);
        }
    }
}

bool IRComSubExprElim::removeGlobalCSE(Function *func)
{
    // TODO: 根据计算出的gen kill in out进行全局公共子表达式消除
    return true;
}

void IRComSubExprElim::pass()
{
    for (auto func = unit->begin(); func != unit->end(); func++)
    {
        while (!localCSE(*func) || !globalCSE(*func))
            ;
    }
}
