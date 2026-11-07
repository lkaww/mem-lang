%{
    #include <stdio.h>
    #include <string.h>

    void mem_write(unsigned int address, float value);
    float mem_read(unsigned int address);
    void mem_free(unsigned int address);
    unsigned int mem_find_sequences(float value);


    int yyerror(const char* message);
    int yylex(void);
    extern FILE* yyin;
%}

%union {
    float floating;
    unsigned int address;
}

%token <floating> NUMBER_FLOAT
%token <address> ADDRESS
%token MEM_WRITE MEM_READ MEM_FREE MEM_FIND_SEQUENCES
%token PAREN_LEFT PAREN_RIGHT
%token AND SEMICOLON

%type <floating> exp_float
%type <address> exp_address

%%

input:
    %empty
|   input line;
;

line:
    exp_float SEMICOLON {
        printf("%f\n", $1);
    }

|   exp_address SEMICOLON {
        printf("%u\n", $1);
    }
;

exp_float:
    NUMBER_FLOAT {
        $$ = $1;
    }

|   MEM_WRITE PAREN_LEFT ADDRESS AND NUMBER_FLOAT PAREN_RIGHT {
        mem_write($3, $5);
    }

|   MEM_FIND_SEQUENCES PAREN_LEFT NUMBER_FLOAT PAREN_RIGHT {
        mem_find_sequences($3);
    }
;

exp_address:
    ADDRESS {
        $$ = $1;
    }

|   exp_float MEM_READ PAREN_LEFT ADDRESS PAREN_RIGHT {
        $1 = mem_read($4);
    }

|   MEM_FREE PAREN_LEFT ADDRESS PAREN_RIGHT {
        mem_free($3);
    }
;

%%

void mem_write(unsigned int address, float value) {

}

float mem_read(unsigned int address) {
    return 1.00f;
}

void mem_free(unsigned int address) {

}

unsigned int mem_find_sequences(float value) {
    return 1;
}

int yyerror(const char* message) {
    fprintf(stderr, "error: %s\n", message);
    return 0;
}

int main(int argc, char* argv[]) {
    //if (argv[1].strrchr("", '.') && strcmp(argv[1].strrchr("", '.'), ".mem") == 0)

    yyin = fopen(argv[1], "r");

    if (yyin == NULL)
    {
        printf("error: no such file or directory\n");
        return 1;
    }

    fclose(yyin);

    return yyparse();
}