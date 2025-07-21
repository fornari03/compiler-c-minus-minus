%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex(void);
extern FILE *yyin;  // Declare yyin for file input

typedef struct SymbolTableReg {
    char *name;     /* identifier name */
    int used;       /* 0 == false; 1 == true */
    struct SymbolTableReg *nxt;
} SymbolTableReg;

//typedef struct SymbolTableReg SymbolTableReg;
SymbolTableReg *table = (SymbolTableReg*) 0;
int semanticError = 0;

void addSymbol(char *name, int used) {
    SymbolTableReg *ptr;
    ptr = (SymbolTableReg*) malloc(sizeof(SymbolTableReg));

    ptr->name = (char*) malloc(strlen(name)+1);

    strcpy(ptr->name, name);
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

void declareSymbol(char *name, int isVar) {
    if (inTable(name)) {
        // redeclaration of a variable
        semanticError = 1;
        printf("\nSemantic Error: redeclaration of variable or function \"%s\"\n", name);
    } else {
        addSymbol(name, !isVar);

        if (isVar)
            printf("\nVariable \"%s\" declared\n", name);
        else
            printf("\nFunction \"%s\" declared\n", name);
    }
}

void setUsed(char *name, int used) {
    SymbolTableReg *ptr = table;
    while (ptr != (SymbolTableReg*)0) {
        if (strcmp(ptr->name, name) == 0) {
            ptr->used = used;
            return;
        }

        ptr = (SymbolTableReg*)ptr->nxt;
    }
}

%}
%union {
    char *sval;
    int ival;
    char cval;
}

/* declaração dos tokens que são retornados pelo lexer */
%token <sval> ID STRINGCON
%token INTCON CHARCON
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
all:
    prog {
        if (semanticError) {
            printf("\nSemantic error: some symbol was used without being declared, or was redeclared.\n");
        } else {
            int hasWarning = 0;
            
            int numWarnings = 0;
            SymbolTableReg *ptr = (SymbolTableReg*) table;
            while (ptr != (SymbolTableReg*)0) {
                if (!ptr->used) {
                    hasWarning = 1;
                    numWarnings++;
                }

                ptr = ptr->nxt;
            }

            if (hasWarning && numWarnings > 0) {
                printf("\nWarning: %d variables were declared but not used.\n", numWarnings);
            }

            printf("\nNo syntax or semantyc errors.\n");
        }
    }
    ;

prog:
    |prog opt_dcl_func
    ;
    
opt_dcl_func:
    dcl SEMICLN
    |func
    ;

dcl:
    type var_decl opt_var_decl_seq
    |EXTERN type ID LPAREN parm_types RPAREN opt_id_parmtypes_seq { declareSymbol($<sval>3, 0); }
    |type ID LPAREN parm_types RPAREN opt_id_parmtypes_seq { declareSymbol($<sval>2, 0); }
    |EXTERN ID LPAREN parm_types RPAREN opt_id_parmtypes_seq { declareSymbol($<sval>2, 0); }
    |ID LPAREN parm_types RPAREN opt_id_parmtypes_seq { declareSymbol($<sval>1, 0); }
    ;

opt_id_parmtypes_seq: |COMMA ID LPAREN parm_types RPAREN ;

var_decl: ID opt_intcon_brckt { declareSymbol($<sval>1, 1); };

opt_intcon_brckt: |LBRCKT INTCON RBRCKT ;

type:
    CHAR_T
    |INT_T
    ;

parm_types:
    VOID
    |type ID opt_brckts opt_parm_types_seq { declareSymbol($<sval>2, 1); }
    ;

opt_parm_types_seq:
    |opt_parm_types_seq COMMA type ID opt_brckts { declareSymbol($<sval>4, 1); }
    ;

opt_brckts: | LBRCKT RBRCKT ;

func:
    type ID LPAREN parm_types RPAREN LCRLY func_body RCRLY { declareSymbol($<sval>2, 0); }
    |VOID ID LPAREN parm_types RPAREN LCRLY func_body RCRLY { declareSymbol($<sval>2, 0); }
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
    |RETURN opt_expr SEMICLN
    |assg SEMICLN
    |ID LPAREN id_seq RPAREN SEMICLN {
        if (!inTable($<sval>1)) {
            printf("\nSemantic Error: Variable or function %s used before being declared.\n", $<sval>1);
            semanticError = 1;
        } else {
            printf("\nFunction %s used\n", $<sval>1);
            setUsed($<sval>1, 1);
        }
    }
    |LCRLY star_stmt RCRLY
    |SEMICLN
        ;

opt_expr: |expr ;
opt_assg: |assg ;

assg:
    ID opt_assg_expr ATR expr {
        if (!inTable($<sval>1)) {
            printf("\nSemantic Error: Variable %s used before being declared.\n", $<sval>1);
            semanticError = 1;
        } else {
            printf("\nVariable %s used\n", $<sval>1);
            setUsed($<sval>1, 1);
        }
    }
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
    |ID id_expr {
        if (!inTable($<sval>1)) {
            printf("\nSemantic Error: Variable or function \"%s\" used before being declared.\n", $<sval>1);
            semanticError = 1;
        } else {
            printf("\nVariable or function \"%s\" used\n", $<sval>1);
            setUsed($<sval>1, 1);
        }
    }
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