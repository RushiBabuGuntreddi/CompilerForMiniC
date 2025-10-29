%{
	#include <iostream>
	#include <string.h>
	#include <stdlib.h>
    #include <vector>
    #include <bits/stdc++.h>
    using namespace std;
	void yyerror(const char *);
	int yylex(void);
    extern char *yytext;
    extern int yylineno;
    void print_vec();
    void print_func();
    set<string> global_declarations;
    set<string>local_arrays;
    map<string,string> rushi_data;
    int datacount=0;
    vector<string>vec;
   map<string,string> mp;
   vector<string>vec_temp;
   string jump;
   int param_count = +8;
   int local_count = 0;

%}

%union {
    char *str_val;  
}

%token <str_val> IDENTIFIER INT_CONST TEMP F_IDENTIFIER GOTO_LABEL LABEL  PARAM STRING_LITERAL CHAR_CONST
%token GLOBAL  IF GOTO RETURN RETVAL CALL LE_OP EQ_OP GE_OP NE_OP   LOCAL
%%

start : program
;
program : {cout <<".bss"<<endl;} globals {cout <<".text"<<endl;} functions {cout <<".data"<<endl;for(auto it=rushi_data.begin();it!=rushi_data.end();it++){cout<<it->first<<": .asciz "<<it->second<<endl;}}
;
globals : 
         | global_decl  globals
;
global_decl : GLOBAL IDENTIFIER {cout<< $2 << ": .space 4" << endl;global_declarations.insert($2);} 
              | GLOBAL IDENTIFIER '[' INT_CONST ']' {cout<< $2 << ": .space " << $4 << endl;global_declarations.insert($2);} 
;

functions : 
          | function functions
;
function : F_IDENTIFIER   fundecls {
    string temp=string($1);
    temp.pop_back();
    cout << ".globl " << temp << endl;
    cout << $1 << endl;
    print_func();
  
}
;

paramdecl : IDENTIFIER '=' PARAM {mp[$1]=to_string(param_count);param_count+=4;}
;
fundecls : 
         | fundecl fundecls
;
fundecl : assignment_statement {}
         | paramdecl
         | random_declr
         | func_call
         | if_statement
         | GOTO GOTO_LABEL {vec.push_back("jmp ."+string($2));}
         | LABEL {vec.push_back("."+string($1));}
         | retvaldecl
         | RETURN
;

random_declr : LOCAL IDENTIFIER {local_count-=4;mp[$2]=to_string(local_count);} 
            | LOCAL IDENTIFIER '[' INT_CONST ']' {local_count-=ceil((float)atoi($4)/4)*4;mp[$2]=to_string(local_count);local_arrays.push_back(string($2));}
;
assignment_statement : direct
                        | indirect
;
direct : IDENTIFIER '=' TEMP 
{
    if(global_declarations.find($1) != global_declarations.end())
 {
   string temp = "movl "+ mp[$3] + "(%ebp), %eax";
   vec.push_back(temp);
   temp = "movl %eax, " + string($1);
    vec.push_back(temp);
 }
 else
 {
    string temp = "movl "+ mp[$3] + "(%ebp), %eax";
    vec.push_back(temp);
    temp = "movl %eax, " + mp[$1] + "(%ebp)";
    vec.push_back(temp);
 } 
}

 | IDENTIFIER '=' INT_CONST
{
    if(global_declarations.find($1) != global_declarations.end())
    {
        string temp= "movl $" + string($3) + ", %eax";
        vec.push_back(temp);
        temp = "movl %eax, " + string($1);
        vec.push_back(temp);

    }
    else
    {
        string temp = "movl $" + string($3) + ", %eax";
        vec.push_back(temp);
        temp = "movl %eax, " + mp[$1] + "(%ebp)";
        vec.push_back(temp);

    }
   

}

 | IDENTIFIER '[' TEMP ']' '=' TEMP
 {
    if (global_declarations.find($1) != global_declarations.end())
    {
       string temp ="movl "+mp[$3]+"(%ebp), %eax";
         vec.push_back(temp);
       temp ="movl $"+string($1)+ ", %ebx";//change
         vec.push_back(temp);
         temp ="addl %eax, %ebx";
            vec.push_back(temp);
            // temp ="movl "+mp[$6]+"(%ebp), %eax";
            temp="movb "+mp[$6]+"(%ebp), %al";
            vec.push_back(temp);
            // temp ="movb %eax, (%ebx)";
            temp="movb %al, (%ebx)";
            vec.push_back(temp);
    }
    else
    {
        string temp="movl "+mp[$3]+"(%ebp), %eax";
        vec.push_back(temp);
        temp="movl "+mp[$1]+"(%ebp), %ebx";
        vec.push_back(temp);
        temp="addl %eax, %ebx";
        vec.push_back(temp);
        temp="movb "+mp[$6]+"(%ebp), %al";
        vec.push_back(temp);
        temp="movb %al, (%ebx)";
        vec.push_back(temp);

    }


 
 }
