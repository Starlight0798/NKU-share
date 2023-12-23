#ifndef __TYPE_H__
#define __TYPE_H__
#include <vector>
#include <string>

class Type
{
private:
    int kind;
protected:
    enum {INT, VOID, FUNC, CHAR, BOOL, FLOAT}; 
public:
    Type(int kind) : kind(kind) {};
    virtual ~Type() {};
    virtual std::string toStr() = 0;
    bool isInt() const {return kind == INT;};
    bool isVoid() const {return kind == VOID;};
    bool isFunc() const {return kind == FUNC;};
    bool isChar() const {return kind == CHAR;}; 
    bool isBool() const {return kind == BOOL;};
    bool isFloat() const {return kind == FLOAT;};
};

class IntType : public Type
{
private:
    int size;
public:
    IntType(int size) : Type(Type::INT), size(size){};
    std::string toStr();
};

// CHAR
class CharType : public Type
{
private:
    int size;
public:
    CharType(int size) : Type(Type::CHAR), size(size){}
    std::string toStr();
};

// BOOL
class BoolType : public Type
{
private:
    int size;
public:
    BoolType(int size) : Type(Type::BOOL), size(size){}
    std::string toStr();
};

// FLOAT
class FloatType : public Type
{
private:
    int size;
public:
    FloatType(int size) : Type(Type::FLOAT), size(size){}
    std::string toStr();
};

class VoidType : public Type
{
public:
    VoidType() : Type(Type::VOID){};
    std::string toStr();
};

class FunctionType : public Type
{
private:
    Type *returnType;
    std::vector<Type*> paramsType;
public:
    FunctionType(Type* returnType, std::vector<Type*> paramsType) : 
    Type(Type::FUNC), returnType(returnType), paramsType(paramsType){};
    std::string toStr();
};

class TypeSystem
{
private:
    static IntType commonInt;
    static VoidType commonVoid;
    static CharType commonChar; // CHAR
    static BoolType commonBool; // BOOL
    static FloatType commonFloat; // FLOAT
public:
    static Type *intType;
    static Type *voidType;
    static Type *charType;  // CHAR
    static Type *boolType;  // BOOL
    static Type *floatType; // FLOAT
};

#endif
