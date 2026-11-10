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

    void float_set(int index, float value);
    float float_get(int index);
    void float_free(int index);

    bool string_check(const char* string);

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
%token TYPE_INT TYPE_FLOAT
%token PLUS MINUS DIVIDE MULTIPLY MODULO
%token PRINTF PRINTFLN
%token PAREN_LEFT PAREN_RIGHT
%token AND SEMICOLON

%type <integer> exp_int
%type <floating> exp_float
%type <string> exp_string

%left PLUS MINUS
%left DIVIDE MULTIPLY MODULO

%%

input:
    %empty
|   input line
;

line:
    printf SEMICOLON
|   printfln SEMICOLON

|   mem_write SEMICOLON
|   mem_free SEMICOLON

|   exp_int SEMICOLON
|   exp_float SEMICOLON
;

printf:
    PRINTF PAREN_LEFT exp_string PAREN_RIGHT {
        if (string_check($3))
            printf($3);
    }

|   PRINTF PAREN_LEFT exp_string AND exp_int PAREN_RIGHT {
        if (string_check($3))
            printf($3, $5);
    }

|   PRINTF PAREN_LEFT exp_string AND exp_float PAREN_RIGHT {
        if (string_check($3))
            printf($3, $5);
    }
;

printfln:
    PRINTFLN PAREN_LEFT exp_string PAREN_RIGHT {
        if (string_check($3)) {
            printf($3);
            printf("\n");
        }
    }

|   PRINTFLN PAREN_LEFT exp_string AND exp_int PAREN_RIGHT {
        if (string_check($3)) {
            printf($3, $5);
            printf("\n");
        }
    }

|   PRINTFLN PAREN_LEFT exp_string AND exp_float PAREN_RIGHT {
        if (string_check($3)) {
            printf($3, $5);
            printf("\n");
        }
    }
;

mem_write:
    MEM_WRITE PAREN_LEFT exp_int AND exp_int AND TYPE_INT PAREN_RIGHT {
        int_set($3, $5);
    }

|   MEM_WRITE PAREN_LEFT exp_int AND exp_float AND TYPE_FLOAT PAREN_RIGHT {
        float_set($3, $5);
    }
;

mem_free:
    MEM_FREE PAREN_LEFT exp_int AND TYPE_INT PAREN_RIGHT {
        int_free($3);
    }

|   MEM_FREE PAREN_LEFT exp_int AND TYPE_FLOAT PAREN_RIGHT {
        float_free($3);
    }
;
    
exp_int:
    NUMBER_INT {
        $$ = $1;
    }

|   exp_int PLUS exp_int {
        $$ = $1 + $3;
    }

|   exp_int MINUS exp_int {
        $$ = $1 - $3;
    }

|   exp_int MULTIPLY exp_int {
        $$ = $1 * $3;
    }

|   exp_int DIVIDE exp_int {
        $$ = $1 / $3;
    }

|   exp_int MODULO exp_int {
        $$ = $1 % $3;
    }

|   MEM_READ PAREN_LEFT exp_int AND TYPE_INT PAREN_RIGHT {
        $$ = int_get($3);
    }
;


exp_float:
    NUMBER_FLOAT {
        $$ = $1;
    }

|   exp_float PLUS exp_float {
        $$ = $1 + $3;
    }

|   exp_float MINUS exp_float {
        $$ = $1 - $3;
    }

|   exp_float MULTIPLY exp_float {
        $$ = $1 * $3;
    }

|   exp_float DIVIDE exp_float {
        $$ = $1 / $3;
    }

|   MEM_READ PAREN_LEFT exp_int AND TYPE_FLOAT PAREN_RIGHT {
        $$ = float_get($3);
    }
;

exp_string:
    STRING {
        $$ = $1;
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

void float_set(int index, float value) {
    if (float_vars[index] != NULL) {
        *float_vars[index] = value;
        return;
    }

    float_vars[index] = (float*) malloc(sizeof(float));
    *float_vars[index] = value;
}

float float_get(int index) {
    return *float_vars[index];
}

void float_free(int index) {
    free(float_vars[index]);
    float_vars[index] = NULL;
}

bool string_check(const char* string) {
    for (size_t i = 0; i < strlen(string); i++) {
        if (string[i] == '%') {
            if (string[i+1] != 'f' && string[i+1] != 'g' && string[i+1] != 'i' && string[i+1] != 'd' && string[i+1] != '%' && string[i+1] != 'F') {
                yyerror("no modificator found after %");
                return false;
            }
        }
    }

    return true;
}

int yyerror(const char* message) {
    fprintf(stderr, "ERROR: %s\n", message);
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

    int parse = yyparse();
    fclose(yyin);

    return parse;
}