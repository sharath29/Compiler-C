%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
char *tempid;
char *type;
char *stack = "";
int scope=0;
void insert(char*,char*,int);
char string_buf[100];
//{type_declaration}[ ]*{identifier} {check(yytext);return;}
%}

%x VALUEPARSE ENDSTATE




alpha [a-zA-Z]
digit [0-9]
identifier {alpha}({alpha}|{digit})*
type_declaration "int "|"float "|"char "|"double "|"void "

%%
[ \t]		;
[ \n]   { yylineno = yylineno + 1;}


int	return INT;
float return FLOAT;
char return CHAR;
void return VOID;
double return DOUBLE;
for 	return FOR;
while	return WHILE;
if	return IF;
else	return ELSE;
printf  return PRINTF;
struct 	return STRUCT;
^"#include ".+ ;
{digit}+       {yylval.ivalue = atoi(yytext);return NUM;} 
{alpha}({alpha}|{digit})* {yylval.dragon.name = strdup(yytext);yylval.dragon.type="string";return ID;}
\"[^\"\n]+\" return STRING;
"<="    return LE;
">="    return GE;
"=="    return EQ;
"!="    return NE;
">"	return GT;
"<"	return LT;
"."     return DOT;
\/\/.* ;
\/\*(.*\n)*.*\*\/ ;
.       return yytext[0];
%%

int yywrap(){
	return 1;
}


void check(char *str){
	int index = hashFunction(str,stack);
	struct template *temp = searchIndex(index,str);
	if(temp == NULL) printf("already declared\n");
}

char *getScope(int scope){
	if(strlen(stack) == 0)
		return "global";
	else if(strlen(stack) == 1)
		return "function";
	else if(strlen(stack) == 2)
		return "loop";
	else if(strlen(stack) == 3)
		return "loop-loop";
	else
		return "";
}


void insert(char *yytext, char *stack,int dim){
  int len = strlen(yytext);
  tempid = (char*)malloc((len+1)*sizeof(char));
  strcpy(tempid, yytext);
  insertHash(tempid,"identifier",type,getScope(scope),stack,dim);
}
