#include "Type.h"
#include <sstream>

IntType TypeSystem::commonInt = IntType(32);
BoolType TypeSystem::commonBool = BoolType();
VoidType TypeSystem::commonVoid = VoidType();
FloatType TypeSystem::commonFloat = FloatType(32);   // FLOAT

Type* TypeSystem::intType = &commonInt;
Type* TypeSystem::voidType = &commonVoid;
Type* TypeSystem::boolType = &commonBool;
Type* TypeSystem::floatType = &commonFloat;     // FLOAT

std::string IntType::toStr()
{
    std::ostringstream buffer;
    buffer << "i" << size;
    return buffer.str();
}

std::string BoolType::toStr()
{
    return "i1";
}

std::string VoidType::toStr()
{
    return "void";
}

std::string FunctionType::toStr()
{
    std::ostringstream buffer;
    buffer << returnType->toStr() << "(";
    for (auto type = paramsType.begin(); type != paramsType.end(); type++)
    {
        buffer << (*type)->toStr();
        if(type != paramsType.end() - 1)
            buffer << ", ";
    }
    buffer << ")";
    return buffer.str();
}

// FLOAT
std::string FloatType::toStr()
{
    return "f32";
}

std::string PointerType::toStr()
{
    std::ostringstream buffer;
    buffer << valueType->toStr() << "*";
    return buffer.str();
}