| TEMP '=' IDENTIFIER
{
    if(mp.find($1)==mp.end())
    {
        local_count-=4;
        mp[$1]=to_string(local_count);
    }
    if(global_declarations.find($3) != global_declarations.end())
    {
        string temp = "movl " + string($3) + ", %eax";
        vec.push_back(temp);
        temp = "movl %eax, " + mp[$1] + "(%ebp)";
        vec.push_back(temp);
    }
    else
    { string temp;
        if(local_arrays.find($3)==local_arrays.end()){ temp = "movl " + mp[$3] + "(%ebp), %eax";
        vec.push_back(temp);} 
        else {
            temp="leal " + mp[$3] + "(%ebp), %eax";
            vec.push_back(temp);
        }
        temp = "movl %eax, " + mp[$1] + "(%ebp)";
        vec.push_back(temp);
    }
    
}

| TEMP '=' IDENTIFIER '[' TEMP ']'
{
  if(mp.find($1)==mp.end())
  {
      local_count-=4;
      mp[$1]=to_string(local_count);
  }
    if(global_declarations.find($3) != global_declarations.end())
    {
        string temp="movl "+mp[$5]+"(%ebp), %eax";
        vec.push_back(temp);
        temp="movl $"+string($3)+", %ebx";
        vec.push_back(temp);
        temp="addl %eax, %ebx";
        vec.push_back(temp);
        temp="movb (%ebx), %al";
        vec.push_back(temp);
        temp="movb %al, "+mp[$1]+"(%ebp)";

    }
    else
    {
        string temp="movl "+mp[$5]+"(%ebp), %eax";
        vec.push_back(temp);
        temp="movl "+mp[$3]+"(%ebp), %ebx";
        vec.push_back(temp);
        temp="addl %eax, %ebx";
        vec.push_back(temp);
        temp="movb (%ebx), %al";
        vec.push_back(temp);
        temp="movb %al, "+mp[$1]+"(%ebp)";
        vec.push_back(temp);
      
    }



}
| TEMP '=' TEMP
{
    if(mp.find($1)==mp.end())
    {
        local_count-=4;
        mp[$1]=to_string(local_count);
    }
    string temp = "movl "+mp[$3]+"(%ebp), %eax";
    vec.push_back(temp);
    temp = "movl %eax, "+mp[$1]+"(%ebp)";
    vec.push_back(temp);
}
| TEMP '=' STRING_LITERAL
{
    if(mp.find($1)==mp.end())
    {
        local_count-=4;
        mp[$1]=to_string(local_count);

    }
    string random = "rushi"+to_string(datacount);
    rushi_data[random] = string($3);
    datacount++;
    string temp = "movl $"+random+", %eax";
    vec.push_back(temp);
    temp = "movl %eax, "+mp[$1]+"(%ebp)";
    vec.push_back(temp);


   
}
| TEMP '=' CHAR_CONST
{
    if(mp.find($1)==mp.end())
    {
        local_count-=4;
        mp[$1]=to_string(local_count);
    }
    string temp = "movb $"+string($3)+", %al";
    vec.push_back(temp);
    temp = "movb %al, "+mp[$1]+"(%ebp)";
    vec.push_back(temp);
}
| TEMP '=' INT_CONST
{
if (mp.find($1)==mp.end()){
    local_count-=4;
    mp[$1]=to_string(local_count);
}
string temp = "movl $" + string($3) + ", %eax";
vec.push_back(temp);
temp = "movl %eax, " + mp[$1] + "(%ebp)";
vec.push_back(temp);
}
| TEMP '='  '-' INT_CONST
{
    if(mp.find($1)==mp.end())
    {
        local_count-=4;
        mp[$1]=to_string(local_count);
    }
    string temp = "movl $" + to_string(atoi($4)) + ", %eax";
    vec.push_back(temp);
    temp = "negl %eax";
    vec.push_back(temp);
    temp = "movl %eax, " + mp[$1] + "(%ebp)";
    vec.push_back(temp);
    
}
 | TEMP '=' RETVAL
{

    if(mp.find($1)==mp.end())
    {
        local_count-=4;
        mp[$1]=to_string(local_count);
    }
    string temp= "movl %eax, "+mp[$1]+"(%ebp)";
    vec.push_back(temp);
}
;
indirect : TEMP '=' arithmetic_expression {
    if(mp.find($1)==mp.end())
    {
        local_count-=4;
        mp[$1]=to_string(local_count);
    }
    string temp = "movl %eax, "+mp[$1]+"(%ebp)";
    vec.push_back(temp);
}
| TEMP '=' relational_expression
{
    if(mp.find($1)==mp.end())
    {
        local_count-=4;
        mp[$1]=to_string(local_count);
    }
  
}
;


