#ifndef __UNIT_H__
#define __UNIT_H__

#include <vector>
#include "Function.h"
#include <utility>

class Unit
{
    typedef std::vector<Function *>::iterator iterator;
    typedef std::vector<Function *>::reverse_iterator reverse_iterator;

private:
    std::vector<Function *> func_list;
    std::vector<std::pair<SymbolEntry *, std::string>> global_vars; // 全局变量

public:
    Unit() = default;
    ~Unit() ;
    void insertFunc(Function *);
    void removeFunc(Function *);
    void output() const;
    iterator begin() { return func_list.begin(); };
    iterator end() { return func_list.end(); };
    reverse_iterator rbegin() { return func_list.rbegin(); };
    reverse_iterator rend() { return func_list.rend(); };

    void insertGlobalVar(SymbolEntry *se, std::string value) { global_vars.push_back(std::make_pair(se, value)); };
};

#endif