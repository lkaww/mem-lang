# mem-lang

A small set of commands that allow you to work with memory. Created with Flex and GNU Bison.
## How to build

You need to download Flex, GNU Bison and GCC. Then run the following commands:

```bash
bison -d -o y.tab.c parser.y
flex lexer.l
gcc y.tab.c lex.yy.c -o mem-lang.exe
```
    
## Usage

```
./mem-lang script.txt
```

You can use absolutely any extension instead of .txt.

## Example

Script code:

```
mem_write(1, 2.34); //ADDRESS 1, VALUE 2.34
print(mem_read(1)); //PRINTS VALUE ON ADDRESS 1
```