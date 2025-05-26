%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>  // for atoi(), atof()

    #include "parser.tab.h" 
%}

/* definitions */
DIGITO  [0-9]
LETRA   [a-zA-Z]
SINAL   [+-]

/* estado exclusivo */
%x COMENTARIO

%%

"/*" {
    BEGIN(COMENTARIO);
}

<COMENTARIO>[^*]+ {} // ignora tudo que não é '*'

<COMENTARIO>"*/" {
    BEGIN(INITIAL);
//    printf("Comentário de múltiplas linhas\n");
}

<COMENTARIO><<EOF>> {
    printf("erro: comentário não fechado\n");
    return ERROR_TOKEN;
}

<COMENTARIO>. {} // ignora o resto

"while"|"if"|"else"|"for"|"char"|"int"|"string"|"void" {
//    printf("palavra reservada (%s)\n", yytext);
    if (strcmp(yytext, "while") == 0) return WHILE;
    if (strcmp(yytext, "if") == 0) return IF;
    if (strcmp(yytext, "else") == 0) return ELSE;
    if (strcmp(yytext, "for") == 0) return FOR;
    if (strcmp(yytext, "char") == 0) return CHAR_T;
    if (strcmp(yytext, "int") == 0) return INT_T;
    if (strcmp(yytext, "string") == 0) return STRING;
    if (strcmp(yytext, "void") == 0) return VOID;
}


"="|"!"|"+"|"-"|"*"|"/"|"=="|"!="|"<"|">"|"<="|">="|"&&"|"||" {
//      printf("operador (%s)\n", yytext);
    if (strcmp(yytext, "=") == 0) return ATR;
    if (strcmp(yytext, "!") == 0) return NOT;
    if (strcmp(yytext, "+") == 0) return PLUS;
    if (strcmp(yytext, "-") == 0) return MINUS;
    if (strcmp(yytext, "*") == 0) return MULT;
    if (strcmp(yytext, "/") == 0) return DIV;
    if (strcmp(yytext, "==") == 0) return EQUALS;
    if (strcmp(yytext, "!=") == 0) return NOT_EQUALS;
    if (strcmp(yytext, "<") == 0) return LESS_THAN;
    if (strcmp(yytext, ">") == 0) return MORE_THAN;
    if (strcmp(yytext, "<=") == 0) return LESS_EQUAL;
    if (strcmp(yytext, ">=") == 0) return MORE_EQUAL;
    if (strcmp(yytext, "&&") == 0) return AND_OP;
    if (strcmp(yytext, "||") == 0) return OR_OP;
}



"(" {
//    printf("abre parênteses\n");
    return LPAREN;
}

")" {
//    printf("fecha parênteses\n");
    return RPAREN;
}

"{" {
    return LCRLY;
}

"}" {
    return RCRLY;
}

";" {
    return ';';
}

"print" {
//    printf("comando de saída (%s)\n", yytext);
    return PRINT;
}

{DIGITO}+({LETRA}|_)+({LETRA}|{DIGITO}|_)* {
    printf("erro: (%s)\n", yytext);
    return ERROR_TOKEN;
}

{SINAL}?{DIGITO}+ {
//    printf("número inteiro (%s)\n", yytext);
    yylval.ival = atoi(yytext);
    return INT_LITERAL;
}

{SINAL}?{DIGITO}+"."{DIGITO}* {
//    printf("float (%s)\n", yytext);
    yylval.fval = atof(yytext);
    return FLOAT_LITERAL;
}

{LETRA}({LETRA}|{DIGITO}|_)* {
//    printf("identificador (%s)\n", yytext);
    yylval.sval = strdup(yytext);
    return IDENTIFIER;
}

'([^\\'\n])'|'\\n'|'\\0'|'\\t' {
//    printf("char (%s)\n", yytext);
    yylval.cval = yytext[1];
    return CHAR_LITERAL;
}

\"[^\n\"]*\" {
//    printf("string (%s)\n", yytext);
    yylval.sval = strdup(yytext);
    return STRING_LITERAL;
}

[ \t\n]+ {}  // ignora espaços

. {
    printf("caractere inválido: %s\n", yytext);
    return ERROR_TOKEN;
}

%%
// retirar comentário para usar o scanner isoladamente (sem o parser).
/*
int main() {
    yylex();
    return 0;
}
*/