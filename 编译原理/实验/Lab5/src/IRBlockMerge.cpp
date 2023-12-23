#include "IRBlockMerge.h"
#include <unordered_set>
#include <vector>


using namespace std;

void BlockMerge::execute() {
    for (auto func = unit->begin(); func != unit->end(); func++){
        findBLocks(*func);
    }
}

// 查找可以合并的块
void BlockMerge::findBLocks(Function *func) {
    for (auto bb : func->getBlockList()) {
        /* 
         * 如果块内存在条件跳转指令，说明该块的后继块可能不止一个，这里不作合并。
         * 不过此处如果实现了其他优化，比如常量传播，进一步导致条件判断恒真/假，
         * 可能会发现有很多分支实际上并不可达，此时即使该块含有cond指令，实际上
         * 仍然是可以考虑与其后继块进行合并的。
         * 另外，此处如果实现了phi指令，同样需要根据phi指令的具体实现进一步考虑
         * 其他情况。
         */

        // TODO: 1. 检查块内是否存在cond指令，后继块数目是否为1 

        BasicBlock *block = bb;
        int succ_num = block->getNumOfSucc();
        if(succ_num>1){
            continue;
        }

        mergeList.clear();
        
        // 依据控制流持续向后合并，直至存在块不可合并
        while (true) {
            // TODO: 2. 检查后继块是否可以合并，包括后继块的前驱块数目等
            bool can_merge = 0;
            // 获取block的后继块succ;
            BasicBlock* succ;

            if (can_merge) {
                mergeList.push_back(succ);
                block = succ;
            } else {
                break;
            }
        }
        // TODO: 3. 合并基本块
        if (mergeList.size() > 0)
            merge(func, bb);
    }
}

// 如果debug时需要查看块内指令信息，可借助该函数
void BlockMerge::printInsts(BasicBlock *start) {
    auto head = start->end();
    for (auto instr = head->getNext(); instr != head;
         instr = instr->getNext()) {
        // 此处可以打印自己想要查看的指令信息
    }
}

void BlockMerge::merge(Function *func, BasicBlock *start) {
    
    // TODO: 1. 处理所有待合并块之间的联系，包括删除冗余的可合并块之间的跳转等；

    for (auto bb : mergeList) {
        std::vector<Instruction *> mergeInst = {};
        auto head = bb->end();
        for (auto instr = head->getNext(); instr != head;
             instr = instr->getNext()) {

            // 此处需要补充对指令的判断与处理
            mergeInst.push_back(instr);

        }

        // TODO: 2. 在合并留下来的唯一块中插入所有被合并块中留下的指令；

        // TODO: 3. 维护块之间的前驱后继关系，将被合并的块从容器中移除。
        // bb->deleteAllRelation();
        func->remove(bb);
    }
}


// 如果实现了phi指令，需要对其进行维护
void BlockMerge::replacePhiBB(BasicBlock *succ, BasicBlock *start) {
    auto head = succ->end();
    for (auto instr = head->getNext(); instr != head;
         instr = instr->getNext()) {
        // if (!instr->isPhi())
        //     continue;
        // PhiInstruction *phi = dynamic_cast<PhiInstruction *>(instr);
        // auto phiBBs = phi->getPhiBBs();
        // auto phiOperands = phi->getPhiOperands();

    }
}