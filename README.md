# mem-lang
A small interpreting language. Created with Flex and GNU Bison as study project.

## How to build
You need to download Flex, GNU Bison and C compiler (i have gcc). Then run the following commands:
```
bison -d -o y.tab.c parser.y
flex lexer.l
gcc y.tab.c lex.yy.c
```

## Usage
```
./mem script.mem
```
You can use only .mem extension.

## Example

Script code:
```
printfln("hello"); //PRINTF WITH NEW LINE
printfln("there");

printf("Hello, World!"); //PRINTF
```

Console:
```
./mem example.mem

hello
there
Hello, World!
```
