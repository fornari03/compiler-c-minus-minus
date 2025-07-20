%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "geracode.h"

void yyerror(const char *s);
int yylex(void);
extern FILE *yyin;
void translate_to_vm(CodeGenerator* cg);

CodeGenerator* cg;
%}

%union {
    int ival;
    char *sval;
}

%token <sval> IDENTIFIER
%token <ival> INT_LITERAL

%token WHILE IF ELSE PRINT PRINTLN CHAR_T INT_T MAIN ERROR_TOKEN
%token LPAREN RPAREN LCRLY RCRLY EQ NE LT LE GT GE

%type <sval> expression condition
%type <ival> type

%left '+' '-'
%left '*' '/'
%nonassoc '='

%%

program:
    INT_T MAIN LCRLY commands RCRLY {}
    ;

commands:
    /* empty */
    | commands statement
    ;

statement:
    simple_statement ';'
    | control_statement
    ;

/* GRAMÁTICA CORRIGIDA: 'simple_statement' é mais específico agora */
simple_statement:
    declaration
    | assignment
    | print_statement
    | println_statement
    ;

/* NOVA REGRA: 'assignment' para resolver a ambiguidade */
assignment:
    IDENTIFIER '=' expression {
        emit(cg, "%s = %s", $1, $3);
    }
    ;

declaration:
    type IDENTIFIER '=' expression {
        add_symbol(cg, $2, $1);
        emit(cg, "%s = %s", $2, $4);
    }
    | type IDENTIFIER {
        add_symbol(cg, $2, $1);
    }
    ;

type:
    INT_T { $$ = 0; }
    | CHAR_T { $$ = 1; }
    ;

print_statement:
    PRINT LPAREN expression RPAREN {
        emit(cg, "OUT %s", $3);
    }
    ;

println_statement:
    PRINTLN {
        emit(cg, "OUT_NL");
    }
    ;

control_statement:
    WHILE {
            $<sval>$ = (char*)malloc(32);
            char* start_label = new_label(cg);
            char* end_label = new_label(cg);
            sprintf($<sval>$, "%s %s", start_label, end_label);
            emit(cg, "%s:", start_label);
        }
    LPAREN condition RPAREN {
            char start_label[16], end_label[16];
            sscanf($<sval>2, "%s %s", start_label, end_label);
            emit(cg, "JLE %s, %s", $4, end_label);
        }
    LCRLY commands RCRLY {
            char start_label[16], end_label[16];
            sscanf($<sval>2, "%s %s", start_label, end_label);
            emit(cg, "JMP %s", start_label);
            emit(cg, "%s:", end_label);
        }
    ;

condition:
    expression GT expression {
        char* temp = new_temp(cg);
        emit(cg, "%s = %s - %s", temp, $1, $3);
        $$ = temp;
    }
    | expression LT expression {
        char* temp = new_temp(cg);
        emit(cg, "%s = %s - %s", temp, $3, $1);
        $$ = temp;
    }
    ;

/* Expressões não incluem mais a atribuição, que agora é um 'statement' */
expression:
    INT_LITERAL {
        char* val = malloc(32);
        sprintf(val, "%d", $1);
        $$ = val;
    }
    | IDENTIFIER {
        $$ = strdup($1);
    }
    | expression '+' expression {
        char* temp = new_temp(cg);
        emit(cg, "%s = %s + %s", temp, $1, $3);
        $$ = temp;
    }
    | expression '-' expression {
        char* temp = new_temp(cg);
        emit(cg, "%s = %s - %s", temp, $1, $3);
        $$ = temp;
    }
    | expression '*' expression {
        char* temp = new_temp(cg);
        emit(cg, "%s = %s * %s", temp, $1, $3);
        $$ = temp;
    }
    | expression '/' expression {
        char* temp = new_temp(cg);
        emit(cg, "%s = %s / %s", temp, $1, $3);
        $$ = temp;
    }
    | LPAREN expression RPAREN {
        $$ = $2;
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro de sintaxe: %s\n", s);
}

int main(int argc, char *argv[]) {
    cg = init_codegen();
    FILE *file = argc > 1 ? fopen(argv[1], "r") : stdin;
    
    if (!file) {
        fprintf(stderr, "Erro ao abrir arquivo: %s\n", argv[1]);
        return 1;
    }
    
    yyin = file;
    int parse_result = yyparse();
    
    if (file != stdin) fclose(file);
    
    if (parse_result == 0) {
        printf("=== Código de 3 Endereços Gerado ===\n%s\n", cg->code);
        printf("=== Código da VM Traduzido ===\n");
        translate_to_vm(cg);
    } else {
        printf("\nCompilação falhou devido a erros.\n");
    }
    
    free_codegen(cg);
    return parse_result;
}