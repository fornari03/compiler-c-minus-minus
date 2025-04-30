%{
    #include <stdio.h> // para poder usar o printf no lex.yy.c

    // include na tabela para as palavras reservadas -> caso particular de identificador
    // tokens devem ser tuplas de (classe, valor, posição)
%}

/* definitions */
DIGITO  [0-9]
LETRA   [a-zA-Z]
SINAL   [+|-]

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
        return 1;
    }

    <COMENTARIO>. {} // ignora o resto

"while"|"if"|"else"|"char"|"int" {
    printf("palavra reservada (%s)\n", yytext);
}

"(" {
    printf("abre parênteses\n");
}

")" {
    printf("fecha parênteses\n");
}

{DIGITO}+({LETRA}|_)+({LETRA}|{DIGITO}|_)* {
    printf("erro: (%s)\n", yytext);
}


{SINAL}?{DIGITO}+ {
    printf("número inteiro (%s)\n", yytext);
}


{SINAL}?{DIGITO}+"."?{DIGITO}* {
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


[ \t\n]+ {}  // ignora espaços


. {
    printf("caractere inválido: %s\n", yytext);
}

%%

int main() {
    yylex();
    return 0;
}