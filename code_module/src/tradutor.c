#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include "tradutor.h"

#define MAX_REGS 9
#define PRINTLN_REG 8

typedef struct { char name[100]; int line; } LabelMap;
typedef struct { char name[100]; int reg_num; } RegisterMap;

int get_or_create_reg(const char* name, RegisterMap* reg_map, int* reg_count) {
    for (int i = 0; i < *reg_count; i++) {
        if (strcmp(name, reg_map[i].name) == 0) return reg_map[i].reg_num;
    }
    if (*reg_count >= (MAX_REGS - 1)) {
        return (*reg_count - 2);
    }
    strcpy(reg_map[*reg_count].name, name);
    reg_map[*reg_count].reg_num = *reg_count;
    return (*reg_count)++;
}

void translate_to_vm(CodeGenerator* cg) {
    if (!cg || !cg->code) return;

    LabelMap label_map[256];
    int label_count = 0;
    RegisterMap reg_map[MAX_REGS];
    int reg_count = 0;
    
    char* code_copy_pass1 = strdup(cg->code);
    char* line = strtok(code_copy_pass1, "\n");
    int line_num = 0;
    while(line) {
        if (strlen(line) > 1 && line[strlen(line)-1] == ':') {
            sscanf(line, "%[^:]:", label_map[label_count].name);
            label_map[label_count].line = line_num;
            label_count++;
        } else {
           line_num++; 
        }
        line = strtok(NULL, "\n");
    }
    free(code_copy_pass1);
    
    char* code_copy_pass2 = strdup(cg->code);
    line = strtok(code_copy_pass2, "\n");
    while (line) {
        char arg1[100], arg2[100], arg3[100], op[20], keyword[20];

        int r_dest, r_op1, r_op2;
        
        if (sscanf(line, "%s = %s %s %s", arg1, arg2, op, arg3) == 4) {
            r_dest = get_or_create_reg(arg1, reg_map, &reg_count);
            if (isdigit(arg2[0]) || (arg2[0] == '-' && isdigit(arg2[1]))) {
                r_op1 = get_or_create_reg("temp_literal", reg_map, &reg_count);
                printf("LDC %d,%s(0)\n", r_op1, arg2);
            } else { r_op1 = get_or_create_reg(arg2, reg_map, &reg_count); }
            if (isdigit(arg3[0]) || (arg3[0] == '-' && isdigit(arg3[1]))) {
                r_op2 = get_or_create_reg("temp_literal2", reg_map, &reg_count);
                printf("LDC %d,%s(0)\n", r_op2, arg3);
            } else { r_op2 = get_or_create_reg(arg3, reg_map, &reg_count); }
            const char* vm_op = !strcmp(op, "+") ? "ADD" : !strcmp(op, "-") ? "SUB" : !strcmp(op, "*") ? "MUL" : "DIV";
            printf("%s %d,%d,%d\n", vm_op, r_dest, r_op1, r_op2);
        }
        else if (sscanf(line, "%s = %s", arg1, arg2) == 2) {
            r_dest = get_or_create_reg(arg1, reg_map, &reg_count);
            if (isdigit(arg2[0]) || (arg2[0] == '-' && isdigit(arg2[1]))) {
                printf("LDC %d,%s(0)\n", r_dest, arg2);
            } else {
                r_op1 = get_or_create_reg(arg2, reg_map, &reg_count);
                printf("ADD %d,%d,0\n", r_dest, r_op1);
            }
        }
        else if (sscanf(line, "%s %s , %s", keyword, arg1, arg2) == 3 && strcmp(keyword, "JLE") == 0) {
            r_op1 = get_or_create_reg(arg1, reg_map, &reg_count);
            int target_line = -1;
            for(int i=0; i<label_count; i++) if(strcmp(arg2, label_map[i].name) == 0) target_line = label_map[i].line;
            printf("JLE %d,%d(0)\n", r_op1, target_line);
        }
        else if (sscanf(line, "%s %s", keyword, arg1) == 2 && strcmp(keyword, "JMP") == 0) {
            int target_line = -1;
            for(int i=0; i<label_count; i++) if(strcmp(arg1, label_map[i].name) == 0) target_line = label_map[i].line;
            printf("JEQ 0,%d(0)\n", target_line);
        }
        else if (sscanf(line, "%s %s", keyword, arg1) == 2 && strcmp(keyword, "OUT") == 0) {
            if (isdigit(arg1[0]) || (arg1[0] == '-' && isdigit(arg1[1]))) {
                r_op1 = get_or_create_reg("temp_literal", reg_map, &reg_count);
                printf("LDC %d,%s(0)\n", r_op1, arg1);
                printf("OUT %d,0,0\n", r_op1);
            } else {
                r_op1 = get_or_create_reg(arg1, reg_map, &reg_count);
                printf("OUT %d,0,0\n", r_op1);
            }
        }
        else if(strcmp(line, "OUT_NL") == 0) {
            printf("LDC %d,10(0)\n", PRINTLN_REG);
            printf("OUT %d,0,0\n", PRINTLN_REG);
        }

        line = strtok(NULL, "\n");
    }

    printf("HALT 0,0,0\n");
    free(code_copy_pass2);
}