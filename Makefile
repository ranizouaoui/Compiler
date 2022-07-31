prog:
	flex -o lexer.c lexer.l 
	bison -d -o parser.c parser.y -d
	gcc parser.c -o prog