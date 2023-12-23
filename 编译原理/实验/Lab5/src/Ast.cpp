#include "Ast.h"
#include "Unit.h"
#include "SymbolTable.h"
#include "Instruction.h"
#include "IRBuilder.h"
#include <string>
#include "Type.h"


int Node::counter = 0;
IRBuilder* Node::builder = nullptr;
static FunctionType* parrent = nullptr; // 用于辅助判断return语句是否合法
extern Unit unit;

// 检查是否为Bool类型，若不是则强制转换为Bool类型
static void checkBool(ExprNode* &expr, int line, int col) {
    Type *type = expr->getSymPtr()->getType();
    if(type->isFunc()) type = ((FunctionType*)type)->getRetType();
    if(!type->isBool()){
        // INT -> BOOL
        if(type->isInt()){
            SymbolEntry *se = new TemporarySymbolEntry(TypeSystem::boolType, SymbolTable::getLabel());
            ExprNode* zero = new Constant(new ConstantSymbolEntry(type, 0));
            expr = new BinaryExpr(se, BinaryExpr::NOTEQUAL, expr, zero);
        }
        // 无法转换为bool
        else{
            fprintf(stderr, "type %s is not applicable for boolType in line %d, col %d\n", type->toStr().c_str(), line, col);
            exit(EXIT_FAILURE);
        }
    }
}

// 检查是否为Int类型，若不是则强制转换为Int类型
static void checkInt(ExprNode* &expr, int line, int col) {
    Type *type = expr->getSymPtr()->getType();
    if(type->isFunc()) type = ((FunctionType*)type)->getRetType();
    if(!type->isInt()){
        // BOOL -> INT
        if(type->isBool()){
            Operand* dst = new Operand(new TemporarySymbolEntry(TypeSystem::intType, SymbolTable::getLabel()));
            new ZextInstruction(dst, expr->getOperand(), expr->getBuilder()->getInsertBB());
            expr->setOperand(dst);
        }
        // 无法转换为int
        else{
            fprintf(stderr, "type %s is not applicable for intType in line %d, col %d\n", type->toStr().c_str(), line, col);
            exit(EXIT_FAILURE);
        }
    }
}

// 检查表达式是否为常量, 如果是则转换为常量，简化代码生成
static int checkConst(ExprNode* &expr){
    int value = expr->getValue();
    if(value != INFINITE){
        SymbolEntry *se = new ConstantSymbolEntry(TypeSystem::intType, value);
        expr = new Constant(se);
        return value;
    }
    return INFINITE;
}

Node::Node()
{
    seq = counter++;
}

void Node::backPatch(std::vector<BasicBlock**> &list, BasicBlock* target)
{
    for(auto &bb : list){
        *bb = target;
    }
}

std::vector<BasicBlock**> Node::merge(std::vector<BasicBlock**> &list1, std::vector<BasicBlock**> &list2)
{
    std::vector<BasicBlock**> res(list1);
    res.insert(res.end(), list2.begin(), list2.end());
    return res;
}


// TODO BEGIN genCode ------------------------------------------------------------------
void Ast::genCode(Unit *unit)
{
    IRBuilder *builder = new IRBuilder(unit);
    Node::setIRBuilder(builder);
    root->genCode();
}

