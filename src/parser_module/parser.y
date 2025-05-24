%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *s);
int yylex(void);
extern FILE *yyin;  // Declare yyin for file input
%}

/* declaração dos tokens que são retornados pelo lexer */
%token WHILE IF ELSE PRINT CHAR_T INT_T
%token LPAREN RPAREN
%token LCRLY RCRLY
%token INT_LITERAL FLOAT_LITERAL CHAR_LITERAL STRING_LITERAL
%token IDENTIFIER
%token ERROR_TOKEN
%token ';'

/* define o tipo de yylval */
%union {
    int ival;
    float fval;
    char cval;
    char *sval;
}

%type <ival> INT_LITERAL
%type <fval> FLOAT_LITERAL
%type <cval> CHAR_LITERAL
%type <sval> STRING_LITERAL IDENTIFIER



%%

program:
    commands
    ;

commands:
    /* empty */
    | commands statement
    ;

statement:
      simple_statement ';'
    | control_statement
    ;

simple_statement:
      declaration
    | expression
    | print_statement
    ;

declaration:
      INT_T IDENTIFIER  { free($2); }
    | CHAR_T IDENTIFIER { free($2); }
    ;

control_statement:
      IF LPAREN expression RPAREN commands_block
    | IF LPAREN expression RPAREN commands_block ELSE commands_block
    | WHILE LPAREN expression RPAREN commands_block
    ;

commands_block:
    LCRLY commands RCRLY
    ;

expression:
      INT_LITERAL              
    | FLOAT_LITERAL            
    | CHAR_LITERAL             
    | STRING_LITERAL           { free($1); }
    | IDENTIFIER               { free($1); }
    ;

print_statement:
    PRINT LPAREN expression RPAREN
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro: %s\n", s);
}

int main(int argc, char *argv[]) {
    FILE *file = NULL;
    
    if (argc > 1) {
        file = fopen(argv[1], "r");
        if (!file) {
            fprintf(stderr, "Error: Cannot open file '%s'\n", argv[1]);
            return 1;
        }
        yyin = file;
        printf("Parsing file: %s\n", argv[1]);
    } else {
        printf("Reading from stdin (Ctrl+D to end):\n");
        yyin = stdin;
    }
    
    int result = yyparse();
    
    if (file) {
        fclose(file);
    }
    
    if (result == 0) {
        printf("Parsing completed successfully!\n");
    } else {
        printf("Parsing failed with errors.\n");
    }
    
    return result;
}