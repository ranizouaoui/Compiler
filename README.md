# Compiler

Compiler construction using Flex and Bison

## Setup Instructions
Clone this repository. You will need flex, bison, and gcc installed on your machine.

### To build:
```
$ make
compiler:
	flex -o lexer.c lexer.l 
	bison -d -o parser.c parser.y -d
	gcc parser.c -o compiler
```
### To run:
```
$ ./compiler
5 
18
45
Results :
        -- Success in lexical analysis ! --
        -- Parse success! --
```

### To update:
```
//  Change code
$ rm compiler
$ make
```