void FunctionDef::genCode()
{
    Unit *unit = builder->getUnit();
    Function *func = new Function(unit, se, params);
    BasicBlock *entry = func->getEntry();
    // set the insert point to the entry basicblock of this function.
    builder->setInsertBB(entry);

    // 生成参数代码
    params->genCode();

    stmt->genCode();

    /**
     * Construct control flow graph. You need do set successors and predecessors for each basic block.
     * for each basic block. Todo
    */
    bool existRet = false;
    for(auto block = func->begin(); block != func->end(); block++){
        // 清除RET之后的指令
        BasicBlock* bb = *block;
        Instruction* inst = bb->begin();
        bool ret = false;
        while(inst && inst != bb->end()){
            if(ret){
                Instruction* tmp = inst;
                inst = inst->getNext();
                bb->remove(tmp);
                continue;
            }
            if(inst->isRet()) {
                ret = true;
                existRet = true;
            }
            inst = inst->getNext();
        }

        // 判断最后一条指令是否为条件跳转或无条件跳转
        Instruction* lastinst = bb->rbegin();
        if(lastinst){
            // 条件跳转
            if(lastinst->isCond()){
                CondBrInstruction* condinst = dynamic_cast<CondBrInstruction*>(lastinst);
                BasicBlock* truebb = condinst->getTrueBranch();
                BasicBlock* falsebb = condinst->getFalseBranch();
                bb->addSucc(truebb);
                bb->addSucc(falsebb);
                truebb->addPred(bb);
                falsebb->addPred(bb);
            }
            // 无条件跳转
            else if(lastinst->isUncond()){
                UncondBrInstruction* uncondinst = dynamic_cast<UncondBrInstruction*>(lastinst);
                BasicBlock* branchbb = uncondinst->getBranch();
                bb->addSucc(branchbb);
                branchbb->addPred(bb);
            } 
        }
    }
    // 不存在Return语句
    if(!existRet){
        Type* rettype = dynamic_cast<FunctionType*>(se->getType())->getRetType();
        if(rettype->isVoid()){
            // void返回值可以没有return语句
            new RetInstruction(nullptr, builder->getInsertBB());
        }
        else{
            fprintf(stderr, "Function %s has no return statement\n", se->toStr().c_str());
            exit(EXIT_FAILURE);
        }
    }
}

void BinaryExpr::genCode()
{
    BasicBlock *bb = builder->getInsertBB();
    Function *func = bb->getParent();
    if (op == AND)
    {
        BasicBlock *trueBB = new BasicBlock(func);  // if the result of lhs is true, jump to the trueBB.
        expr1->genBranch();
        backPatch(expr1->trueList(), trueBB);
        builder->setInsertBB(trueBB);               // set the insert point to the trueBB so that intructions generated by expr2 will be inserted into it.
        expr2->genBranch();
        true_list = expr2->trueList();
        false_list = merge(expr1->falseList(), expr2->falseList());
    }
    else if(op == OR)
    {
        // Todo
        // 只有expr1为false时才会求expr2
        BasicBlock *falseBB = new BasicBlock(func);
        expr1->genBranch();
        backPatch(expr1->falseList(), falseBB);
        builder->setInsertBB(falseBB);
        expr2->genBranch();
        true_list = merge(expr1->trueList(), expr2->trueList());
        false_list = expr2->falseList();
    }
    else{
        expr1->genCode();
        expr2->genCode();
        // 类型不同进行转换
        Type *type1 = expr1->getSymPtr()->getType();
        Type *type2 = expr2->getSymPtr()->getType();
        if(type1->isFunc()) type1 = ((FunctionType*)type1)->getRetType();
        if(type2->isFunc()) type2 = ((FunctionType*)type2)->getRetType();

        if(type2->isInt()) checkInt(expr1, line, col);
        if(type1->isInt()) checkInt(expr2, line, col);

        if(op >= LESS && op <= NOTEQUAL){
            // Todo
            Operand *src1 = expr1->getOperand();
            Operand *src2 = expr2->getOperand();
            int opcode;
            switch (op)
            {
            case LESS:
                opcode = CmpInstruction::L;
                break;
            case LESSEQUAL:
                opcode = CmpInstruction::LE;
                break;
            case GREATER:
                opcode = CmpInstruction::G;
                break;
            case GREATEREQUAL:
                opcode = CmpInstruction::GE;
                break;
            case EQUAL:
                opcode = CmpInstruction::E;
                break;
            case NOTEQUAL:
                opcode = CmpInstruction::NE;
                break;
            default:
                opcode = -1;
                break;
            }
            new CmpInstruction(opcode, dst, src1, src2, bb);
        }
        else if(op >= ADD && op <= MOD){
            Operand *src1 = expr1->getOperand();
            Operand *src2 = expr2->getOperand();
            int opcode;
            switch (op)
            {
            case ADD:
                opcode = BinaryInstruction::ADD;
                break;
            case SUB:
                opcode = BinaryInstruction::SUB;
                break;
            case MUL:
                opcode = BinaryInstruction::MUL;
                break;
            case DIV:
                opcode = BinaryInstruction::DIV;
                break;
            case MOD:
                opcode = BinaryInstruction::MOD;
                break;
            default:
                opcode = -1;
                break;
            }
            new BinaryInstruction(opcode, dst, src1, src2, bb);
        }
    }
}

