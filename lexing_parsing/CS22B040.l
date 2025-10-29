%{
   # include "CS22B040.tab.h"
   # include <iostream>
   #include <stdlib.h>
   #include <string>
   void yyerror(const char *);
   using namespace std;


%}
%option yylineno

%%

int                          {return TYPE;} 
char                         {                return TYPE;}
float                        {                return TYPE;}
void                            {                return TYPE;}
printf                       {                               return PRINTF;}
if                           {                              return IF;}
else                         {                              return ELSE;}
while                        {                              return WHILE;}
for                          {                              return FOR;}
return                       {                              return RETURN;}
[0-9]+(\.[0-9]+)?                     {                   return NUMBER;}
[a-zA-Z_][a-zA-Z0-9_]*       { strcpy(yylval.strval,yytext);      return VAR;}

"=="                         {                   return COMP;}
"!="                         {                   return COMP;}
"<"                          {                   return COMP;}
">"                         {                   return COMP;}
"<="                         {                   return COMP;}
">="                         {                   return COMP;}
"="                           {                   return '=';}
[;+\-*/\\,]                   {            return *yytext; }
\"(\\.|[^"])*\"                    {return STRING;}
"**"                         {             return POW;}
[\(\)\{\}\[\]]              {             return *yytext; }
[ \n\t\r]                     {                                         }

.    { yyerror("unknown character"); }

%%

int yywrap(void) {
    return 1;
}