%{
	#include <iostream>
	#include <string.h>
	#include <stdlib.h>
    #include <vector>
    #include <bits/stdc++.h>
    #include<fstream>
    using namespace std;
	void yyerror(const char *);
	int yylex(void);
    extern char *yytext;
    extern int yylineno;
    extern FILE *yyin;
    map<int,pair<string,vector<string>>> tac;
    int global_label = 1;
    map<string,int> label_to_line;
    vector<string> temp;
    map<int,set<string>> insets;
    map<int,set<string>> outsets;
    set<int> redundant;
    map<int,set<int>> flow_graph;
   map<int,set<int>> prevs;
    
%}

%union {
    char *str_val;  
}

%token <str_val> ID  INT_LIT 
%token IF GOTO PRINT OP C_OP

%%

program : taclines
;
taclines : tacline taclines
          | tacline     
;
tacline : assignment {tac[global_label] = make_pair("assignment",temp);temp.clear();global_label++;}
         | unary_assignment {tac[global_label] = make_pair("unary_assignment",temp);temp.clear();global_label++;}
         | conditional_jump
         | unconditional_jump
         | label_def
         | io_statement
;
assignment : ID '=' expr {temp.push_back($1);} 
;
expr : ID OP ID {temp.push_back($1);temp.push_back($3);} 
     | ID OP INT_LIT {temp.push_back($1);} 
     | INT_LIT OP ID {temp.push_back($3);} 
     | INT_LIT OP INT_LIT
     | ID  {temp.push_back($1);} 
     | INT_LIT
;

unary_assignment : ID '=' OP ID {temp.push_back($1);temp.push_back($4);} 
;
conditional_jump : IF ID  C_OP ID GOTO ID  {tac[global_label] = make_pair("conditional_jump",vector<string>{string($2),string($4),string($6)});global_label++;}
;
unconditional_jump : GOTO ID {tac[global_label] = make_pair("unconditional_jump",vector<string>{string($2)});global_label++;}
;
label_def : ID ':' {label_to_line[$1] = global_label;tac[global_label] = make_pair("label_def",vector<string>{string($1)});global_label++;}
;
io_statement : PRINT ID {tac[global_label] = make_pair("io_statement",vector<string>{string($2)});global_label++;}
;
%%
void yyerror(const char *s) {
    cout <<"Line number: " << yylineno << " Error: " << s << endl;
   
    exit(1);
}

