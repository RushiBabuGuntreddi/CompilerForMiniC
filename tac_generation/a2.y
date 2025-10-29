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
    int line_number = 1;
    unordered_map<string, int> func_params;
    stack<vector<string>> func_params_args;
    stack<vector<string>> if_stack;
    stack<string> func_call_stack;
    stack<string> else_labels;
    stack<string> exit_labels;
    set<string> global_variables;
    set<string> local_variables;
    int ifs_num=1;
    string true_L , false_L,exit_L;
    string generate (const string s,int &val);
    string process_function_call(string func_call_name);
    void check (string var);

    vector<string>tac;
    void print_tac();
    
    int global=0;
    bool declared=false;
    string func_name;
    string func_call_name;
    string t ="t";
    string if_label;
    string else_label;
    string while_start_label;
    string while_body_label;
    string while_exit_label;
    stack<string> while_starts;
    stack<string>while_bodys;
    stack<string>while_exits;
    stack<vector<string>> for_change_stack;
    string exit_label;
    int t_number=1;
    string temp;
    class Node {
        public :
        string key ;
        Node* left;
        Node* right;
        vector<string> tac_for_node;
        Node(string key) {
            this->key = key;
            left = right = NULL;
        }
    };

    void process_tree(Node* root , string true_label, string false_label) {
        if (root == NULL) {
            return;
        }
        if(root->left==nullptr && root->right==nullptr)
        {
            for (auto i : root->tac_for_node)
            {
                tac.push_back(i);
            }

            tac.push_back("if " + root->key + " goto " + true_label);
            tac.push_back("goto " + false_label);
            return ;
        }
        string new_label = generate("L",ifs_num);
        if (root->key=="or") {
            
            process_tree(root->left,true_label,new_label);
               tac.push_back(new_label + ":");
            process_tree(root->right,true_label,false_label);
            return ;
        }
        else if (root->key=="and") {
            
            process_tree(root->left,new_label,false_label);
            tac.push_back(new_label + ":");
            process_tree(root->right,true_label,false_label);
            return ;
        }
        else if (root->key=="not") {
            process_tree(root->left,false_label,true_label);
            return ;
        }
    }
%}


%union {
    class Node *node;
    char *str_val;  
}


%token<str_val> IDENTIFIER STRING_LITERAL INT_CONST CHAR_CONST

%token IF ELSE WHILE FOR RETURN 
%token INT CHAR 
%token EQ_OP NE_OP LE_OP GE_OP OR AND
%token EXP_OP 
%left OR
%left  AND
%right NOT

%type<str_val> variable expression rvalue constant arithmetic_expression function_call g_variable
%type<node>  condition_list condition for_condition
%right  '<' '>' EQ_OP NE_OP LE_OP GE_OP
%left   '+' '-'
%left   '*' '/'
%left   EXP_OP

%start program

%%

program: lines

lines:
    oneline
    | lines oneline 

oneline:
    global_variable_declaration ';' 
    | function_declaration
;
global_variable_declaration : type_specifier  g_variable {cout <<"global "<<$2<<endl; global_variables.insert(string($2));}
;
g_variable : 
    IDENTIFIER { $$=$1;  }
    | IDENTIFIER '[' expression ']' {strcpy($$, $1);strcat($$, "[");strcat($$, $3);strcat($$, "]");} 

type_specifier:  INT
    | CHAR

;

/* global_variable_declaration : type_specifier variable {} */

variable_declaration:
    type_specifier {declared=true;} declaration_list {declared=false;}

function_declaration:
    type_specifier IDENTIFIER  '(' {cout<<$2<<": "<<endl;func_name=$2;}  parameter_list ')' '{' statements '}' {print_tac();cout<<endl;tac.clear();local_variables.clear();}


declaration_list:
    declaration_list ',' variable 
    | declaration_list ',' assignment_statement
    | variable 
    | assignment_statement

;
variable: 
    IDENTIFIER { $$=$1; if (declared) {local_variables.insert(string$1);}else {check(string($1));} }
    | IDENTIFIER '[' expression ']' {if (declared) {local_variables.insert(string($1));}else {check(string($1));};strcpy($$,$1);strcat($$,"[");strcat($$,$3);strcat($$,"]") ;} 

