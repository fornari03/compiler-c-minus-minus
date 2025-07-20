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

[ \t\n]+        {}

.               { printf("Caractere invalido: %s\n", yytext); return ERROR_TOKEN; }

%%