int main(int argc, char *argv[]) {
    yyin = fopen(argv[1], "r");
    yyparse();
    fclose(yyin);
    /* cout <<"hi"<<endl; */
    
  

for (int i=1; i<global_label; i++)
{
 string type=tac[i].first;
 vector<string> operands=tac[i].second;
 if(type=="conditional_jump")
 {
    int line = label_to_line[operands[2]];
    /* cout << line << endl; */
    flow_graph[i].insert(line);
    flow_graph[i].insert(i+1);
    prevs[line].insert(i);
    prevs[i+1].insert(i);

 }
 else if (type=="unconditional_jump")
 {
    int line = label_to_line[operands[0]];
    flow_graph[i].insert(line);
    prevs[line].insert(i);
 }
 else 
 {
    flow_graph[i].insert(i+1);
    prevs[i+1].insert(i);
    /* cout <<i <<" "<<type<<endl; */
 }

}
while(1)
{int intial_s=0;
int final_s=0;
do {
intial_s=final_s;
for (int i=global_label-1; i>=1; i--)
{
 
 string type=tac[i].first;
 vector<string> operands=tac[i].second;
 
 int size=operands.size();
 if (size==0)
 {
        continue;
 }
 set<string>inset;
 set<string>outset;

 if (type=="assignment")
 { 
   for ( auto x : flow_graph[i])
   {
    for (auto y : insets[x])
    {
        outset.insert(y);
    }
   }
   /* cout <<operands[size-1]<<"rushi"<<endl; */
   
   for (auto a :outset)
   {
    inset.insert(a);
   }
   inset.erase(operands[size-1]);
   for (int p=0;p<size-1;p++)
   {
    inset.insert(operands[p]);

   }

  insets[i]=inset;
  outsets[i]=outset;


 }
 else if (type=="unary_assignment")
 {
   for ( auto x : flow_graph[i])
   {
    for (auto y : insets[x])
    {
        outset.insert(y);
    }
   }
    for (auto a :outset)
    {
     inset.insert(a);
    }
    inset.erase(operands[0]);
    inset.insert(operands[1]);
    insets[i]=inset;
    outsets[i]=outset;
 }
 else if (type=="io_statement")
 {
  for (auto x : flow_graph[i])
  {
    for (auto y : insets[x])
    {
        outset.insert(y);
    }
  }
    for (auto a :outset)
    {
        inset.insert(a);
    }
    /* cout <<"print "<<operands[0]<<endl; */
    inset.insert(operands[0]);
    insets[i]=inset;
    outsets[i]=outset;
 }
 else if (type=="unconditional_jump")
 {
  for (auto x : flow_graph[i])
  {
    for (auto y : insets[x])
    {
        outset.insert(y);
    }
  }
    for (auto a :outset)
    {
        inset.insert(a);
    }
    insets[i]=inset;
    outsets[i]=outset;
 }
 else if (type=="conditional_jump")
 {
  for (auto x : flow_graph[i])
  {
    for (auto y : insets[x])
    {
        outset.insert(y);
    }
  }
    for (auto a :outset)
    {
        inset.insert(a);
    }
    inset.insert(operands[0]);
    inset.insert(operands[1]);
    insets[i]=inset;
    outsets[i]=outset;
 }
 else if (type=="label_def")
 {
  for (auto x : flow_graph[i])
  {
    for (auto y : insets[x])
    {
        outset.insert(y);
    }
  }
    for (auto a :outset)
    {
        inset.insert(a);
    }
    /* cout <<"contents of label_def"<<endl;
    for (auto x : inset)
    { cout <<"inset ";
        cout << x << " ";
    } */
    insets[i]=inset;
    outsets[i]=outset;
 }
}
final_s=0;
for (int i=1; i<global_label; i++)
{
    for (auto x : outsets[i])
    {
        final_s+=x.size();

    }
    for (auto x : insets[i])
    {
        final_s+=x.size();
    }
}
}
while (intial_s < final_s);
bool flag=false;

for (int i=1;i<global_label;i++)
{
    string type=tac[i].first;
    vector<string> operands=tac[i].second;
    int size=operands.size();
    if (size==0)
    {
        continue;
    }

    if (type=="assignment")
    {
        if (outsets[i].find(operands[size-1])==outsets[i].end())
        {
            redundant.insert(i);
            tac.erase(i);
            flag=true;
        for (auto x : prevs[i])
        {
            for (auto y : flow_graph[i])
            {
                flow_graph[x].insert(y);
                flow_graph[x].erase(i);
                prevs[y].insert(x);
                prevs[y].erase(i);
            }
        }
        }

    }
    else if (type=="unary_assignment")
    {
        if (outsets[i].find(operands[0])==outsets[i].end())
        {
            redundant.insert(i);
            tac.erase(i);
            flag=true;
        for (auto x : prevs[i])
        {
            for (auto y : flow_graph[i])
            {
                flow_graph[x].insert(y);
                flow_graph[x].erase(i);
                prevs[y].insert(x);
                prevs[y].erase(i);
            }
        }
        }

    }
}


if (flag==false)
{
    break;
}

outsets.clear();
insets.clear();




}

/* cout <<"bye"<<endl; */

ifstream file(argv[2]);
string line;
while (getline(file,line))
{
    int q=stoi(line);
  if (redundant.find(q)!=redundant.end())
  {
    cout <<"Line removed in optimized TAC"<<endl;
  }
  else
  {
    for (auto i : outsets[q])
    {
        cout << i << " ";
    }
    if(outsets[q].size()!=0)
    {
        cout << endl;
    }
    else 
    {
        cout <<" "<<endl;
    }
    
  }

}



 
    return 0;
}