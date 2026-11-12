%{
    #include "y.tab.h"
    #include <stdlib.h>

    int yyerror(const char* message);
%}

%%

[0-9]+"."[0-9]+ {
    yylval.floating = atof(yytext);
    return NUMBER_FLOAT;
}

[0-9]+ {
    yylval.integer = atoi(yytext);
    return NUMBER_INT;
}

"+" {
    return PLUS;
}

"-" {
    return MINUS;
}

"*" {
    return MULTIPLY;
}

"/" {
    return DIVIDE;
}

"mem_write" {
    return MEM_WRITE;
}

"mem_read" {
    return MEM_READ;
}

"mem_free" {
    return MEM_FREE;
}

"int" {
    return TYPE_INT;
}

"float" {
    return TYPE_FLOAT;
}

"string" {
    return TYPE_STRING;
}

"printf" {
    return PRINTF;
}

"printfln" {
    return PRINTFLN;
}

"scanf" {
    return SCANF;
}

"(" {
    return PAREN_LEFT;
}

")" {
    return PAREN_RIGHT;
}

"," {
    return AND;
}

";" {
    return SEMICOLON;
}

\"[^\"\n]*\" {
    yytext[yyleng - 1] = '\0';
    yytext++;

    yylval.string = strdup(yytext);
    return STRING;
}

"//"[^\n]* {}

[ \t\n]+ {}

.   {
    yyerror(yytext);
}

%%

int yywrap(void) {
    return 1;
}