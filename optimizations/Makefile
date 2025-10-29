a.out: a4.l a4.y
	bison -d a4.y
	flex a4.l
	g++ -o $@ a4.tab.c lex.yy.c -lfl

clean:
	rm -f a4.tab.c a4.tab.h lex.yy.c a.out
