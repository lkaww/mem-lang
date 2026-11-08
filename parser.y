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
    char* string;
}

%token <floating> NUMBER_FLOAT
%token <address> ADDRESS
%token <string> STRING
%token MEM_WRITE MEM_READ MEM_FREE MEM_FIND_SEQUENCES
%token PRINTF F U
%token PAREN_LEFT PAREN_RIGHT
%token AND SEMICOLON

%type <floating> exp_float
%type <address> exp_address
%type <string> exp_string

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

|   exp_string SEMICOLON {
        printf("%s\n", $1);
    }
;

exp_float:
    NUMBER_FLOAT {
        $$ = $1;
    }

|   MEM_WRITE PAREN_LEFT exp_address AND exp_float PAREN_RIGHT {
        mem_write($3, $5);
    }

|   MEM_READ PAREN_LEFT exp_address PAREN_RIGHT {
        $$ = mem_read($3);
    }

|   PRINTF PAREN_LEFT F AND exp_float PAREN_RIGHT {
        printf("%f",$5 );
    }    
;

exp_address:
    ADDRESS {
        $$ = $1;
    }

|   MEM_FIND_SEQUENCES PAREN_LEFT exp_float PAREN_RIGHT {
        $$ = mem_find_sequences($3);
    }

|   MEM_FREE PAREN_LEFT exp_address PAREN_RIGHT {
        mem_free($3);
    }

|   PRINTF PAREN_LEFT U AND exp_address PAREN_RIGHT {
        printf("%u", $5);
    }
;

exp_string:
    STRING {
        $$ = $1;
    }

|   PRINTF PAREN_LEFT exp_string PAREN_RIGHT {
        printf("%s", $3);
    }

|   PRINTF PAREN_LEFT exp_string AND F AND exp_float PAREN_RIGHT {
        printf("%s %f", $3, $7);
    }

|   PRINTF PAREN_LEFT exp_string AND U AND exp_address PAREN_RIGHT {
        printf("%s %u", $3, $7);
    }

|   PRINTF PAREN_LEFT F AND exp_float AND exp_string PAREN_RIGHT {
        printf("%f %s", $5, $7);
    }

|   PRINTF PAREN_LEFT U AND exp_address AND exp_string PAREN_RIGHT {
        printf("%u %s", $5, $7);
    }
%%

void mem_write(unsigned int address, float value) {
    printf("writed %f on %u", value, address);
}

float mem_read(unsigned int address) {
    //printf("value on %u", address);
    return 1.00f;
}

void mem_free(unsigned int address) {
    printf("mem free at %u", address);
}

unsigned int mem_find_sequences(float value) {
    printf("finded sequence of bytes on address ");
    return 1;
}

int yyerror(const char* message) {
    fprintf(stderr, "error: %s\n", message);
    return 0;
}

int main(int argc, char* argv[]) {
    yyin = fopen(argv[1], "r");

    if (yyin == NULL)
    {
        printf("error: no such file or directory\n");
        return 1;
    }

    return yyparse();

    fclose(yyin);
}