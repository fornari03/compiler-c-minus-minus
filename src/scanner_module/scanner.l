%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "parser.tab.h"
%}

%option noyywrap

DIGITO  [0-9]
LETRA   [a-zA-Z]

%x COMENTARIO

%%

"/*"            BEGIN(COMENTARIO);
<COMENTARIO>"*/" BEGIN(INITIAL);
<COMENTARIO>.|\n {}

"main"          {return MAIN;}
"while"         {return WHILE;}
"if"            {return IF;}
"else"          {return ELSE;}
"char"          {return CHAR_T;}
"int"           {return INT_T;}
"print"         {return PRINT;}
"println"       {return PRINTLN;}

"=="            {return EQ;}
"!="            {return NE;}
"<="            {return LE;}
">="            {return GE;}
"<"             {return LT;}
">"             {return GT;}
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

"while"|"if"|"else"|"for"|"char"|"int"|"string"|"void"|"return" {
//    printf("palavra reservada (%s)\n", yytext);
    if (strcmp(yytext, "while") == 0) return WHILE;
    if (strcmp(yytext, "if") == 0) return IF;
    if (strcmp(yytext, "else") == 0) return ELSE;
    if (strcmp(yytext, "for") == 0) return FOR;
    if (strcmp(yytext, "char") == 0) return CHAR_T;
    if (strcmp(yytext, "int") == 0) return INT_T;
    //if (strcmp(yytext, "string") == 0) return STRING;
    if (strcmp(yytext, "void") == 0) return VOID;
    if (strcmp(yytext, "return") == 0) return RETURN;
    if (strcmp(yytext, "extern") == 0) return EXTERN;
}


"="|"!"|"+"|"-"|"*"|"/"|"=="|"!="|"<"|">"|"<="|">="|"&&"|"||" {
//      printf("operador (%s)\n", yytext);
    if (strcmp(yytext, "=") == 0) return ATR;
    if (strcmp(yytext, "!") == 0) return NOT;
    if (strcmp(yytext, "+") == 0) return PLUS;
    if (strcmp(yytext, "-") == 0) return MINUS;
    if (strcmp(yytext, "*") == 0) return MUL;
    if (strcmp(yytext, "/") == 0) return DIV;
    if (strcmp(yytext, "==") == 0) return DBEQ;
    if (strcmp(yytext, "!=") == 0) return NTEQ;
    if (strcmp(yytext, "<") == 0) return LT;
    if (strcmp(yytext, ">") == 0) return GT;
    if (strcmp(yytext, "<=") == 0) return LTE;
    if (strcmp(yytext, ">=") == 0) return GTE;
    if (strcmp(yytext, "&&") == 0) return AND;
    if (strcmp(yytext, "||") == 0) return OR;
}



"+"             {return '+';}
"-"             {return '-';}
"*"             {return '*';}
"/"             {return '/';}
"="             {return '=';}
";"             {return ';';}
"("             {return LPAREN;}
")"             {return RPAREN;}
"{"             {return LCRLY;}
"}"             {return RCRLY;}

{DIGITO}+       { yylval.ival = atoi(yytext); return INT_LITERAL; }
{LETRA}({LETRA}|{DIGITO}|_)* { yylval.sval = strdup(yytext); return IDENTIFIER; }
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

"[" {
    return LBRCKT;
}

"]" {
    return RBRCKT;
}

";" {
    return SEMICLN;
}


"," {
    return COMMA;
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
    return INTCON;
}

{SINAL}?{DIGITO}+"."{DIGITO}* {
//    printf("float (%s)\n", yytext);
    yylval.fval = atof(yytext);
    return FLOATCON;
}

{LETRA}({LETRA}|{DIGITO}|_)* {
//    printf("identificador (%s)\n", yytext);
    yylval.sval = strdup(yytext);
    return ID;
}

[ \t\n]+        {}
'([^\\'\n])'|'\\n'|'\\0'|'\\t' {
//    printf("char (%s)\n", yytext);
    yylval.cval = yytext[1];
    return CHARCON;
}

.               { printf("Caractere invalido: %s\n", yytext); return ERROR_TOKEN; }
\"[^\n\"]*\" {
//    printf("string (%s)\n", yytext);
    yylval.sval = strdup(yytext);
    return STRINGCON;
}

[ \t\n\r]+ {}  // ignora espaços

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
