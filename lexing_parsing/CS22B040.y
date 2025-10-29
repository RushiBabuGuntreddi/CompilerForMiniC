%{
    #include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
    #include <iostream>
    #include <unordered_map>
    #include <string>
    #include<bits/stdc++.h>
    using namespace std;
     void yyerror(const char * );
	int yylex(void);
    extern char *yytext;
    extern int yylineno;
    unordered_map<string,int> mp;
%}
%expect 1
%left '+' '-'
%left '*' '/'
%right POW
%token  COMP PRINTF IF ELSE FOR WHILE RETURN NUMBER  TYPE STRING


%union{
    int value;
   char strval[256];
}
%token <strval> VAR

%% 
program: lines {
        		//printf("program.\n");
	};

lines: oneline {
		//printf("lines: oneline\n");
    	}
	| oneline lines {
		//printf("lines: oneline lines\n");
	}
;

oneline:  function_def
        | TYPE multile_ass_decc ';'
        | assignments ';'
        | conditionals
        | loops
        | print
        | returnstatement
        | fun_call ';'
        | '{' lines '}'
        ;


print : PRINTF '(' STRING  pexps')'   ';';

pexps: 
      | ',' expression pexps ;


declarations: VAR { mp[$1]=0;}
             |VAR '[' expression ']' { mp[$1]=1;}
             |VAR '[' expression ']' '[' expression ']'{ mp[$1]=2;} ;

assignments:  VAR '=' expression { if(mp.find($1)==mp.end()){ mp[$1]==0;}}
            | VAR '[' expression ']' '=' expression {if(mp.find($1)==mp.end()){ mp[$1]=1;}}
            | VAR '[' expression ']' '[' expression ']' '=' expression {if(mp.find($1)==mp.end()){ mp[$1]=2;}} ;


ass_dec : declarations
        | assignments ;

multile_ass_decc :  ass_dec
              | ass_dec ',' multile_ass_decc ;
            

conditionals: IF '(' cond ')' oneline
            | IF '(' cond ')' oneline ELSE oneline 
           
            ;


cond:  comp_expression 
       | comp_expression COMP comp_expression ;

loops: WHILE '(' cond ')' oneline
     | FOR '(' for_assign ';' cond ';' assignments')' oneline ;

for_assign : assignments
            | TYPE assignments
returnstatement: RETURN ';'
               | RETURN expression ';' ;

function_def: TYPE VAR '(' args ')' ;
args: 
    |arg
    | arg ',' args
arg:  TYPE VAR { mp[$2]=0;}
    | TYPE VAR '[' ']' { mp[$2]=1;}
    | TYPE VAR '[' ']' '['expression ']' { mp[$2]=2;}
    | TYPE VAR '['expression ']' { mp[$2]=1;}
    | TYPE VAR '['expression ']' '['expression ']' { mp[$2]=2;}
;

fun_call : VAR '(' exps ')'

expression : expression_end
             | expression_start

expression_start: expression '+' expression 
	  | expression '-' expression 
	  | expression '*' expression 
	  | expression '/' expression 
      | expression POW expression 
	  | '(' expression ')' 
      | '-' '(' expression ')'

expression_end: NUMBER 
      | '-' NUMBER
      | VAR 
      | '-' VAR 
      | VAR '[' expression ']' 
      | VAR '[' expression ']' '[' expression ']' 
      | fun_call
      | '-' VAR '[' expression ']' 
      | '-' VAR '[' expression ']' '[' expression ']' 
      | '-' fun_call
      
    
;
comp_expression : comp_expression_end
             | expression_start
;

comp_expression_end: NUMBER 
      | '-' NUMBER
	  | VAR {if((mp.find($1)!=mp.end())&&(mp[$1]!=0))yyerror("error");}
	  | '-' VAR {if((mp.find($2)!=mp.end())&&(mp[$2]!=0))yyerror("error");}
      | VAR '[' expression ']' {if((mp.find($1)!=mp.end())&&(mp[$1]!=1))yyerror("error");}
      | VAR '[' expression ']' '[' expression ']' {if((mp.find($1)!=mp.end())&&(mp[$1]!=2))yyerror("error");}
      | fun_call
      | '-' VAR '[' expression ']' {if((mp.find($2)!=mp.end())&&(mp[$2]!=1))yyerror("hi");}
      | '-' VAR '[' expression ']' '[' expression ']' {if((mp.find($2)!=mp.end())&&(mp[$2]!=2))yyerror("error");}
      | '-' fun_call
	  
;
exps : 
      | expression
      | expression ',' exps
;

%%


void yyerror(const char *s) {
    cout << " "<<yylineno << endl;
    exit(1);
}

int main(void) {
    yyparse();
    return 0;
}