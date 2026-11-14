%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <stdbool.h>

    int yyerror(const char* message);
    int yylex(void);


    //AST (nodes)
    typedef struct {
        char* value;
    } node_string;

    typedef struct {
        int value;
    } node_int;

    typedef struct {
        float value;
    } node_float;


    typedef struct {
        node_string* string;
        node_int* integer;
        node_float* floating;
        node_string* string_second;
        bool ln;
    } node_printf;


    typedef struct {
        node_printf printf;
    } node_std;

    node_string* node_add_string(char* value);
    node_int* node_add_int(int value);
    node_float* node_add_float(float value);

    void node_add_printf(node_string* string, node_int* integer, node_float* floating, node_string* string_second, bool ln);

    void node_to_func();

    node_std* nodes = NULL;
    int nodes_cur = 0;

    
    //Variables
    int* int_vars[25] = {NULL};
    float* float_vars[25] = {NULL};
    char* string_vars[25] = {NULL};

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


    //Checking (small protection)
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
%token PRINTF PRINTFLN
%token SCANF

%token TYPE_INT TYPE_FLOAT TYPE_STRING

%token PLUS MINUS DIVIDE MULTIPLY MODULO
%left PLUS MINUS
%left DIVIDE MULTIPLY MODULO

%token PAREN_LEFT PAREN_RIGHT AND SEMICOLON

%type <integer> exp_int
%type <floating> exp_float
%type <string> exp_string

%%

input:
    %empty
|   input ln
;

ln:
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
            node_add_printf(node_add_string($3), NULL, NULL, NULL, false);
    }

|   PRINTF PAREN_LEFT exp_string AND exp_int PAREN_RIGHT {
        if (check_string($3))
            node_add_printf(node_add_string($3), node_add_int($5), NULL, NULL, false);
    }

|   PRINTF PAREN_LEFT exp_string AND exp_float PAREN_RIGHT {
        if (check_string($3))
            node_add_printf(node_add_string($3), NULL, node_add_float($5), NULL, false);
    }

|   PRINTF PAREN_LEFT exp_string AND exp_string PAREN_RIGHT {
        if (check_string($3))
            node_add_printf(node_add_string($3), NULL, NULL, node_add_string($5), false);
    }
;

printfln:
    PRINTFLN PAREN_LEFT exp_string PAREN_RIGHT {
        if (check_string($3))
            node_add_printf(node_add_string($3), NULL, NULL, NULL, true);
    }

|   PRINTFLN PAREN_LEFT exp_string AND exp_int PAREN_RIGHT {
        if (check_string($3)) 
            node_add_printf(node_add_string($3), node_add_int($5), NULL, NULL, true);
    }

|   PRINTFLN PAREN_LEFT exp_string AND exp_float PAREN_RIGHT {
        if (check_string($3))
            node_add_printf(node_add_string($3), NULL, node_add_float($5), NULL, true);
    }

|   PRINTFLN PAREN_LEFT exp_string AND exp_string PAREN_RIGHT {
        if (check_string($3))
            node_add_printf(node_add_string($3), NULL, NULL, node_add_string($5), true);
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

|   PAREN_LEFT exp_int PAREN_RIGHT {
        $$ = $2;
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

|   PAREN_LEFT exp_float PAREN_RIGHT {
        $$ = $2;
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


//Variables
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


//AST (nodes)
node_string* node_add_string(char* value) {
    node_string* node_new = malloc(sizeof(node_string));
    node_new->value = strdup(value);
    return node_new;
}

node_int* node_add_int(int value) {
    node_int* node_new = malloc(sizeof(node_int));
    //node_new->value = malloc(sizeof(int));
    node_new->value = value;
    return node_new;
}

node_float* node_add_float(float value) {
    node_float* node_new = malloc(sizeof(node_float));
    //node_new->value = malloc(sizeof(float));
    node_new->value = value;
    return node_new;
}


void node_add_printf(node_string* string, node_int* integer, node_float* floating, node_string* string_second, bool ln) {
    node_printf node_new;
    node_new.string = string;
    node_new.integer = integer;
    node_new.floating = floating;
    node_new.string_second = string_second;
    node_new.ln = ln;

    node_std* temp = realloc(nodes, (nodes_cur + 1) * sizeof(*nodes));

    if (temp == NULL) {
        yyerror("can't alloc memory");
        return;
    }

    nodes = temp;
    nodes[nodes_cur].printf = node_new;
    nodes_cur++;
}


void node_to_func() {
    for (int i = 0; i < nodes_cur; ++i) {
        //PRINTF/PRINTFLN
        if (nodes[i].printf.string != NULL) {
            if (nodes[i].printf.ln == true)
                printf("\n");

            if (nodes[i].printf.integer != NULL) {
                printf(nodes[i].printf.string->value, nodes[i].printf.integer->value);
            }

            else if (nodes[i].printf.floating != NULL) {
                printf(nodes[i].printf.string->value, nodes[i].printf.floating->value);
            }

            else if (nodes[i].printf.string_second != NULL) {
                printf(nodes[i].printf.string->value, nodes[i].printf.string_second->value);
            }

            else
                printf(nodes[i].printf.string->value);
        }
    }
}


//Checking (small protection)
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
    node_to_func();
    all_free();

    fclose(yyin);
    return parse;
}