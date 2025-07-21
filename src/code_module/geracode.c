#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "geracode.h"

CodeGenerator* init_codegen() {
    CodeGenerator* cg = malloc(sizeof(CodeGenerator));
    if (!cg) {
        perror("Falha ao alocar CodeGenerator");
        exit(EXIT_FAILURE);
    }

    cg->code = malloc(1024);
    cg->code[0] = '\0';
    cg->temp_count = 0;
    cg->label_count = 0;
    cg->symbol_table = NULL;
    cg->mem_offset = 0;

    memset(cg->temp_names, 0, sizeof(cg->temp_names));
    memset(cg->label_names, 0, sizeof(cg->label_names));

    return cg;
}

void free_codegen(CodeGenerator* cg) {
    if (!cg) return;

    free(cg->code);

    Symbol* current = cg->symbol_table;
    while (current) {
        Symbol* next = current->next;
        free(current->name);
        free(current);
        current = next;
    }

    for (int i = 0; i < MAX_TEMP_LABELS; i++) {
        free(cg->temp_names[i]);
        free(cg->label_names[i]);
    }

    free(cg);
}

void emit(CodeGenerator* cg, const char* format, ...) {
    va_list args;
    va_start(args, format);
    
    int needed = vsnprintf(NULL, 0, format, args) + 1;
    va_end(args);
    
    char* buffer = malloc(needed);
    va_start(args, format);
    vsnprintf(buffer, needed, format, args);
    va_end(args);

    size_t new_size = strlen(cg->code) + needed + 1;
    cg->code = realloc(cg->code, new_size);
    strcat(cg->code, buffer);
    strcat(cg->code, "\n");
    
    free(buffer);
}

char* new_temp(CodeGenerator* cg) {
    if (cg->temp_count >= MAX_TEMP_LABELS) {
        fprintf(stderr, "Erro: Limite de temporários atingido\n");
        return NULL;
    }
    
    if (!cg->temp_names[cg->temp_count]) {
        char name[16];
        snprintf(name, sizeof(name), "t%d", cg->temp_count);
        cg->temp_names[cg->temp_count] = strdup(name);
    }
    
    return cg->temp_names[cg->temp_count++];
}

char* new_label(CodeGenerator* cg) {
    if (cg->label_count >= MAX_TEMP_LABELS) {
        fprintf(stderr, "Erro: Limite de rótulos atingido\n");
        return NULL;
    }
    
    if (!cg->label_names[cg->label_count]) {
        char name[16];
        snprintf(name, sizeof(name), "L%d", cg->label_count);
        cg->label_names[cg->label_count] = strdup(name);
    }
    
    return cg->label_names[cg->label_count++];
}

Symbol* add_symbol(CodeGenerator* cg, const char* name, int type) {
    if (find_symbol(cg, name)) {
        fprintf(stderr, "Variável '%s' já declarada\n", name);
        return NULL;
    }

    Symbol* sym = malloc(sizeof(Symbol));
    sym->name = strdup(name);
    sym->type = type;
    sym->address = cg->mem_offset; 
    sym->reg_num = cg->mem_offset++; 
    sym->scope = 0;
    sym->next = cg->symbol_table;
    cg->symbol_table = sym;
    
    return sym;
}

Symbol* find_symbol(CodeGenerator* cg, const char* name) {
    Symbol* current = cg->symbol_table;
    while (current) {
        if (strcmp(current->name, name) == 0) return current;
        current = current->next;
    }
    return NULL;
}