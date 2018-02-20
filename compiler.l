%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
char *tempid;
char *type;
int scope=0;
void insert(char*);
%}


alpha [a-zA-Z]
digit [0-9]

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
{digit}+       return NUM;
{alpha}({alpha}|{digit})* {insert(yytext);return ID;}
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

char *getScope(int scope){
	if(scope == 0)
		return "global";
	else if(scope == 1)
		return "main";
	else
		return "for";
}
void insert(char *yytext){
  int len = strlen(yytext);
  tempid = (char*)malloc((len+1)*sizeof(char));
  strcpy(tempid, yytext);
  insertHash(tempid,"identifier",type,getScope(scope));
}
