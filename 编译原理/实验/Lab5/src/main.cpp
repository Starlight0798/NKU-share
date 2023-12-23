#include <iostream>
#include <string.h>
#include <unistd.h>
#include "common.h"
#include "Ast.h"
#include "Unit.h"
#include "SymbolTable.h"

extern FILE *yyin;
extern FILE *yyout;
int yyparse();

Ast ast;
Unit unit;
char outfile[256] = "a.out";
dump_type_t dump_type = ASM;

int main(int argc, char *argv[])
{
    int opt;
    while ((opt = getopt(argc, argv, "iato:")) != -1)
    {
        switch (opt)
        {
        case 'o':
            strcpy(outfile, optarg);
            break;
        case 'a':
            dump_type = AST;
            break;
        case 't':
            dump_type = TOKENS;
            break;
        case 'i':
            dump_type = IR;
            break;
        default:
            fprintf(stderr, "Usage: %s [-o outfile] infile\n", argv[0]);
            exit(EXIT_FAILURE);
            break;
        }
    }
    if (optind >= argc)
    {
        fprintf(stderr, "no input file\n");
        exit(EXIT_FAILURE);
    }
    if (!(yyin = fopen(argv[optind], "r")))
    {
        fprintf(stderr, "%s: No such file or directory\nno input file\n", argv[optind]);
        exit(EXIT_FAILURE);
    }
    if (!(yyout = fopen(outfile, "w")))
    {
        fprintf(stderr, "%s: fail to open output file\n", outfile);
        exit(EXIT_FAILURE);
    }

    Type* stfunc;
    SymbolEntry* stse;
    std::string name;

    //putint
    name = "putint";
    stfunc = new FunctionType(TypeSystem::voidType, {TypeSystem::intType});
    stse = new IdentifierSymbolEntry(stfunc, name, globals->getLevel());
    globals->install(name, stse);

    //getint
    name = "getint";
    stfunc = new FunctionType(TypeSystem::intType, {});
    stse = new IdentifierSymbolEntry(stfunc, name, globals->getLevel());
    globals->install(name, stse);

    //putch
    name = "putch";
    stfunc = new FunctionType(TypeSystem::voidType, {TypeSystem::intType});
    stse = new IdentifierSymbolEntry(stfunc, name, globals->getLevel());
    globals->install(name, stse);

    //getch
    name = "getch";
    stfunc = new FunctionType(TypeSystem::intType, {});
    stse = new IdentifierSymbolEntry(stfunc, name, globals->getLevel());
    globals->install(name, stse);

    yyparse();
    if(dump_type == AST)
        ast.output();
    ast.typeCheck();
    ast.genCode(&unit);
    if(dump_type == IR)
        unit.output();
    return 0;
}