void Constant::genCode()
{
    // do nothing
}

void Id::genCode()
{
    BasicBlock *bb = builder->getInsertBB();
    Operand *addr = dynamic_cast<IdentifierSymbolEntry*>(symbolEntry)->getAddr();
    new LoadInstruction(dst, addr, bb);
}

void IfStmt::genCode()
{
    int value = checkConst(cond);
    if(value == INFINITE){
        Function *func = builder->getInsertBB()->getParent();
        BasicBlock *then_bb=  new BasicBlock(func);
        BasicBlock *end_bb = new BasicBlock(func);

        cond->genBranch();
        backPatch(cond->trueList(), then_bb);
        backPatch(cond->falseList(), end_bb);

        builder->setInsertBB(then_bb);
        thenStmt->genCode();
        then_bb = builder->getInsertBB();
        new UncondBrInstruction(end_bb, then_bb);

        builder->setInsertBB(end_bb);
    }
    else if(value != 0) thenStmt->genCode();
}

void IfElseStmt::genCode()
{
    // Todo
    int value = checkConst(cond);
    if(value == INFINITE){
        Function *func = builder->getInsertBB()->getParent();
        BasicBlock *then_bb, *else_bb, *end_bb;
        then_bb = new BasicBlock(func);
        else_bb = new BasicBlock(func);
        end_bb = new BasicBlock(func);

        cond->genBranch();
        backPatch(cond->trueList(), then_bb);
        backPatch(cond->falseList(), else_bb);

        builder->setInsertBB(then_bb);
        thenStmt->genCode();
        then_bb = builder->getInsertBB();
        new UncondBrInstruction(end_bb, then_bb);

        builder->setInsertBB(else_bb);
        elseStmt->genCode();
        else_bb = builder->getInsertBB();
        new UncondBrInstruction(end_bb, else_bb);
    
        builder->setInsertBB(end_bb);
    }
    else if(value == 0) elseStmt->genCode();
    else thenStmt->genCode();
}

void CompoundStmt::genCode()
{
    // Todo
    if (stmt) stmt->genCode();
}

void SeqNode::genCode()
{
    // Todo
    if (stmt1) stmt1->genCode();
    if (stmt2) stmt2->genCode();
}

void DeclStmt::genCode()
{
    IdentifierSymbolEntry *se = dynamic_cast<IdentifierSymbolEntry *>(id->getSymPtr());
    if(se->isGlobal())
    {
        if(se->isConst()) return;
        Operand *addr;
        SymbolEntry *addr_se;
        addr_se = new IdentifierSymbolEntry(*se);
        addr_se->setType(new PointerType(se->getType()));
        addr = new Operand(addr_se);
        se->setAddr(addr);

        // 把全局变量插入到全局变量表中
        Unit *unit = builder->getUnit();
        int init_value = INFINITE;
        if(expr) init_value = expr->getValue();
        // 有常量初值
        if(init_value != INFINITE){
            unit->insertGlobalVar(se, std::to_string(init_value));
        }
        // 无常量初值
        else{
            unit->insertGlobalVar(se, "0");
        }
    }
    else if(se->isLocal())
    {
        Function *func = builder->getInsertBB()->getParent();
        BasicBlock *entry = func->getEntry();

        Type *type = new PointerType(se->getType());
        SymbolEntry *addr_se = new TemporarySymbolEntry(type, SymbolTable::getLabel());
        Operand *addr = new Operand(addr_se);
        Instruction *alloca = new AllocaInstruction(addr, se);      // allocate space for local id in function stack.
        
        entry->insertFront(alloca);                                 // allocate instructions should be inserted into the begin of the entry block.
        se->setAddr(addr);     
        
        if(expr){
            expr->genCode();
            Operand *src = expr->getOperand();
            new StoreInstruction(addr, src, builder->getInsertBB());
        }                                     // set the addr operand in symbol entry so that we can use it in subsequent code generation.
    }
    else if(se->isParam())
    {
        // Todo
        Function *func = builder->getInsertBB()->getParent();
        BasicBlock *entry = func->getEntry();

        Type *type = new PointerType(se->getType());
        SymbolEntry *addr_se = new TemporarySymbolEntry(type, SymbolTable::getLabel());
        Operand *addr = new Operand(addr_se);
        Instruction *alloca = new AllocaInstruction(addr, se);            

        entry->insertFront(alloca);                               
        se->setAddr(addr);     

        Operand *src = new Operand(se);
        new StoreInstruction(addr, src, builder->getInsertBB());             
    }
}

