#include <stdlib.h>
#include <stdio.h>
#include <string.h>
int i;

struct template{
	char name[50];
	char token[50];
	char type[50];
	char scope[10];
	char stack[10];
	int level;
	struct template *next;
}*table[100];

int hashFunction(char *str,char *scopeid){
	int sum = 0;
	for(i=0;str[i]!='\0';i++){
		sum += str[i];
	}
	for(i=0;scopeid[i]!='\0';++i)
		sum += scopeid[i];
	return sum % 100;
}

struct template* searchIndex(int index,char* str){
	struct template *head = table[index];
	struct template *temp;
	while(head != NULL){
		if(head->next == NULL)
			temp = head;
		if(strcmp(head->name,str)==0)
			return NULL;
		else
			head = head->next;
	}
	return temp;
}

struct template *makenode(char *name,char *token, char *type, char *scope, char *stack){
	struct template *entry = (struct template*) malloc(sizeof(struct template));
	strcpy(entry->name,name);
	strcpy(entry->token,token);
	strcpy(entry->scope,scope);
	strcpy(entry->type,type);
	strcpy(entry->stack,stack);
	entry->level = strlen(stack);
	entry->next = NULL;
	return entry;
}

void insertHash(char *str,char *token,char *type,char *scope, char *stack){
	int index = hashFunction(str,stack);
	if(table[index] == NULL){
		table[index] = makenode(str,token,type,scope,stack);
	}
	else{
		struct template *temp = searchIndex(index,str);
		if(temp != NULL){
			temp->next = makenode(str,token,type,scope,stack);
		}
	}
}

void display(){
	struct template *ptr;
	printf("(name,\ttoken,\t\ttype,\tscope,\tscope-id,\tlevel)\n\n");
	for(i=0;i<100;++i){
		if(table[i] != NULL){
			ptr = table[i];
			while(ptr != NULL){
				printf("(%s,\t%s,\t%s,\t%s,\t%s,\t%d)\t", ptr->name,ptr->token,ptr->type,ptr->scope,ptr->stack,	ptr->level);
				ptr = ptr->next;
			}printf("\n");
		}
	}
}

// putsym(char *name,char *token,int type,int scope){
// 	if(type == 1)
// 		insertHash(name,token,"int","global");
// }
