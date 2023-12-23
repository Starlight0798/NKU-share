#include "Type.h"
#include <sstream>

IntType TypeSystem::commonInt = IntType(4);
VoidType TypeSystem::commonVoid = VoidType();
CharType TypeSystem::commonChar = CharType(1);      // CHAR
BoolType TypeSystem::commonBool = BoolType(1);      // BOOL
FloatType TypeSystem::commonFloat = FloatType(4);   // FLOAT

Type* TypeSystem::intType = &commonInt;
Type* TypeSystem::voidType = &commonVoid;
Type* TypeSystem::charType = &commonChar;   // CHAR
Type* TypeSystem::boolType = &commonBool;   // BOOL
Type* TypeSystem::floatType = &commonFloat; // FLOAT

std::string IntType::toStr()
{
    return "int";
}

// CHAR
std::string CharType::toStr()
{
    return "char";
}

// BOOL
std::string BoolType::toStr()
{
    return "bool";
}

// FLOAT
std::string FloatType::toStr()
{
    return "float";
}

std::string VoidType::toStr()
{
    return "void";
}

std::string FunctionType::toStr()
{
    std::ostringstream buffer;
    buffer << returnType->toStr() << "()";
    return buffer.str();
}