void ReturnStmt::genCode()
{
    // Todo
    BasicBlock *bb = builder->getInsertBB();
    if(retValue){
        retValue->genCode();
        Operand *src = retValue->getOperand();
        new RetInstruction(src, bb);
    }
    else{
        new RetInstruction(nullptr, bb);
    }
}

void AssignStmt::genCode()
{
    BasicBlock *bb = builder->getInsertBB();
    expr->genCode();
    Operand *addr = dynamic_cast<IdentifierSymbolEntry*>(lval->getSymPtr())->getAddr();
    Operand *src = expr->getOperand();
    /***
     * We haven't implemented array yet, the lval can only be ID. So we just store the result of the `expr` to the addr of the id.
     * If you want to implement array, you have to caculate the address first and then store the result into it.
     */
    new StoreInstruction(addr, src, bb);
}


void FuncParams::genCode(){
    for(std::size_t i = 0; i < decls.size(); i++){
        decls[i]->genCode();
    }
}

void BreakStmt::genCode(){
    Function* func = builder->getInsertBB()->getParent();
    BasicBlock* bb = builder->getInsertBB();
    BasicBlock* endbb = ((WhileStmt*)whileStmt)->getEndBB();
    new UncondBrInstruction(endbb, bb);     // 跳转到循环结束的BB
    BasicBlock* next_bb = new BasicBlock(func);
    builder->setInsertBB(next_bb);
}

void ContinueStmt::genCode(){
    Function* func = builder->getInsertBB()->getParent();
    BasicBlock* bb = builder->getInsertBB();
    BasicBlock* condbb = ((WhileStmt*)whileStmt)->getCondBB();
    new UncondBrInstruction(condbb, bb);    // 跳转到循环条件的BB
    BasicBlock* next_bb = new BasicBlock(func);
    builder->setInsertBB(next_bb);
}

void WhileStmt::genCode(){
    Function* func = builder->getInsertBB()->getParent();
    BasicBlock* bb = builder->getInsertBB();

    cond_bb = new BasicBlock(func);
    stmt_bb = new BasicBlock(func);
    end_bb = new BasicBlock(func);
    
    new UncondBrInstruction(cond_bb, bb);
    builder->setInsertBB(cond_bb);
    cond->genBranch();
    backPatch(cond->trueList(), stmt_bb);
    backPatch(cond->falseList(), end_bb);

    builder->setInsertBB(stmt_bb);
    stmt->genCode();
    bb = builder->getInsertBB();
    new UncondBrInstruction(cond_bb, bb);

    builder->setInsertBB(end_bb);
}

void BlankStmt::genCode(){
    // do nothing
}

void CallParams::genCode(){
    // do nothing
}

void CallExpr::genCode(){
    std::vector<Operand*> operands;
    for(ExprNode* expr : params->getParams()){
        expr->genCode();
        operands.push_back(expr->getOperand());
    }
    BasicBlock* bb = builder->getInsertBB();
    new CallInstruction(dst, symbolEntry, operands, bb);
}