parameter_list:
    | parameter_list ',' function_parameter
    | function_parameter

function_parameter:
    type_specifier IDENTIFIER {local_variables.insert(string($2));int num=++func_params[func_name];temp = generate("param",num); tac.push_back(temp + " = " + $2); }
    | type_specifier IDENTIFIER '[' function_array_1D ']' 

function_array_1D: 
    | expression

statements: 
    | statements statement
 
statement:
    assignment_statement ';'    
    | if_statement {cout <<"goto "<<else_labels.top()<<endl;cout <<else_labels.top()<<":"<<endl;else_labels.pop();}
    | if_else_statement   {}
    | iteration_statement       
    | return_statement ';'      
    | variable_declaration ';'  
    | function_call ';' {process_function_call($1);print_tac();tac.clear();}        

assignment_statement:
    variable '='  expression {if (tac.size()==0){temp= generate("t",t_number);tac.push_back(temp + " = " + string($3));tac.push_back(string($1) + " = " + temp);}else {tac.push_back(string($1) + " = " + string($3));}print_tac();tac.clear();}


;
if_statement:
    IF '(' condition_list ')' { true_L=generate("L",ifs_num);false_L=generate("L",ifs_num);process_tree($3,true_L,false_L);tac.push_back(true_L + ":");print_tac();tac.clear();else_labels.push(false_L);} body 
;
if_else_statement:
     if_statement  ELSE {exit_L=generate("L",ifs_num);cout<<"goto "<<exit_L<<endl;cout<<else_labels.top()<<":"<<endl;else_labels.pop();exit_labels.push(exit_L);} body {cout<<exit_labels.top()<<":"<<endl;exit_labels.pop();}

   
;

condition_list  : condition_list OR condition_list {$$=new Node("or");$$->left=$1;$$->right=$3;}
    | condition_list AND condition_list {$$=new Node("and");$$->left=$1;$$->right=$3;}
    | condition {$$=$1;}
;
condition :  expression EQ_OP expression {temp = generate("t,",t_number);tac.push_back(temp + " = " + string($1)+ " == " +  string($3)) ;$$=new Node (temp);$$->tac_for_node=tac;tac.clear();}
    | expression NE_OP expression {temp= generate("t",t_number);tac.push_back(temp + " = " + string($1)+ " != " +  string($3)) ;$$=new Node (temp);$$->tac_for_node=tac;tac.clear();}
    | expression LE_OP expression {temp=generate("t",t_number);tac.push_back(temp + " = " + string($1)+ " <= " +  string($3)) ;$$=new Node (temp);$$->tac_for_node=tac;tac.clear();}
    | expression GE_OP expression {temp=generate("t",t_number);tac.push_back(temp + " = " + string($1)+ " >= " +  string($3)) ;$$=new Node (temp);$$->tac_for_node=tac;tac.clear();}
    | expression '<' expression  {temp=generate("t",t_number);tac.push_back(temp + " = " + string($1)+ " < " +  string($3)) ;$$=new Node (temp);$$->tac_for_node=tac;tac.clear();}
    | expression '>' expression {temp=generate("t",t_number);tac.push_back(temp + " = " + string($1)+ " > " +  string($3)) ;$$=new Node (temp);$$->tac_for_node=tac;tac.clear();}
    | expression {}
    | NOT condition  {$$=new Node("not");$$->left=$2;}
    | '(' condition_list ')' {$$=$2;}

;



body:
    '{' statements '}'
    | statement

iteration_statement:
    WHILE '(' condition_list ')' {exit_L=generate("L",ifs_num);cout<<exit_L<<":"<<endl;true_L=generate("L",ifs_num);false_L=generate("L",ifs_num);process_tree($3,true_L,false_L);tac.push_back(true_L + ":");print_tac();tac.clear();else_labels.push(false_L);exit_labels.push(exit_L);}  body {cout<<"goto "<< exit_labels.top()<<endl;exit_labels.pop();cout<<else_labels.top()<<":"<<endl;else_labels.pop();}
    | FOR '(' for_assign ';' {exit_L=generate("L",ifs_num);cout<<exit_L<<":"<<endl;exit_labels.push(exit_L);} for_condition {true_L=generate("L",ifs_num);false_L=generate("L",ifs_num);process_tree($6,true_L,false_L);tac.push_back(true_L + ":");print_tac();tac.clear();else_labels.push(false_L);} ';' for_change {for_change_stack.push(tac);tac.clear();} ')' body {for (auto it : for_change_stack.top())cout <<it<<endl;cout <<"goto "<<exit_labels.top()<<endl;cout<<else_labels.top()<<":"<<endl;else_labels.pop();exit_labels.pop();}

