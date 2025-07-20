#ifndef GERACODE_H
#define GERACODE_H
#ifndef _POSIX_C_SOURCE
#define _POSIX_C_SOURCE 200809L  // Para strdup()
#endif

#include <stdio.h>    
#include <stdlib.h>   
#include <string.h>   
#include <stdarg.h>   

#define MAX_TEMP_LABELS 512  


typedef struct CodeGenerator CodeGenerator;

// Tabela de símbolos
typedef struct Symbol {
    char* name;
    int type;
    int address; 
    int reg_num; 
    int scope;
    struct Symbol* next;
} Symbol;

// Estrutura completa do gerador de código
struct CodeGenerator {
    char* code;
    int temp_count;
    int label_count;
    Symbol* symbol_table;
    int mem_offset;
    char* temp_names[512];
    char* label_names[512];
};

// Protótipos das funções
CodeGenerator* init_codegen();
void free_codegen(CodeGenerator* cg);
char* new_temp(CodeGenerator* cg);
char* new_label(CodeGenerator* cg);
void emit(CodeGenerator* cg, const char* format, ...);
Symbol* add_symbol(CodeGenerator* cg, const char* name, int type);
Symbol* find_symbol(CodeGenerator* cg, const char* name);
void emit_store(CodeGenerator* cg, const char* dest, const char* src);
void emit_load(CodeGenerator* cg, const char* dest, const char* src);

#endif