void UnaryExpr::genCode(){
    BasicBlock* bb = builder->getInsertBB();
    expr->genCode();
    int opcode;
    Operand *src1, *src2;
    Type* type = expr->getSymPtr()->getType();
    if(type->isFunc()) type = ((FunctionType*)type)->getRetType();
    if(op == ADD || op == SUB){
        checkInt(expr, line, col);  // 检查是否是Int
    }   
    switch(op){
    case ADD:
        dst = expr->getOperand();
        break;
    case SUB:
        opcode = BinaryInstruction::SUB;
        src1 = new Operand(new ConstantSymbolEntry(TypeSystem::intType, 0));
        src2 = expr->getOperand();
        new BinaryInstruction(opcode, dst, src1, src2, bb);
        break;
    case NOT:
        // 如果是INT，比较是否为0
        if(type->isInt()){
            opcode = CmpInstruction::E;
            Operand *zero = new Operand(new ConstantSymbolEntry(TypeSystem::intType, 0));
            new CmpInstruction(opcode, dst, expr->getOperand(), zero, bb);
        }
        // 如果是BOOL，同样比较是否为0
        else if(type->isBool()){
            opcode = CmpInstruction::E;
            Operand *zero = new Operand(new ConstantSymbolEntry(TypeSystem::boolType, 0));
            new CmpInstruction(opcode, dst, expr->getOperand(), zero, bb);
        }
        else{
            fprintf(stderr, "Unary expr type %s not implemented in line %d, col %d\n", type->toStr().c_str(), line, col);
        }
        break;
    default:
        break;
    }
}

void ExprStmt::genCode(){
    expr->genCode();
}


// TODO BEGIN typeCheck ------------------------------------------------------------------
void Ast::typeCheck()
{
    if(root) root->typeCheck();
}

void FunctionDef::typeCheck()
{
    // Todo
    parrent = dynamic_cast<FunctionType*>(se->getType());
    stmt->typeCheck();
    parrent = nullptr;
}

void BinaryExpr::typeCheck()
{
    // Todo
    checkConst(expr1);
    checkConst(expr2);
    Type *type1 = expr1->getSymPtr()->getType();
    Type *type2 = expr2->getSymPtr()->getType();
    if(type1->isFunc()) type1 = ((FunctionType*)type1)->getRetType();
    if(type2->isFunc()) type2 = ((FunctionType*)type2)->getRetType();
    if(type1->isVoid() || type2->isVoid()){
        fprintf(stderr, "BinaryExpr found voidType in line %d, col %d\n", line, col);
        exit(EXIT_FAILURE);
    }
    if(op == AND || op == OR){
        checkBool(expr1, line, col);
        checkBool(expr2, line, col);
    }
    expr1->typeCheck();
    expr2->typeCheck();
}

void Constant::typeCheck()
{
    // do nothing
}

void Id::typeCheck()
{
    // do nothing
}

void IfStmt::typeCheck()
{
    // Todo
    checkBool(cond, line, col);
    checkConst(cond);
    cond->typeCheck();
    thenStmt->typeCheck();
}

void IfElseStmt::typeCheck()
{
    // Todo
    checkBool(cond, line, col);
    checkConst(cond);
    cond->typeCheck();
    thenStmt->typeCheck();
    elseStmt->typeCheck();
}

void CompoundStmt::typeCheck()
{
    // Todo
    if (stmt) stmt->typeCheck();
}

void SeqNode::typeCheck()
{
    // Todo
    if (stmt1) stmt1->typeCheck();
    if (stmt2) stmt2->typeCheck();
}

void DeclStmt::typeCheck()
{
    // Todo
    if (expr == nullptr) return;
    checkConst(expr);
    expr->typeCheck();
    Type* type1 = id->getSymPtr()->getType();
    Type* type2 = expr->getSymPtr()->getType();
    if(type2->isFunc()) type2 = ((FunctionType*)type2)->getRetType();
    if(type1->isVoid() || type2->isVoid()){
        fprintf(stderr, "DeclStmt found voidType in line %d, col %d\n", line, col);
        exit(EXIT_FAILURE);
    }
    if(type1 != type2){
        fprintf(stderr, "DeclStmt type %s and %s mismatch in line %d, col %d\n",
        type1->toStr().c_str(), type2->toStr().c_str(), line, col);
        exit(EXIT_FAILURE);
    }
    if(id->isConst()){
        id->setValue(expr->getValue());
    }
}

