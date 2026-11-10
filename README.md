# mem-lang
A small scripting language. Created with Flex and GNU Bison as study project.

## How to build
You need to download Flex, GNU Bison and GCC. Then run the following commands:
```
bison -d -o y.tab.c parser.y
flex lexer.l
gcc y.tab.c lex.yy.c -o mem.exe
```

## Usage
```
./mem script.txt
```
You can use absolutely any extension instead of .txt.

## Example

Script code:
```
mem_write(1, 1, int); //ADDRESS 1, VALUE 1, TYPE INT
printf("Result: %i", mem_read(1, int)); //PRINTS VALUE ON ADDRESS 1, TYPE INT
```

Console:
```
./mem example.txt

Result: 1
```
