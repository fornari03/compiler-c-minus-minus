%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *s);
int yylex(void);
extern FILE *yyin;  // Declare yyin for file input
%}

/* declaração dos tokens que são retornados pelo lexer */
%token ID INTCON CHARCON STRINGCON
%token VOID CHAR INT EXTERN
%token MINUS NOT COMMA SEMICLN /*'-' '!' ',' ';'*/
%token LPAREN RPAREN LBRCKT RBRCKT LCRLY RCRLY /*'(' ')' '[' ']' '{' '}'*/
%token PLUS MUL DIV /*'+' '*' '/'*/ 
%token DBEQ NTEQ LTE LT GTE GT /*"==" "!=" "<=" '<' ">=" '>'*/
%token AND OR /*"&&" "||"*/
%token EQ /*'='*/
%token IF ELSE WHILE FOR RETURN /*"if" "else" "while" "for" "return"*/

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
    |prog opt_dcl_func
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
    CHAR
    |INT
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
    ID opt_assg_expr EQ expr
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