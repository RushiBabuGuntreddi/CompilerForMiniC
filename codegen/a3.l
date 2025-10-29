%{
    #include<bits/stdc++.h>
    using namespace std;

    #include "a3.tab.h"

    void yyerror(const char* s);
    extern int yylineno;


%}

%%
"retval" {return RETVAL;}
"global" {return GLOBAL;}
"local" {return LOCAL;}
"goto" {return GOTO;}
"if" {return IF;}
"return" {return RETURN;cout << "return" << endl;}
param[0-9]+ {yylval.str_val = strdup(yytext); return PARAM;}
"call" {return CALL;}
\"([^\"]|\\\")*\"   {yylval.str_val = strdup(yytext);  return STRING_LITERAL; }
[\+\-\*\/\!\(\)\:\=\[\]\<\>] {return *yytext;}
"<="    {  return LE_OP;}
"=="    {  return EQ_OP;}
">="    {  return GE_OP;}
"!="    {  return NE_OP;}

\'([^\']|\\\'|\\0|\\\\|\\n)\'    { yylval.str_val = strdup(yytext);   return CHAR_CONST; } 
[t][0-9]+ {yylval.str_val = strdup(yytext); return TEMP;}
[L][0-9]+[:] {yylval.str_val = strdup(yytext); return LABEL;}
[L][0-9]+ {yylval.str_val = strdup(yytext); return GOTO_LABEL;}

[a-zA-Z_][a-zA-Z0-9_]*  { yylval.str_val = strdup(yytext); return IDENTIFIER; }
[a-zA-Z_][a-zA-Z0-9_]*[:]   { yylval.str_val = strdup(yytext); return F_IDENTIFIER; }
[0-9]+ {yylval.str_val=strdup(yytext); return INT_CONST;}




[ \t\r\f]    { }
[\n] {yylineno++;}


%%
int yywrap(void){
    return 1;
}
