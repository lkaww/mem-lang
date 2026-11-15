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
./mem script.mg
```
You can use absolutely only .mg extension.

## Example

Script code:
```
printfln("hello"); //PRINTF WITH NEW LINE
printfln("there");

printf("Hello, World!"); //PRINTF
```

Console:
```
./mem example.mg

hello
there
Hello, World!
```