arithmetic_expression   : TEMP '+' TEMP 
{
    string temp = "movl "+mp[$1]+"(%ebp), %eax";
    vec.push_back(temp);
    temp = "movl "+mp[$3]+"(%ebp), %ebx";
    vec.push_back(temp);
    temp = "addl %ebx, %eax";
    vec.push_back(temp);
}
| TEMP '-' TEMP
{
    string temp = "movl "+mp[$1]+"(%ebp), %eax";
    vec.push_back(temp);
    temp = "movl "+mp[$3]+"(%ebp), %ebx";
    vec.push_back(temp);
    temp = "subl %ebx, %eax";
    vec.push_back(temp);
}
| TEMP '*' TEMP
{
    string temp = "movl "+mp[$1]+"(%ebp), %eax";
    vec.push_back(temp);
    temp = "movl "+mp[$3]+"(%ebp), %ebx";
    vec.push_back(temp);
    temp = "imull %ebx, %eax";
    vec.push_back(temp);
}
| TEMP '/' TEMP
{
    string temp = "movl "+mp[$1]+"(%ebp), %eax";
    vec.push_back(temp);
    temp = "cltd";
    vec.push_back(temp);
    temp = "movl "+mp[$3]+"(%ebp), %ebx";
    vec.push_back(temp);
    
    temp= "idivl %ebx";
    vec.push_back(temp);
}

;
relational_expression : TEMP LE_OP TEMP
{
    string temp = "movl "+mp[$1]+"(%ebp), %eax";
    vec.push_back(temp);
    temp = "movl "+mp[$3]+"(%ebp), %ebx";
    vec.push_back(temp);
    temp = "cmpl %ebx, %eax";
    vec.push_back(temp);
    jump = "jle ";
    
}
| TEMP EQ_OP TEMP
{
    string temp = "movl "+mp[$1]+"(%ebp), %eax";
    vec.push_back(temp);
    temp = "movl "+mp[$3]+"(%ebp), %ebx";
    vec.push_back(temp);
    temp = "cmpl %ebx, %eax";
    vec.push_back(temp);
    jump = "je ";
    
}
| TEMP GE_OP TEMP
{
    string temp = "movl "+mp[$1]+"(%ebp), %eax";
    vec.push_back(temp);
    temp = "movl "+mp[$3]+"(%ebp), %ebx";
    vec.push_back(temp);
    temp = "cmpl %ebx, %eax";
    vec.push_back(temp);
    jump = "jge ";
    
}
| TEMP NE_OP TEMP
{
 string temp = "movl "+mp[$1]+"(%ebp), %eax";
    vec.push_back(temp);
    temp = "movl "+mp[$3]+"(%ebp), %ebx";
    vec.push_back(temp);
    temp = "cmpl %ebx, %eax";
    vec.push_back(temp);
    jump = "jne ";
    

}
| TEMP '<' TEMP
{

    string temp = "movl "+mp[$1]+"(%ebp), %eax";
    vec.push_back(temp);
    temp = "movl "+mp[$3]+"(%ebp), %ebx";
    vec.push_back(temp);
    temp = "cmpl %ebx, %eax";
    vec.push_back(temp);
    jump = "jl ";
}
| TEMP '>' TEMP
{
string temp = "movl "+mp[$1]+"(%ebp), %eax";
    vec.push_back(temp);
    temp = "movl "+mp[$3]+"(%ebp), %ebx";
    vec.push_back(temp);
    temp = "cmpl %ebx, %eax";
    vec.push_back(temp);
    jump = "jg ";


}
;

if_statement : IF '(' TEMP ')' GOTO GOTO_LABEL {vec.push_back( jump+ " ."+string($6));}

;

func_call : func_params {
 int siz = vec_temp.size();
 for (int i=siz-1;i>=0;i--)
 {
     string temp = "pushl "+mp[vec_temp[i]]+"(%ebp)";
     vec.push_back(temp);
 }
 
 
} CALL IDENTIFIER {
    string temp = "call "+string($4);
    vec.push_back(temp);
    temp = "addl $"+to_string(4*vec_temp.size())+", %esp";
    vec.push_back(temp);
    vec_temp.clear();
}
;
func_params : 
            | func_param func_params
;
func_param : PARAM '=' TEMP {vec_temp.push_back($3);}

;

retvaldecl : RETVAL '=' TEMP 
{
    string temp = "movl "+mp[$3]+"(%ebp), %eax";
    vec.push_back(temp);
}
;


%%
void print_vec()
{
    for(int i=0;i<vec.size();i++)
    {
        cout << vec[i] << endl;
    }
    vec.clear();
}

void print_func()
{
    cout <<"pushl %ebp" << endl;
    cout <<"movl %esp, %ebp" << endl;
    cout <<"subl $"<<(local_count*-1)<<", %esp" << endl;
    print_vec();
    cout <<"movl %ebp, %esp" << endl;
    cout <<"popl %ebp" << endl;
    cout <<"ret" << endl;
    local_count = 0;
    mp.clear();
    param_count = +8;
    

}
void yyerror(const char *s) {
    cout <<"Line number: " << yylineno << " Error: " << s << endl;
   
    exit(1);
}

int main() {
    yyparse();
    return 0;
}