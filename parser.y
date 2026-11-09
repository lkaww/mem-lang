%{
    #include <stdio.h>
    #include <string.h>

    int yyerror(const char* message);
    int yylex(void);

    int* int_vars[25];
    float* float_vars[25];

    void int_set(int index, int value);
    int int_get(int index);
    void int_free(int index);

    extern FILE* yyin;
%}

%union {
    int integer;
    float floating;
    char* string;
}

%token <integer> NUMBER_INT
%token <floating> NUMBER_FLOAT
%token <string> STRING

%token MEM_WRITE MEM_READ MEM_FREE
%token PRINTF I F S
%token PAREN_LEFT PAREN_RIGHT
%token AND SEMICOLON

%type <integer> exp_int
%type <floating> exp_float
%type <string> exp_string

%%

input:
    %empty
|   input line;
;

line:
    exp_float SEMICOLON {
        printf("%g\n", $1);
    }

|   exp_int SEMICOLON {
        printf("%d\n", $1);
    }

|   exp_string SEMICOLON {
        printf("%s\n", $1);
    }
;
exp_int:
    NUMBER_INT {
        $$ = $1;
    }

|   PRINTF PAREN_LEFT I AND exp_int PAREN_RIGHT {
        printf("%d\n",$5 );
    }

|   MEM_WRITE PAREN_LEFT exp_int AND exp_int PAREN_RIGHT {
        int_set($3, $5);
    }

|   MEM_READ PAREN_LEFT exp_int PAREN_RIGHT {
        $$ = int_get($3);
    }

|   MEM_FREE PAREN_LEFT exp_int PAREN_RIGHT {
        int_free($3);
    }
;


exp_float:
    NUMBER_FLOAT {
        $$ = $1;
    }

|   PRINTF PAREN_LEFT F AND exp_float PAREN_RIGHT {
        printf("%g\n",$5 );
    }    
;

exp_string:
    STRING {
        $$ = $1;
    }

|   PRINTF PAREN_LEFT exp_string PAREN_RIGHT {
        printf("%s\n", $3);
    }

|   PRINTF PAREN_LEFT exp_string AND F AND exp_float PAREN_RIGHT {
        printf("%s %g\n", $3, $7);
    }

|   PRINTF PAREN_LEFT F AND exp_float AND exp_string PAREN_RIGHT {
        printf("%g %s\n", $5, $7);
    }

|   PRINTF PAREN_LEFT exp_string AND I AND exp_int PAREN_RIGHT {
        printf("%s %d\n", $3, $7);
    }

|   PRINTF PAREN_LEFT I AND exp_int AND exp_string PAREN_RIGHT {
        printf("%d %s\n", $5, $7);
    }
%%

void int_set(int index, int value) {
    if (int_vars[index] != NULL) {
        *int_vars[index] = value;
        return;
    }

    int_vars[index] = (int*) malloc(sizeof(int));
    *int_vars[index] = value;
}

int int_get(int index) {
    return *int_vars[index];
}

void int_free(int index) {
    free(int_vars[index]);
    int_vars[index] = NULL;
}

int yyerror(const char* message) {
    fprintf(stderr, "error: %s\n", message);
    return 0;
}

int main(int argc, char* argv[]) {
    yyin = fopen(argv[1], "r");

    if (yyin == NULL)
    {
        //printf("error: no such file or directory\n");
        yyerror("no such file or directory");
        return 1;
    }

    return yyparse();

    fclose(yyin);
}