%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <stdbool.h>

    int yyerror(const char* message);
    int yylex(void);


    //AST (nodes)
    typedef struct {
        int value;
    } node_int;

    typedef struct {
        float value;
    } node_float;

    typedef struct {
        char* value;
    } node_string;


    typedef struct {
        node_string* string;
        node_int* integer;
        node_float* floating;
        node_string* string_second;
        bool ln;
        bool read;
    } node_printf;

    typedef struct {
        node_int* address;
        node_int* value_int;
        node_float* value_float;
        node_string* value_string;
        bool read;
    } node_memwrite;

    typedef struct {
        node_int* address;
        bool value_int;
        bool value_float;
        bool value_string;
    } node_memread;

    typedef struct {
        node_string* parametres;
    } node_scanf;


    typedef struct {
        node_printf printf;
        node_memwrite memwrite;
        node_memread memread;
        node_memread memfree;
        node_scanf scanf;
    } node_std;


    node_int* node_add_int(int value);
    node_float* node_add_float(float value);
    node_string* node_add_string(char* value);

    void node_add_printf(node_string* string, node_int* integer, node_float* floating, node_string* string_second, bool ln, bool read);
    void node_add_memwrite(node_int* address, node_int* value_int, node_float* value_float, node_string* value_string, bool read);
    void node_add_memread(node_int* address, bool value_int, bool value_float, bool value_string, bool free);
    void node_add_scanf(node_string* parametres);

    void node_to_func();

    void reading_set(node_memread node);
    void mem_write(node_memwrite node);
    void mem_free(node_memread node);

    node_std* nodes = NULL;
    int nodes_cur = 0;
    char* reading_value = NULL;

    
    //Variables
    int* int_vars[99] = {NULL};
    float* float_vars[99] = {NULL};
    char* string_vars[99] = {NULL};

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


    //Checking
    bool check_string(const char* string);
    bool check_index(int index);
    bool check_ext(const char* filename);

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
%token READING

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
|   mem_read SEMICOLON
|   mem_free SEMICOLON
|	scanf SEMICOLON
;

printf:
    PRINTF PAREN_LEFT exp_string PAREN_RIGHT {
        if (check_string($3))
            node_add_printf(node_add_string($3), NULL, NULL, NULL, false, false);
    }

|   PRINTF PAREN_LEFT exp_string AND exp_int PAREN_RIGHT {
        if (check_string($3))
            node_add_printf(node_add_string($3), node_add_int($5), NULL, NULL, false, false);
    }

|   PRINTF PAREN_LEFT exp_string AND exp_float PAREN_RIGHT {
        if (check_string($3))
            node_add_printf(node_add_string($3), NULL, node_add_float($5), NULL, false, false);
    }

|   PRINTF PAREN_LEFT exp_string AND exp_string PAREN_RIGHT {
        if (check_string($3))
            node_add_printf(node_add_string($3), NULL, NULL, node_add_string($5), false, false);
    }

|   PRINTF PAREN_LEFT exp_string AND READING PAREN_RIGHT {
        if (check_string($3))
            node_add_printf(node_add_string($3), NULL, NULL, NULL, false, true);
    }
;

printfln:
    PRINTFLN PAREN_LEFT exp_string PAREN_RIGHT {
        if (check_string($3))
            node_add_printf(node_add_string($3), NULL, NULL, NULL, true, false);
    }

|   PRINTFLN PAREN_LEFT exp_string AND exp_int PAREN_RIGHT {
        if (check_string($3))
            node_add_printf(node_add_string($3), node_add_int($5), NULL, NULL, true, false);
    }

|   PRINTFLN PAREN_LEFT exp_string AND exp_float PAREN_RIGHT {
        if (check_string($3))
            node_add_printf(node_add_string($3), NULL, node_add_float($5), NULL, true, false);
    }

|   PRINTFLN PAREN_LEFT exp_string AND exp_string PAREN_RIGHT {
        if (check_string($3))
            node_add_printf(node_add_string($3), NULL, NULL, node_add_string($5), true, false);
    }

|   PRINTFLN PAREN_LEFT exp_string AND READING PAREN_RIGHT {
        if (check_string($3))
            node_add_printf(node_add_string($3), NULL, NULL, NULL, true, true);
    }
;

mem_write:
    MEM_WRITE PAREN_LEFT exp_int AND exp_int AND TYPE_INT PAREN_RIGHT {
        node_add_memwrite(node_add_int($3), node_add_int($5), NULL, NULL, false);
    }