void ReturnStmt::typeCheck()
{
    // Todo
    if(parrent){
        Type* type1 = parrent->getRetType();
        Type* type2 = TypeSystem::voidType;
        if(retValue) {
            checkConst(retValue);
            retValue->typeCheck();
            type2 = retValue->getSymPtr()->getType();
            if(type2->isFunc()) type2 = ((FunctionType*)type2)->getRetType();
        }
        if(type1 != type2){
            fprintf(stderr, "ReturnStmt type %s and %s mismatch in line %d, col %d\n",
            type1->toStr().c_str(), type2->toStr().c_str(), line, col);
            exit(EXIT_FAILURE);
        }
    }
    else {
        fprintf(stderr, "return statement not in function in line %d, col %d\n", line, col);
        exit(EXIT_FAILURE);
    }
}

void AssignStmt::typeCheck()
{
    // Todo
    checkConst(expr);
    lval->typeCheck();
    expr->typeCheck();
    Id *id = dynamic_cast<Id*>(lval);
    if(id->isConst()){
        fprintf(stderr, "AssignStmt const %s cannot be assigned in line %d, col %d\n", id->getSymPtr()->toStr().c_str(), line, col);
        exit(EXIT_FAILURE);
    }
    Type* type1 = lval->getSymPtr()->getType();
    Type* type2 = expr->getSymPtr()->getType();
    if(type1->isFunc()) type1 = ((FunctionType*)type1)->getRetType();
    if(type2->isFunc()) type2 = ((FunctionType*)type2)->getRetType();
    if(type1->isVoid() || type2->isVoid()){
        fprintf(stderr, "AssignStmt found voidType in line %d, col %d\n", line, col);
        exit(EXIT_FAILURE);
    }
    if(type1 == type2) return;
    if(type1->isBool()){
        checkBool(expr, line, col);
    }
    else{
        fprintf(stderr, "AssignStmt type %s and %s mismatch in line %d, col %d\n",
        type1->toStr().c_str(), type2->toStr().c_str(), line, col);
        exit(EXIT_FAILURE);
    }
}

void FuncParams::typeCheck(){
    for(std::size_t i = 0; i < decls.size(); i++){
        decls[i]->typeCheck();
    }
}

void BreakStmt::typeCheck() {
    if(whileStmt == nullptr){
        fprintf(stderr, "break statement not within loop in line %d, col %d\n", line, col);
        exit(EXIT_FAILURE);
    }
}   

void ContinueStmt::typeCheck(){
    if(whileStmt == nullptr){
        fprintf(stderr, "continue statement not within loop in line %d, col %d\n", line, col);
        exit(EXIT_FAILURE);
    }
}

void WhileStmt::typeCheck(){
    checkBool(cond, line, col);
    checkConst(cond);
    cond->typeCheck();
    if(stmt) stmt->typeCheck();
}

void BlankStmt::typeCheck(){
    // do nothing
}

void CallParams::typeCheck(){
    // do nothing
}

void CallExpr::typeCheck(){
    for(ExprNode* &expr : params->getParams()){
        checkConst(expr);
    }
}

void UnaryExpr::typeCheck(){
    checkConst(expr);
    expr->typeCheck();
    Type *type = expr->getSymPtr()->getType();
    if(type->isVoid()){
        fprintf(stderr, "Unary cannot be applied to type %s in line %d, col %d\n", expr->getSymPtr()->getType()->toStr().c_str(), line, col);
        exit(EXIT_FAILURE);
    }
}

void ExprStmt::typeCheck(){
    checkConst(expr);
    expr->typeCheck();
}


// TODO BEGIN output ------------------------------------------------------------------
void BinaryExpr::output(int level)
{
    std::string op_str;
    switch(op)
    {
        case ADD:
            op_str = "add";
            break;
        case SUB:
            op_str = "sub";
            break;
        case MUL:
            op_str = "mul";
            break;
        case DIV:
            op_str = "div";
            break;
        case MOD:
            op_str = "mod";
            break;
        case AND:
            op_str = "and";
            break;
        case OR:
            op_str = "or";
            break;
        case LESS:
            op_str = "less";
            break;
        case LESSEQUAL:
            op_str = "less equal";
            break;
        case GREATER:
            op_str = "greater";
            break;
        case GREATEREQUAL:
            op_str = "greater equal";
            break;
        case EQUAL:
            op_str = "equal";
            break;
        case NOTEQUAL:
            op_str = "not equal";
            break;
    }
    std::string type = symbolEntry->getType()->toStr();
    fprintf(yyout, "%*cBinaryExpr\top: %s\tType: %s\n", level, ' ', op_str.c_str(), type.c_str());
    expr1->output(level + 4);
    expr2->output(level + 4);
}

