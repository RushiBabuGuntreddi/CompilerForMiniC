all : a.out tac
a.out: a3.l a3.y
	bison -d a3.y
	flex a3.l
	g++ -o $@ a3.tab.c lex.yy.c -lfl


tac : tac.l tac.y
	bison -d tac.y
	flex tac.l
	g++ -o $@ tac.tab.c lex.yy.c -lfl
clean:
	rm -f a3.tab.c a3.tab.h lex.yy.c a.out tac.tab.c tac.tab.h tac 
