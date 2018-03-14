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

void push(int val){
  char *temp;
  int len = strlen(stack);
  temp = (char *)malloc((len+1)*sizeof(char));
  char num = val + '0';
  int i=0;
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


%}

%token INT FLOAT CHAR DOUBLE VOID STRING
%token FOR WHILE
%token IF ELSE PRINTF
%token STRUCT
%token NUM ID
%token INCLUDE
%token DOT

%right '='
%left AND ORinsert
%left '<' '>' LE GE EQ NE LT GT
%%

start: start Function
	| Function
	| Declaration
	;

/* Declaration block */
Declaration: Type Assignment ';'
	| Assignment ';'
	| FunctionCall ';'
	| ArrayUsage ';'
	| Type ArrayUsage ';'
	| StructStmt ';'
	| error
	;

/* Assignment block */
Assignment: ID '=' Assignment
	| ID '=' FunctionCall
	| ID '=' ArrayUsage
	| ArrayUsage '=' Assignment
	| ID ',' Assignment
	| NUM ',' Assignment
	| ID '+' Assignment
	| ID '-' Assignment
	| ID '*' Assignment
	| ID '/' Assignment
	| NUM '+' Assignment
	| NUM '-' Assignment
	| NUM '*' Assignment
	| NUM '/' Assignment
	| STRING
	| '(' Assignment ')'
	| '-' '(' Assignment ')'
	| '-' NUM
	| '-' ID
	|   NUM
	|   ID
	;

/* Function Call Block */
FunctionCall : ID'('')'
	| ID'('Assignment')'
	;

/* Array Usage */
ArrayUsage : ID'['Assignment']'
	;

/* Function block */
Function: Type ID '(' ArgListOpt ')' CompoundStmt
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
Type:	INT {type = "int";}
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