void Ast::output()
{
    fprintf(yyout, "program\n");
    if(root != nullptr)
        root->output(4);
}

void Constant::output(int level)
{
    std::string type, value;
    type = symbolEntry->getType()->toStr();
    value = symbolEntry->toStr();
    fprintf(yyout, "%*cIntegerLiteral\tvalue: %s\ttype: %s\n", level, ' ',
            value.c_str(), type.c_str());
}

void Id::output(int level)
{
    std::string name, type;
    int scope;
    name = symbolEntry->toStr();
    type = symbolEntry->getType()->toStr();
    scope = dynamic_cast<IdentifierSymbolEntry*>(symbolEntry)->getScope();
    fprintf(yyout, "%*cId\tname: %s\tscope: %d\ttype: %s\n", level, ' ',
            name.c_str(), scope, type.c_str());
}

void CompoundStmt::output(int level)
{
    fprintf(yyout, "%*cCompoundStmt\n", level, ' ');
    if (stmt) stmt->output(level + 4);
}

void SeqNode::output(int level)
{
    if (stmt1) stmt1->output(level);
    if (stmt2) stmt2->output(level);
}

void DeclStmt::output(int level)
{
    fprintf(yyout, "%*cDeclStmt\n", level, ' ');
    id->output(level + 4);
    if(expr) expr->output(level + 4);
}

void IfStmt::output(int level)
{
    fprintf(yyout, "%*cIfStmt\n", level, ' ');
    cond->output(level + 4);
    thenStmt->output(level + 4);
}

void IfElseStmt::output(int level)
{
    fprintf(yyout, "%*cIfElseStmt\n", level, ' ');
    cond->output(level + 4);
    thenStmt->output(level + 4);
    elseStmt->output(level + 4);
}

void ReturnStmt::output(int level)
{
    fprintf(yyout, "%*cReturnStmt\n", level, ' ');
    if (retValue) retValue->output(level + 4);
}

void AssignStmt::output(int level)
{
    fprintf(yyout, "%*cAssignStmt\n", level, ' ');
    lval->output(level + 4);
    expr->output(level + 4);
}

void FunctionDef::output(int level)
{
    std::string name, type;
    name = se->toStr();
    type = se->getType()->toStr();
    fprintf(yyout, "%*cFunctionDef function name: %s, type: %s\n", level, ' ', 
            name.c_str(), type.c_str());
    params->output(level + 4);
    stmt->output(level + 4);
}


void FuncParams::output(int level) {
    fprintf(yyout, "%*cFuncParams\n", level, ' ');
    for (std::size_t i = 0; i < types.size(); i++) {
        decls[i]->output(level + 4);
    }
}

void BreakStmt::output(int level){
    fprintf(yyout, "%*cBreakStmt\n", level, ' ');
}

void ContinueStmt::output(int level){
    fprintf(yyout, "%*cContinueStmt\n", level, ' ');
}

void WhileStmt::output(int level){
    fprintf(yyout, "%*cWhileStmt\n", level, ' ');
    cond->output(level + 4);
    stmt->output(level + 4);
}

void BlankStmt::output(int level){
    fprintf(yyout, "%*cBlankStmt\n", level, ' ');
}

void CallParams::output(int level){
    fprintf(yyout, "%*cCallParams\n", level, ' ');
    for (std::size_t i = 0; i < params.size(); i++) {
        params[i]->output(level + 4);
    }
}

void CallExpr::output(int level){
    std::string name, type;
    name = symbolEntry->toStr();
    type = symbolEntry->getType()->toStr();
    fprintf(yyout, "%*cCallExpr function name: %s, type: %s\n", level, ' ', 
            name.c_str(), type.c_str());
    if(params) params->output(level + 4);
}

