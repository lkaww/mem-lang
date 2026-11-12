%{
    #include <stdio.h>
    #include <string.h>

    int yyerror(const char* message);
    int yylex(void);

    int* int_vars[25] = {NULL};
    float* float_vars[25] = {NULL};
    char* string_vars[25] = {NULL};

    /*char* always_statements[25] = {NULL};
    bool always_write = false;
    int curstatement = 0;
    void statement_add(char* value);*/

    void int_set(int index, int value);
    int int_get(int index);
    void int_free(int index);

    void float_set(int index, float value);
    float float_get(int index);
    void float_free(int index);

    void string_set(int index, char* value);
    char* string_get(int index);
    void string_free(int index);

    void all_free();

    bool check_string(const char* string);
    bool check_index(int index);

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
%token TYPE_INT TYPE_FLOAT TYPE_STRING
%token PLUS MINUS DIVIDE MULTIPLY MODULO
%token PRINTF PRINTFLN
%token SCANF
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
    statements
;

statements:
    printf SEMICOLON
|   printfln SEMICOLON

|   mem_write SEMICOLON
|   mem_free SEMICOLON

|   exp_string
;

printf:
    PRINTF PAREN_LEFT exp_string PAREN_RIGHT {
        if (check_string($3))
            printf($3);
    }

|   PRINTF PAREN_LEFT exp_string AND exp_int PAREN_RIGHT {
        if (check_string($3))
            printf($3, $5);
    }

|   PRINTF PAREN_LEFT exp_string AND exp_float PAREN_RIGHT {
        if (check_string($3))
            printf($3, $5);
    }

|   PRINTF PAREN_LEFT exp_string AND exp_string PAREN_RIGHT {
        if (check_string($3))
            printf($3, $5);
    }
;

printfln:
    PRINTFLN PAREN_LEFT exp_string PAREN_RIGHT {
        if (check_string($3)) {
            printf($3);
            printf("\n");
        }
    }

|   PRINTFLN PAREN_LEFT exp_string AND exp_int PAREN_RIGHT {
        if (check_string($3)) {
            printf($3, $5);
            printf("\n");
        }
    }

|   PRINTFLN PAREN_LEFT exp_string AND exp_float PAREN_RIGHT {
        if (check_string($3)) {
            printf($3, $5);
            printf("\n");
        }
    }

|   PRINTFLN PAREN_LEFT exp_string AND exp_string PAREN_RIGHT {
        if (check_string($3)) {
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

|   MEM_WRITE PAREN_LEFT exp_int AND exp_string AND TYPE_STRING PAREN_RIGHT {
        string_set($3, $5);
    }
;

mem_free:
    MEM_FREE PAREN_LEFT exp_int AND TYPE_INT PAREN_RIGHT {
        int_free($3);
    }

|   MEM_FREE PAREN_LEFT exp_int AND TYPE_FLOAT PAREN_RIGHT {
        float_free($3);
    }

|   MEM_FREE PAREN_LEFT exp_int AND TYPE_STRING PAREN_RIGHT {
        string_free($3);
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

|   MEM_READ PAREN_LEFT exp_int AND TYPE_STRING PAREN_RIGHT {
        $$ = string_get($3);
    }

|   SCANF PAREN_LEFT exp_string PAREN_RIGHT {
        char* user_input;
        scanf($3, user_input);
        $$ = user_input;
    }
%%

/*void statement_add(char* value) {
    if (check_index(curstatement) && always_write) {
        always_statements[curstatement] = strdup(value);
        curstatement++;
    }
}*/

void int_set(int index, int value) {
    if (check_index(index)) {
        if (int_vars[index] != NULL) {
            *int_vars[index] = value;
            return;
        }

        int_vars[index] = (int*) malloc(sizeof(int));
        *int_vars[index] = value;
    }
}

int int_get(int index) {
    if (check_index(index))
        return *int_vars[index];
}

void int_free(int index) {
    if (check_index(index)) {
        free(int_vars[index]);
        int_vars[index] = NULL;
    }
}

void float_set(int index, float value) {
    if (check_index(index)) {
        if (float_vars[index] != NULL) {
            *float_vars[index] = value;
            return;
        }

        float_vars[index] = (float*) malloc(sizeof(float));
        *float_vars[index] = value;
    }
}

float float_get(int index) {
    if (check_index(index))
        return *float_vars[index];
}

void float_free(int index) {
    if (check_index(index)) {
        free(float_vars[index]);
        float_vars[index] = NULL;
    }
}

void string_set(int index, char* value) {
    if (check_index(index)) {
        if (string_vars[index] != NULL) {
            string_vars[index] = value;
            return;
        }

        string_vars[index] = strdup(value);
    }
}

char* string_get(int index) {
    if (check_index(index))
        return string_vars[index];
}

void string_free(int index) {
    if (check_index(index)) {
        free(string_vars[index]);
        string_vars[index] = NULL;
    }
}

void all_free() {
    for (int i = 0; i < 25; ++i) {
        int_free(i);
        float_free(i);
        string_free(i);
    }
}

bool check_string(const char* string) {
    for (size_t i = 0; i < strlen(string); ++i) {
        if (string[i] == '%') {
            if (string[i+1] == 'u' || string[i+1] == 'o' || string[i+1] == 'x' || string[i+1] == 'X') {
                yyerror("no available modificator found after %");
                return false;
            }
        }
    }

    return true;
}

bool check_index(int index) {
    if (index < 0 || index > 24) {
        yyerror("index out of range");
        return false;
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
        yyerror("no such file or directory");
        yyerror("usage: ./mem filename");
        return 1;
    }

    int parse = yyparse();
    all_free();

    fclose(yyin);
    return parse;
}