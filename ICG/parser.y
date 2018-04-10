%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "symbol.c"
	extern struct table;
	int scope=0,scopeIndex=0,top=0;
	int scopeStack[100];
	char charStack[20][100];
	int lnumStack[100];
	int ltop=0;
	int temp=0,lnum=0;
	char label[20];
	char *buff[5];
	
	void open1(){
		scope++;
		scopeStack[scopeIndex++]=scope;
	}	

	void close1(){
		scopeIndex--;
		scopeStack[scopeIndex]=0;
	}

	checkDeclaration(char *name,char *type){
		if(!notPresent(name)){
			struct table temp = checkInfo(name);
			if(temp.level == scopeIndex && temp.scope == scopeStack[scopeIndex-1])
				printf("\t\tredeclaration\n");
			else{
				insertIntoTable(name,type,"identifier",scopeIndex,scopeStack[scopeIndex-1]);
			}
		}
		else{
			insertIntoTable(name,type,"identifier",scopeIndex,scopeStack[scopeIndex-1]);
		}
	}

	void push(char *str){
		strcpy(charStack[++top],str);
	}

	void codegen(){
		sprintf(buff,"%d",temp++);
		strcpy(label,"t_");
		strcat(label,buff);
		printf("%s = %s %s %s\n",label,charStack[top-2],charStack[top-1],charStack[top]);
		strcpy(charStack[top-2],label);
		top = top-2;
	}

	void codegenAssign(){
		printf("%s = %s \n",charStack[top-2],charStack[top]);
		top = top-2;
	}

	if1(){
		lnum++;
		sprintf(buff,"%d",temp);
		strcpy(label,"t_");
		strcat(label,buff);
		printf("%s = not %s\n",label,charStack[top]);
		printf("\tif %s goto L%d:\n",label,lnum);
		lnumStack[++ltop]=lnum;
	}

	if2(){
		lnum++;
		printf("\tgoto L%d:\n",lnum);
		printf("L%d:\n",lnumStack[ltop--]);
		lnumStack[++ltop]=lnum;
	}

	if3(){
		printf("\tL%d:\n",lnumStack[ltop--]);
	}

	for1(){
		lnum++;
		printf("L%d:\n",lnum);
		lnumStack[++ltop]=lnum;
	}

	for2(){
		if1();
		lnum++;
		printf("\tgoto L%d:\n",lnum);
		lnumStack[++ltop]=lnum;
		lnum++;
		printf("L%d:\n",lnum);
		lnumStack[++ltop]=lnum;
	}

	for3(){
		printf("\tgoto L%d:\n",lnumStack[ltop-3]);
		printf("L%d:\n",lnumStack[ltop-1]);
	}

	for4(){
		printf("\tgoto L%d:\n",lnumStack[ltop]);
		printf("L%d:\n",lnumStack[ltop-2]);
		ltop -= 4;
	}

	wh1(){
		lnum++;
		printf("L%d:\n",lnum);
		lnumStack[++ltop]=lnum;
	}

	wh2(){
		if1();
	}

	wh3(){
		int y = lnumStack[ltop--];
		printf("\tgoto L%d:\n",lnumStack[ltop--]);
		printf("L%d:",y);
	}

%}


%token<value> FLOAT INT VOID
%token<value> RETURN IF DO FOR 
%token<value> STRING ID NUM REAL 
%token PRINT PREPROC ELSE WHILE INC
%right '='
%right MINUS
%left '-' '+'
%left '*' '/'
%type<value> E Array F T Constant Type '-' '('


%union{
	struct node{
		int ival;
		char *str;
		char *type;
	}value;
}

%%

start:	Function start
	|	Declaration start
	|	PREPROC start
	|
	;
Function: Type ID '(' ')' CompoundStmt {
		if(!(strcmp($2.str,"printf") && strcmp($2.str,"scanf") && strcmp($2.str,"getc"))){ printf("invalid identifier\n"); }
		else{
			insertIntoTable($2.str,$1.str,"function",scopeIndex,scopeStack[scopeIndex-1]);
		}
	}
	;
Type: INT
	| FLOAT
	| VOID
	;
CompoundStmt: '{' StmtList '}'
	;
StmtList: StmtList Stmt
	|
	;
Stmt: Declaration
	| if
	| while
	| for
	| CompoundStmt
	| RETURN ';'
	| RETURN Constant ';'
	| ID '(' ')' ';'
	| PRINT '(' STRING ')' ';'
	;
while: WHILE {wh1();} '(' E ')' {wh2();} CompoundStmt {wh3();}
	;
for: FOR '(' E {for1();}';' E {for2();}';' E {for3();}')' CompoundStmt {for4();}
	;
if: IF '(' E ')' {if1();} CompoundStmt {if2();} else
	;
else: ELSE CompoundStmt {if3();}
	|
	;
Constant: NUM
	| REAL
	;
Declaration: Type ID {push($2.str);} '=' {push("=");} E {codegenAssign();}';' {
		if(!strcmp($6.type,"identifier")){
			if(!notPresent($6.str)){
				struct table temp = checkInfo($6.str);
				if(strcmp(temp.type,$6.type)){
					printf("\t\ttype mismatch\n");
				}
			}
		}
		else if(strcmp($1.type,$6.type)){
			printf("\t\ttype mismatch\n");
		}

		checkDeclaration($2.str,$2.type);

	}
	| Type ID '[' Assignment ']' ';'{checkDeclaration($2.str,$2.type);}
	| Type ID ';' {checkDeclaration($2.str,$2.type);}
	| Assignment1 ';' 
	| error
	;
Assignment: ID {push($1.str);} '=' {push("=");} Constant {codegenAssign();}
	| ID '+' Assignment
	| ID ',' Assignment
	| Constant ',' Assignment
	| ID
	| Constant
	;
Assignment1: ID {push($1.str);} '=' {push("=");} E {codegenAssign();} {
		if(notPresent($1.str))
			printf("\t\t%s not declared\n",$1.str);
	}
	| ID ',' Assignment1
	| ID '+' Assignment1
	| Constant
	| ID
	;
E: 	 E '+' {push("+");} T {codegen();}
	|T
	|E '<' T
	|E '=' T
	|E INC
	|Array
	|STRING
	;
T: 	 T '*' {push("*");} F {codegen();}
	|T '/' {push("/");} F {codegen();}
	|F
	;
F: '(' E ')' {$$ = $2;}
	| ID {push($1.str);}
	| Constant {push($1.str);}
	| '-' F  %prec MINUS
	;
Array: ID '[' E ']'
	;

%%

#include "lex.yy.c"
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]){
	yyin = fopen(argv[1],"r");
	yyparse();
	if(!yyparse()){
		printf("parsing done\n");
	}
	else{
		printf("error\n");
	}
	printf("\n\t\t\tSYMBOL TABLE\n%-12s %-12s %-12s %-12s %-12s\n","token","type","tokentype","level","scope");
	print();
	fclose(yyin);
	return 0;
}

int yyerror(char *s){
	printf("Line:%d %s %s\n",yylineno,s,yytext);
}