void UnaryExpr::output(int level){
    std::string op_str;
    switch(op)
    {
        case ADD:
            op_str = "add";
            break;
        case SUB:
            op_str = "minus";
            break;
        case NOT:
            op_str = "not";
            break;
    }
    fprintf(yyout, "%*cUnaryExpr\top: %s\n", level, ' ', op_str.c_str());
    expr->output(level + 4);
}

void ExprStmt::output(int level){
    fprintf(yyout, "%*cExprStmt\n", level, ' ');
    expr->output(level + 4);
}

// TODO BEGIN genBranch ------------------------------------------------------------------
void BinaryExpr::genBranch(){
    this->genCode();
    if(op >= LESS && op <= NOTEQUAL){
        BasicBlock* bb = builder->getInsertBB();
        Function *func = bb->getParent();
        BasicBlock* truebb = new BasicBlock(func);
        BasicBlock* falsebb = new BasicBlock(func);
        CondBrInstruction* cond = new CondBrInstruction(truebb, falsebb, dst, bb);
        true_list.push_back(cond->patchBranchTrue());
        false_list.push_back(cond->patchBranchFalse());
    }
}

void UnaryExpr::genBranch(){
    this->genCode();
    BasicBlock* bb = builder->getInsertBB();
    Function *func = bb->getParent();
    BasicBlock* truebb = new BasicBlock(func);
    BasicBlock* falsebb = new BasicBlock(func);
    CondBrInstruction* cond = new CondBrInstruction(truebb, falsebb, dst, bb);
    true_list.push_back(cond->patchBranchTrue());
    false_list.push_back(cond->patchBranchFalse());
}

void Constant::genBranch(){
    this->genCode();
}

void Id::genBranch(){
    this->genCode();
}

void CallExpr::genBranch(){
    this->genCode();
}

// TODO BEGIN getValue --------------------------------------------------------------------
int BinaryExpr::getValue(){
    int val1 = expr1->getValue();
    int val2 = expr2->getValue();
    if(val1 == INFINITE || val2 == INFINITE) return INFINITE;
    switch(op){
        case ADD:
            return val1 + val2;
        case SUB:
            return val1 - val2;
        case MUL:
            return val1 * val2;
        case DIV:
            return val1 / val2;
        case MOD:
            return val1 % val2;
        case AND:
            return val1 && val2;
        case OR:
            return val1 || val2;
        case LESS:
            return val1 < val2;
        case LESSEQUAL:
            return val1 <= val2;
        case GREATER:
            return val1 > val2;
        case GREATEREQUAL:
            return val1 >= val2;
        case EQUAL:
            return val1 == val2;
        case NOTEQUAL:
            return val1 != val2;
        default:
            return INFINITE;
    }
}

int UnaryExpr::getValue(){
    int val = expr->getValue();
    if(val == INFINITE) return INFINITE;
    switch(op){
        case ADD:
            return val;
        case SUB:
            return -val;
        case NOT:
            return !val;
        default:
            return INFINITE;
    }
}

int Constant::getValue(){
    return dynamic_cast<ConstantSymbolEntry*>(symbolEntry)->getValue();
}

int Id::getValue(){
    return dynamic_cast<IdentifierSymbolEntry*>(symbolEntry)->getValue();
}

int CallExpr::getValue(){
    return INFINITE;
}

// TODO BEGIN other func ------------------------------------------------------------------
void FuncParams::append(Type* t, DeclStmt* s) {
    types.push_back(t);
    decls.push_back(s);
}

void CallParams::append(ExprNode* expr){
    params.push_back(expr);
}

std::vector<Type*> CallParams::getTypes() const{
    std::vector<Type*> types;
    for (std::size_t i = 0; i < params.size(); i++) {
        types.push_back(params[i]->getSymPtr()->getType());
    }
    return types;
}

void Id::setValue(int value) {
    dynamic_cast<IdentifierSymbolEntry*>(symbolEntry)->setValue(value);
}

bool Id::isConst() const {
    return dynamic_cast<IdentifierSymbolEntry*>(symbolEntry)->isConst();
}