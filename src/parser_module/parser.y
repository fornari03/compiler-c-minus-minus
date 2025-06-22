%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex(void);
extern FILE *yyin;  // Declare yyin for file input

typedef struct SymbolTableReg {
    char *name;     /* identifier name */
    char *type;     /* type: "int" or "char" */
    int used;       /* 0 == false; 1 == true */
    struct SymbolTableReg *nxt;
} SymbolTableReg;

//typedef struct SymbolTableReg SymbolTableReg;
SymbolTableReg *table = (SymbolTableReg*) 0;
int semanticError = 0;

void addSymbol(char *name, char* type, int used) {
    SymbolTableReg *ptr;
    ptr = (SymbolTableReg*) malloc(sizeof(SymbolTableReg));

    ptr->name = (char*) malloc(strlen(name)+1);
    ptr->type = (char*) malloc(strlen(type)+1);

    strcpy(ptr->name, name);
    strcpy(ptr->type, type);
    ptr->used = used;

    ptr->nxt = (struct SymbolTableReg*) table;
    table = ptr;
}

int inTable(char *name) {
    SymbolTableReg *ptr = table;
    while (ptr != (SymbolTableReg*)0) {
        if (strcmp(ptr->name, name) == 0) return 1;

        ptr = (SymbolTableReg*)ptr->nxt;
    }
    return 0;
}

%}
%union {
    char *sval;
    float fval;
    int ival;
    char cval;
}

/* declaração dos tokens que são retornados pelo lexer */
%token <sval> ID STRINGCON
%token INTCON CHARCON FLOATCON
%token VOID CHAR_T INT_T EXTERN
%token MINUS NOT COMMA SEMICLN /*'-' '!' ',' ';'*/
%token LPAREN RPAREN LBRCKT RBRCKT LCRLY RCRLY /*'(' ')' '[' ']' '{' '}'*/
%token PLUS MUL DIV /*'+' '*' '/'*/ 
%token DBEQ NTEQ LTE LT GTE GT /*"==" "!=" "<=" '<' ">=" '>'*/
%token AND OR /*"&&" "||"*/
%token ATR /*'='*/
%token IF ELSE WHILE FOR RETURN /*"if" "else" "while" "for" "return"*/
%token ERROR_TOKEN /* erro, n sei como tratar isso aqui */
%token PRINT /* tbm n sei o que fazer por enquanto, ta aqui pra deixar compilar */

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%left OR
%left AND
%left DBEQ NTEQ
%left LT GT LTE GTE
%left PLUS MINUS
%left MUL DIV
%right NOT UMINUS


%%
prog:
    |prog opt_dcl_func {
        if (semanticError) {
            printf("\nSemantic error: some symbol was used without being declared.\n");
        } else {
            int hasWarning = 0;
            
            int numWarnings = 0;
            SymbolTableReg *ptr = (SymbolTableReg*) table;
            while (ptr != (SymbolTableReg*)0) {
                if (!ptr->used) {
                    hasWarning = 1;
                    numWarnings++;
                }
            }

            if (hasWarning && numWarnings > 0) {
                printf("\nWarning: %d variables were declared but not used.\n", numWarnings);
            }

            printf("\nNo syntax or semantyc errors.\n");
        }
    }
    ;
    
opt_dcl_func:
    dcl SEMICLN
    |func
    ;

dcl:
    type var_decl opt_var_decl_seq
    |EXTERN type ID LPAREN parm_types RPAREN opt_id_parmtypes_seq
    |type ID LPAREN parm_types RPAREN opt_id_parmtypes_seq
    |EXTERN ID LPAREN parm_types RPAREN opt_id_parmtypes_seq
    |ID LPAREN parm_types RPAREN opt_id_parmtypes_seq
    ;

opt_id_parmtypes_seq: |COMMA ID LPAREN parm_types RPAREN ;

var_decl: ID opt_intcon_brckt ;

opt_intcon_brckt: |LBRCKT INTCON RBRCKT ;

type:
    CHAR_T
    |INT_T
    ;

parm_types:
    VOID
    |type ID opt_brckts opt_parm_types_seq
    ;

opt_parm_types_seq:
    |opt_parm_types_seq COMMA type ID opt_brckts
    ;

opt_brckts: | LBRCKT RBRCKT ;

func:
    type ID LPAREN parm_types RPAREN LCRLY func_body RCRLY
    |VOID ID LPAREN parm_types RPAREN LCRLY func_body RCRLY
    ;

func_body:
    | func_body type var_decl opt_var_decl_seq SEMICLN star_stmt
    ;

opt_var_decl_seq:
    |opt_var_decl_seq COMMA var_decl
    ;

star_stmt: |star_stmt stmt ;

stmt:
    IF LPAREN expr RPAREN stmt %prec LOWER_THAN_ELSE
    |IF LPAREN expr RPAREN stmt ELSE stmt
    |WHILE LPAREN expr RPAREN stmt
    |FOR LPAREN opt_assg SEMICLN opt_expr SEMICLN opt_assg RPAREN stmt
    |RETURN opt_expr
    ;

opt_expr: |expr ;
opt_assg: |assg ;

assg:
    ID opt_assg_expr ATR expr
    ;

opt_assg_expr:
    | LBRCKT expr RBRCKT
    ;
expr:
    MINUS expr %prec UMINUS
    |NOT expr
    |expr binop expr 
    |expr relop expr
    |expr logical_op expr
    |ID id_expr
    |LPAREN expr RPAREN
    |INTCON
    |CHARCON
    |STRINGCON
    ;

id_expr:
    | LPAREN id_seq RPAREN
    | LBRCKT expr RBRCKT
    ;

id_seq:
    | expr opt_expr_seq
    ;

opt_expr_seq:
    | opt_expr_seq COMMA expr
    ;

binop:
    PLUS
    |MINUS
    |MUL
    |DIV
    ;

relop:
    DBEQ
    | NTEQ
    | LTE
    | LT
    | GTE
    | GT
    ;

logical_op:
    AND
    | OR
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