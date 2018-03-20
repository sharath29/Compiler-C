%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbolTable.h"
#include "y.tab.h"
extern FILE *fp,*yyin;
extern int yylineno;
extern char *yytext;
extern char *tempid;
extern char *type;
extern int scope;
extern char *stack;
int flag=0;
int arrayDim=0;
int i=0;

void push(int val){
  char *temp;
  int len = strlen(stack);
  temp = (char *)malloc((len+1)*sizeof(char));
  char num = val + '0';
  for(i=0;i<len;++i){
    temp[i] = stack[i];
  }temp[i]=num;
  temp[i+1]='\0';
  stack = (char *)malloc((len+1)*sizeof(char));
  strcpy(stack,temp);
}

void pop(){
	int len = strlen(stack);
	stack[len - 1] = '\0';
}

void func(char *str){
	int index = hashFunction(str,stack);
	struct template *temp = searchIndex(index,str);
	if(temp == NULL)
		printf("already declared\n");
	else{
		insert(str,stack,0);
		printf("inserted %s\n",str);
	}
}

void funcArray(char *str1,int dim){
	int index = hashFunction(str1,stack);
	printf("%d\n",dim);
	struct template *temp = searchIndex(index,str1);
	if(temp == NULL)
		printf("already declared\n");
	else{
		insert(str1,stack,dim);
		printf("inserted %s\n",str1);
	}
}

checkInsert(char *str){
	printf("flag %d",flag);
	if(flag){
		func(str);
	} 
	else{
		checkPresent(str);
	}
}

void checkPresent(char *str){
	int flag = 0;
	int len = strlen(stack);
	printf("len %d\n",len);
	for(i=len;i>0;--i){
		char *tempstr;
		tempstr = (char *)malloc((i+1)*sizeof(char));
		int j=0;
		for(j=0;j<i;++j){
			tempstr[j] = stack[j];
		}tempstr[j]='\0';
		int index = hashFunction(str,tempstr);
		struct template *temp = searchIndex(index,str);
		printf("str %s\n",tempstr);
		//struct template *ptr = table[index];
		//printf("(%s,\t%s,\t%s,\t%s,\t%s,\t%d)\t", ptr->name,ptr->token,ptr->type,ptr->scope,ptr->stack,	ptr->level);
		
		if(temp == NULL)
			flag=1;
	}
	if(!flag)
		printf("%s not declared\n",str);
}

%}

%token INT FLOAT CHAR DOUBLE VOID STRING
%token FOR WHILE
%token IF ELSE PRINTF
%token STRUCT
%token<str> ID
%token<ivalue> NUM
%token INCLUDE
%token DOT

%right '='
%left AND OR 
%left '<' '>' LE GE EQ NE LT GT

%union{
	int ivalue;
	char *str;
}

%%

start: start Function
	| Function
	| Declaration 
	;

/* Declaration block */
Declaration: Type Assignment ';' {flag=0;}
 	| Assignment ';'
	| FunctionCall ';'
	| ArrayUsage ';'
	| Type ArrayUsage ';' {flag=0;}
	| StructStmt ';'
	| error
	;


/* Assignment block */
Assignment: ID '=' Assignment {printf("hi %d\n",flag);checkInsert($1);}
	| ID '=' FunctionCall {if(flag) func($1);}
	| ID '=' ArrayUsage {if(flag) func($1);}
	| ArrayUsage '=' Assignment
	| ID ',' Assignment {if(flag) func($1);}
	| ID ',' ArrayUsage {if(flag) func($1);}
	| NUM ',' Assignment
	| ID '+' Assignment {if(flag) func($1);}
	| ID '-' Assignment {if(flag) func($1);}
	| ID '*' Assignment {if(flag) func($1);}
	| ID '/' Assignment {if(flag) func($1);}
	| NUM '+' Assignment
	| NUM '-' Assignment
	| NUM '*' Assignment
	| NUM '/' Assignment
	| STRING 
	| '(' Assignment ')'
	| '-' '(' Assignment ')'
	| '-' NUM
	| '-' ID {if(flag) func($2);}
	| NUM {arrayDim = $1;}
	| ID {if(flag) func($1);}
	;

/* Function Call Block */
FunctionCall : ID'('')'
	| ID'('Assignment')'
	;

/* Array Usage */
ArrayUsage : ID'['Assignment']' {printf("flag %d\n",flag);if(flag) funcArray($1,arrayDim);}
	

/* Function block */
Function: Type ID {if(flag) func($2);flag=0;} '(' ArgListOpt ')'  CompoundStmt 
	;
ArgListOpt: ArgList 
	|
	;
ArgList:  ArgList ',' Arg 	
	| Arg 					
	;
Arg:	Type ID 
	;
CompoundStmt:	'{' {++scope;push(scope);} StmtList '}' {pop();}
	;

StmtList:	StmtList Stmt
	|
	;
Stmt:	WhileStmt
	| Declaration
	| ForStmt
	| IfStmt
	| PrintFunc
	| ';'
	;

/* Type Identifier block */
Type:	INT {type = "int";flag=1;}
	| FLOAT {type = "float";}
	| CHAR  {type = "char";}
	| DOUBLE {type = "double";}
	| VOID 	{type = "void";}
	;

/* Loop Blocks */
WhileStmt: WHILE '(' Expr ')' Stmt
	| WHILE '(' Expr ')' CompoundStmt
	;

/* For Block */
ForStmt: FOR '(' Expr ';' Expr ';' Expr ')' Stmt
       | FOR '(' Expr ';' Expr ';' Expr ')' CompoundStmt
       | FOR '(' Expr ')' Stmt
       | FOR '(' Expr ')' CompoundStmt
	;

/* IfStmt Block */
IfStmt : IF '(' Expr ')'
	 	Stmt
	;

/* Struct Statement */
StructStmt : STRUCT ID '{' Type Assignment '}'
	;

/* Print Function */
PrintFunc : PRINTF '(' Expr ')' ';'
	;

/*Expression Block*/
Expr: Expr LE Expr
	| Expr GE Expr
	| Expr NE Expr
	| Expr EQ Expr
	| Expr GT Expr
	| Expr LT Expr
	| Type Assignment
	| Assignment
	| ArrayUsage
	;
%%

int main(int argc, char *argv[])
{
	yyin = fopen(argv[1], "r");

   if(!yyparse())
		printf("\nParsing complete\n");
	else
		printf("\nParsing failed\n");

	display();
	fclose(yyin);
    return 0;
}

yyerror(char *s) {
	printf("%d : %s %s\n", yylineno, s, yytext );
}
