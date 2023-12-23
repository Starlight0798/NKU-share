#ifndef _BLOCKMERGE_H
#define _BLOCKMERGE_H
#include "Instruction.h"
#include "Type.h"
#include "Unit.h"
#include <set>
#include <unordered_set>

class BlockMerge {
    Unit *unit;
    std::vector<BasicBlock *> mergeList;
    void findBLocks(Function *func);
    void merge(Function*func,BasicBlock *start);
    void replacePhiBB(BasicBlock* succ,BasicBlock* start);
    void printInsts(BasicBlock* start);


  public:
    BlockMerge(Unit *_unit) : unit(_unit) {}
    void execute();
};

#endif