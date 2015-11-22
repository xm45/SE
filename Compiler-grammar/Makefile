all: main

main: parser.o tokens.o
	g++ -std=c++11 -o main parser.o tokens.o

parser.o: parser.cpp parser.h tree.h
	g++ -std=c++11 -c parser.cpp

parser.cpp parser.h: parser.y
	bison --defines=parser.h -o parser.cpp parser.y

tokens.o: tokens.cpp parser.h tree.h
	g++ -std=c++11 -c tokens.cpp

tokens.cpp: tokens.l
	flex -o tokens.cpp tokens.l

test:main
	./main test.txt ans.txt

.PHONY: clean
clean:
	-rm -rf *.o tokens.cpp parser.cpp parser.h location.hh position.hh stack.hh main
