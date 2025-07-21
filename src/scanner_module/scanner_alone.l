%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>  // for atoi(), atof()
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
    printf("Comentário de múltiplas linhas\n");
}

<COMENTARIO><<EOF>> {
    printf("erro: comentário não fechado\n");
}

<COMENTARIO>. {} // ignora o resto

"while"|"if"|"else"|"for"|"char"|"int"|"string"|"void"|"return" {
    printf("palavra reservada (%s)\n", yytext);
}


"="|"!"|"+"|"-"|"*"|"/"|"=="|"!="|"<"|">"|"<="|">="|"&&"|"||" {
      printf("operador (%s)\n", yytext);
}



"(" {
    printf("abre parênteses\n");
}

")" {
    printf("fecha parênteses\n");
}

"{" {
    printf("abre chave\n");
}

"}" {
    printf("fecha chave\n");
}

"[" {
    printf("abre colchete\n");
}

"]" {
    printf("fecha colchete\n");
}

";" {
    printf("ponto e vírgula\n");
}

"," {
    printf("vírgula\n");
}


"print" {
    printf("comando de saída (%s)\n", yytext);
}

{DIGITO}+({LETRA}|_)+({LETRA}|{DIGITO}|_)* {
    printf("erro: (%s)\n", yytext);
}

{SINAL}?{DIGITO}+ {
    printf("número inteiro (%s)\n", yytext);
}

{SINAL}?{DIGITO}+"."{DIGITO}* {
    printf("float (%s)\n", yytext);
}

{LETRA}({LETRA}|{DIGITO}|_)* {
    printf("identificador (%s)\n", yytext);
}

'([^\\'\n])'|'\\n'|'\\0'|'\\t' {
    printf("char (%s)\n", yytext);
}

\"[^\n\"]*\" {
    printf("string (%s)\n", yytext);
}

[ \t\n\r]+ {}  // ignora espaços

. {
    printf("caractere inválido: %s\n", yytext);
}

%%
// retirar comentário para usar o scanner isoladamente (sem o parser).

int main() {
    yylex();
    return 0;
}