for_assign:
    | assignment_statement

for_condition:  condition {$$=$1;}

for_change:  
       | for_assignment_statement
;
for_assignment_statement : variable '='  expression {if (tac.size()==0){temp= generate("t",t_number);tac.push_back(temp + " = " + string($3));tac.push_back(string($1) + " = " + temp);}else {tac.push_back(string($1) + " = " + string($3));}print_tac();tac.clear();}

return_statement: RETURN expression { tac.push_back("retval = " +string($2));tac.push_back("return");print_tac();tac.clear(); }

/* printf_statement:
    PRINTF '(' STRING_LITERAL print_parameters ')' */

/* print_parameters:
    | ',' rvalue print_parameters
  */
expression:
    rvalue { $$=$1; }
    | function_call { strcpy($$,process_function_call(string($1)).c_str()); }
    | '(' expression ')' { $$=$2; }
    | arithmetic_expression { $$=$1; }

arithmetic_expression:
     expression '+' expression  {temp=generate("t",t_number);tac.push_back(temp + " = " + string($1)+ " + " +  string($3)) ;strcpy($$,temp.c_str()) ;}
    | expression '-' expression {temp=generate("t",t_number);tac.push_back(temp + " = " + string($1)+ " -"  +  string($3)) ;strcpy($$,temp.c_str()) ;}
    | expression '*' expression {temp=generate("t",t_number);tac.push_back(temp + " = " + string($1)+ " * " +  string($3)) ;strcpy($$,temp.c_str()) ;}
    | expression '/' expression {temp=generate("t",t_number);tac.push_back(temp + " = " + string($1)+ " / " +  string($3)) ;strcpy($$,temp.c_str()) ;}
 | expression EXP_OP expression {temp=generate("t",t_number);tac.push_back(temp + " = " + string($1)+ " ** "+  string($3)) ; strcpy($$,temp.c_str());}



function_call:
    IDENTIFIER   '('  {func_params_args.push(vector<string>{});} function_call_params ')' 
    {strcpy($$,$1);}
 

function_call_params:
    | function_call_params ',' expression {vector<string>& vec=func_params_args.top();if($3[0]=='t'){vec.push_back($3);}else {temp=generate("t",t_number);vec.push_back(temp);tac.push_back(temp+" = "+string($3));} }
    | expression {vector<string>& vec=func_params_args.top();if($1[0]=='t'){vec.push_back($1);}else {temp=generate("t",t_number);vec.push_back(temp);tac.push_back(temp+" = "+string($1));} }
;


constant: INT_CONST  {  $$=$1; }
    | CHAR_CONST { $$=$1; }
    | STRING_LITERAL { $$=$1; }

rvalue: variable { $$=$1; }
    | constant { $$=$1; }

%%


void check (string var){
    if (global_variables.find(var)==global_variables.end() && local_variables.find(var)==local_variables.end())
    {
        string s="undefined variable "+ var;
        yyerror(s.c_str());
    }
}
string generate (const string s,int &val){
    string temp = s + to_string(val);
    val++;
    return temp;
}

void print_tac() {
    for (int i=0;i<tac.size();i++)
    {
        cout << tac[i] << endl;
    }
}

 string process_function_call(string func_call_name) {
    vector<string> vec = func_params_args.top();
    for(int i=0;i<vec.size();i++)
    {
        string param = "param" + to_string(i+1);
        tac.push_back(param + " = " + vec[i]);
    }
    func_params_args.pop();
    tac.push_back("call " + func_call_name);
    temp = generate("t",t_number);
    tac.push_back(temp + " = retval");
    return temp;
   
}
void yyerror(const char *s) {
    fprintf(stderr, "%s\n", s);
    exit(1);
}

int main() {
    yyparse();
    return 0;
}