#include "Unit.h"
extern FILE *yyout;

void Unit::insertFunc(Function *f)
{
    func_list.push_back(f);
}

void Unit::removeFunc(Function *func)
{
    func_list.erase(std::find(func_list.begin(), func_list.end(), func));
}

void Unit::output() const
{
    // 输出全局变量
    for (auto &var : global_vars)
    {
        std::string name = var.first->toStr();
        std::string type = var.first->getType()->toStr();
        std::string value = var.second;
        fprintf(yyout, "%s = global %s %s, align 4\n", name.c_str(), type.c_str(), value.c_str());
    }
    if(!global_vars.empty()) fprintf(yyout, "\n");

    // 输出库函数声明
    fprintf(yyout, "declare i32 @getint()\n");
    fprintf(yyout, "declare i32 @getch()\n");
    fprintf(yyout, "declare void @putint(i32)\n");
    fprintf(yyout, "declare void @putch(i32)\n");
    fprintf(yyout, "\n");

    for (auto &func : func_list){
        func->output();
        fprintf(yyout, "\n");
    }
}

Unit::~Unit()
{
    auto delete_list = func_list;
    for(auto &func:delete_list)
        delete func;
}
