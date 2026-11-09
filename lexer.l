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

"mem_write" {
    return MEM_WRITE;
}

"mem_read" {
    return MEM_READ;
}

"mem_free" {
    return MEM_FREE;
}

"printf" {
    return PRINTF;
}

"%f" {
    return F;
}

"%i" {
    return I;
}

"%s" {
    return S;
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