%{
	#include "a2.tab.h"
    #include <stdlib.h>
    #include <vector>
    using namespace std;

    extern char mytext[];
    void yyerror(const char *);
    extern int line_number;
%}

%%

"if"        { return IF; }
"else"      { return ELSE; }
"while"     { return WHILE; }
"for"       { return FOR; }
"return"    { return RETURN; }
"int"       { return INT; }
"char"      { return CHAR; }

"=="        { return EQ_OP; }
"!="        { return NE_OP; }
"<="        { return LE_OP; }
">="        { return GE_OP; }
"<"         { return '<'; }
">"         { return '>'; }


[+\-*/]     { return *yytext; }
"**"        { return EXP_OP; }

"||"        { return OR; }
"&&"        { return AND; }
"!"      { return NOT; }

//.* ; { /* ignore comments */ }
[=;,(){}[\]] { return *yytext; }

[0-9]+      {yylval.str_val = strdup(yytext);  return INT_CONST; }
['].*[']    { yylval.str_val = strdup(yytext);   return CHAR_CONST; } 

[a-zA-Z_][a-zA-Z0-9_]*   { yylval.str_val = strdup(yytext); return IDENTIFIER; }

["].*["]   {yylval.str_val = strdup(yytext);  return STRING_LITERAL; }

[ \t]+  ; // ignore whitespace

[\n\r]      { line_number++; }

.           { return *yytext; }

%%

int yywrap(void) {
    return 1;
}