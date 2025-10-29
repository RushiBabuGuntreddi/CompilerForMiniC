%{
    #include<bits/stdc++.h>
    using namespace std;

    #include "a4.tab.h"

    void yyerror(const char* s);
    extern int yylineno;


%}

%%

"if" { return IF; }
"goto" { return GOTO; }
"print" { return PRINT; }
[a-zA-Z][a-zA-Z0-9]* { yylval.str_val = strdup(yytext); return ID; }
[0-9]+ { yylval.str_val = strdup(yytext); return INT_LIT; }
[-+*/!] { return OP; }
[=\:] {return *yytext; }
"==" { return C_OP; }
"!=" { return C_OP; }
"<" { return C_OP; }
"<=" { return C_OP; }
">" { return C_OP; }
">=" { return C_OP; }

[ \t\n\r] { }

. {yyerror("Invalid character");}




%%
int yywrap(void){
    return 1;
}
