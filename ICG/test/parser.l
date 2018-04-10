alpha [A-Za-z]
digit [0-9]

%%
[ \t] ;
\n {yylineno++;}
\/\/ ;
\/\*(.*\n).*\*\/ ;
"{" 						{open1(); return '{';}
"}" 						{close1(); return '}';}
if 							{return IF;}
while 						{return WHILE;}
do 							{return DO;}
for 						{return FOR;}
int 						{yylval.value.type="integer"; yylval.value.str = strdup(yytext);return INT;}
float 						{yylval.value.type="float"; return FLOAT;}
void 						{yylval.value.type="void"; return VOID;}
return 						{return RETURN;}
printf						{return PRINT;}
#include.*					{return PREPROC;}
"\+\+"						{return INC;}
{alpha}({alpha}|{digit})* 	{yylval.value.str = strdup(yytext); yylval.value.type = "identifier"; return ID;}
{digit}+ 					{yylval.value.str = strdup(yytext); yylval.value.type = "integer"; return NUM;}
{digit}+\.{digit} 			{yylval.value.str = strdup(yytext); yylval.value.type = "float"; return REAL;}
\"[^\"]*\" 					{yylval.value.str = strdup(yytext); yylval.value.type = "char"; return STRING;}
'=' 						{yylval.value.str = strdup(yytext); return '=';}
. 							{return yytext[0];}
%%