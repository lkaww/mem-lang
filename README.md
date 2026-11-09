# mem-lang

A small set of commands that allow you to work with memory. Created with Flex and GNU Bison.

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
mem\_write(1, 1); //ADDRESS 1, VALUE 2.34
printf(%i, mem\_read(1)); //PRINTS VALUE ON ADDRESS 1
```