|   MEM_WRITE PAREN_LEFT exp_int AND exp_float AND TYPE_FLOAT PAREN_RIGHT {
        node_add_memwrite(node_add_int($3), NULL, node_add_float($5), NULL, false);
    }

|   MEM_WRITE PAREN_LEFT exp_int AND exp_string AND TYPE_STRING PAREN_RIGHT {
        node_add_memwrite(node_add_int($3), NULL, NULL, node_add_string($5), false);
    }

|   MEM_WRITE PAREN_LEFT exp_int AND READING AND TYPE_STRING PAREN_RIGHT {
        node_add_memwrite(node_add_int($3), NULL, NULL, NULL, true);
    }
;

mem_read:
    MEM_READ PAREN_LEFT exp_int AND TYPE_INT PAREN_RIGHT {
        node_add_memread(node_add_int($3), true, false, false, false);
    }

|   MEM_READ PAREN_LEFT exp_int AND TYPE_FLOAT PAREN_RIGHT {
        node_add_memread(node_add_int($3), false, true, false, false);
    }

|   MEM_READ PAREN_LEFT exp_int AND TYPE_STRING PAREN_RIGHT {
        node_add_memread(node_add_int($3), false, false, true, false);
    }
;

mem_free:
    MEM_FREE PAREN_LEFT exp_int AND TYPE_INT PAREN_RIGHT {
        node_add_memread(node_add_int($3), true, false, false, true);
    }

|   MEM_FREE PAREN_LEFT exp_int AND TYPE_FLOAT PAREN_RIGHT {
        node_add_memread(node_add_int($3), false, true, false, true);
    }

|   MEM_FREE PAREN_LEFT exp_int AND TYPE_STRING PAREN_RIGHT {
        node_add_memread(node_add_int($3), false, false, true, true);
    }
;

scanf:
	SCANF PAREN_LEFT exp_string PAREN_RIGHT {
        if (check_string($3))
		    node_add_scanf(node_add_string($3));
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
;

exp_string:
    STRING {
        $$ = $1;
    }
;
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
    if (check_index(index) && int_vars[index] != NULL)
        return *int_vars[index];

    yyerror("reading unset memory (NULL)");
    return 0;
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
    if (check_index(index) && float_vars[index] != NULL)
        return *float_vars[index];

    yyerror("reading unset memory (NULL)");
    return 0.0f;
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
            free(string_vars[index]);
            string_vars[index] = strdup(value);
            return;
        }

        string_vars[index] = strdup(value);
    }
}

char* string_get(int index) {
    if (check_index(index) && string_vars[index] != NULL)
        return string_vars[index];

    yyerror("reading unset memory (NULL)");
    return "";
}

void string_free(int index) {
    if (check_index(index)) {
        free(string_vars[index]);
        string_vars[index] = NULL;
    }
}

void all_free() {
    for (int i = 0; i < 99; ++i) {
        int_free(i);
        float_free(i);
        string_free(i);
    }

    free(nodes);
    nodes = NULL;
    nodes_cur = 0;
    free(reading_value);
}


//AST (nodes)
node_int* node_add_int(int value) {
    node_int* node_new = malloc(sizeof(node_int));
    node_new->value = value;
    return node_new;
}

node_string* node_add_string(char* value) {
    node_string* node_new = malloc(sizeof(node_string));
    node_new->value = strdup(value);
    return node_new;
}

node_float* node_add_float(float value) {
    node_float* node_new = malloc(sizeof(node_float));
    node_new->value = value;
    return node_new;
}


void node_add_printf(node_string* string, node_int* integer, node_float* floating, node_string* string_second, bool ln, bool read) {
    node_printf node_new;
    node_new.string = string;
    node_new.integer = integer;
    node_new.floating = floating;
    node_new.string_second = string_second;
    node_new.ln = ln;
    node_new.read = read;

    node_std* temp = realloc(nodes, (nodes_cur + 1) * sizeof(*nodes));

    if (temp == NULL) {
        yyerror("can't alloc memory");
        return;
    }

    nodes = temp;
    nodes[nodes_cur] = (node_std){0};
    nodes[nodes_cur].printf = node_new;
    nodes_cur++;
}

void node_add_memwrite(node_int* address, node_int* value_int, node_float* value_float, node_string* value_string, bool read) {
    node_memwrite node_new;
    node_new.address = address;
    node_new.value_int = value_int;
    node_new.value_float = value_float;
    node_new.value_string = value_string;
    node_new.read = read;

    node_std* temp = realloc(nodes, (nodes_cur + 1) * sizeof(*nodes));

    if (temp == NULL) {
        yyerror("can't alloc memory");
        return;
    }

    nodes = temp;
    nodes[nodes_cur] = (node_std){0};
    nodes[nodes_cur].memwrite = node_new;
    
    nodes_cur++;
}

