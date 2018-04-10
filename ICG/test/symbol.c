#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int num=0;
struct table{
	char *name;
	char *type;
	int level;
	int scope;
}symbolTable[1000];


int notPresent(char *name){
	for(int i=0;i<num;++i){
		if(!strcmp(symbolTable[i].name,name)){
			return 0;
		}
	}
	return 1;
}

struct table checkInfo(char *name){
	for(int i=0;i<num;++i){
		if(!strcmp(name,symbolTable[i].name)){
			return symbolTable[i];
		}
	}
}

void insertIntoTable(char *name,char *type,int level,int scope){
		symbolTable[num].name=name;
		symbolTable[num].type=type;
		symbolTable[num].level=level;
		symbolTable[num].scope=scope;
		num++;
}

void print(){
	for(int i=0;i<num;++i){
		printf("%s\t\t%s\t\t%d\t\t%d\n",symbolTable[i].name,symbolTable[i].type,symbolTable[i].level,symbolTable[i].scope);
	}
}

// int main(){
// 	insertIntoTable("a","int",2,4);
// 	struct table temp = checkInfo("a");
// 	print();
// 	return 0;
// }