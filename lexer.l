%{
    #include "y.tab.h"
    #include <stdlib.h>
%}

%%

[0-9]+"."[0-9]+ {
    yylval.floating = atof(yytext);
    return NUMBER_FLOAT;
}

[0-9]+"u" {
    yylval.address = strtoul(yytext, NULL, 16);
    return ADDRESS;
}

[0-9]+ {
    yylval.floating = atof(yytext);
    return NUMBER_FLOAT;
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

"mem_fs" {
    return MEM_FIND_SEQUENCES;
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

"//"[^\n]* {}

[ \t\n]+ {}

%%

int yywrap(void) {
    return 1;
}