void node_add_memread(node_int* address, bool value_int, bool value_float, bool value_string, bool free) {
    node_memread node_new;
    node_new.address = address;
    node_new.value_int = value_int;
    node_new.value_float = value_float;
    node_new.value_string = value_string;

    node_std* temp = realloc(nodes, (nodes_cur + 1) * sizeof(*nodes));

    if (temp == NULL) {
        yyerror("can't alloc memory");
        return;
    }

    nodes = temp;
    nodes[nodes_cur] = (node_std){0};

    if (!free)
        nodes[nodes_cur].memread = node_new;
    else
        nodes[nodes_cur].memfree = node_new;
    
    nodes_cur++;
}

void node_add_scanf(node_string* parametres) {
    node_scanf node_new;
    node_new.parametres = parametres;

    node_std* temp = realloc(nodes, (nodes_cur + 1) * sizeof(*nodes));

    if (temp == NULL) {
        yyerror("can't alloc memory");
        return;
    }

    nodes = temp;
    nodes[nodes_cur] = (node_std){0};
    nodes[nodes_cur].scanf = node_new;

    nodes_cur++;
}


void node_to_func() {
    for (int i = 0; i < nodes_cur; ++i) {
        //PRINTF/PRINTFLN
        if (nodes[i].printf.string != NULL) {
            if (nodes[i].printf.integer != NULL) {
                printf(nodes[i].printf.string->value, nodes[i].printf.integer->value);
            }

            else if (nodes[i].printf.floating != NULL) {
                printf(nodes[i].printf.string->value, nodes[i].printf.floating->value);
            }

            else if (nodes[i].printf.string_second != NULL) {
                printf(nodes[i].printf.string->value, nodes[i].printf.string_second->value);
            }

            else if (nodes[i].printf.read == true) {
                printf(nodes[i].printf.string->value, reading_value);
            }

            else
                printf(nodes[i].printf.string->value);

            if (nodes[i].printf.ln == true)
                printf("\n");
        }

        //MEMWRITE
        else if (nodes[i].memwrite.address != NULL) {
            mem_write(nodes[i].memwrite);
        }

        //MEMREAD
        else if (nodes[i].memread.address != NULL) {
            reading_set(nodes[i].memread);
        }

		//SCANF	
        else if (nodes[i].scanf.parametres != NULL) {
            scanf(nodes[i].scanf.parametres->value, reading_value);
        }

        //MEMFREE
        else if (nodes[i].memfree.address != NULL) {
            mem_free(nodes[i].memfree);
        }
    }

    printf("\n");
}

void reading_set(node_memread node) {
    if (node.value_int == true) {
        int value = int_get(node.address->value);

        snprintf(reading_value, 99 * sizeof(char), "%d", value);
    }

    else if (node.value_float == true) {
        float value = float_get(node.address->value);

        snprintf(reading_value, 99 * sizeof(char), "%g", value);
    }

    else {
        char* value = string_get(node.address->value);

        snprintf(reading_value, 99 * sizeof(char), "%s", value);
    }
}

void mem_write(node_memwrite node) {
    if (node.value_int != NULL)
        int_set(node.address->value, node.value_int->value);

    else if (node.value_float != NULL)
        float_set(node.address->value, node.value_float->value);

    else if (node.value_string != NULL)
        string_set(node.address->value, node.value_string->value);

    else
        string_set(node.address->value, reading_value);
}

void mem_free(node_memread node) {
    if (node.value_int == true)
        int_free(node.address->value);

    else if (node.value_float == true)
        float_free(node.address->value);

    else
        string_free(node.address->value);
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
    if (index < 0 || index > 98) {
        yyerror("index out of range");
        return false;
    }

    return true;
}

bool check_ext(const char* filename) {
    const char* dot = strrchr(filename, '.');
    return dot != NULL && strcmp(dot, ".mem") == 0;
}


int yyerror(const char* message) {
    fprintf(stderr, "\nERROR: %s\n", message);
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

    if (!check_ext(argv[1]))
        return 1;

    reading_value = malloc(99 * sizeof(char));
    int parse = yyparse();
    
    node_to_func();
    all_free();

    fclose(yyin);
    return parse;
}
