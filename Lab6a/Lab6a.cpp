#include<stdio.h>
#include<stdlib.h>
#include<string.h>

struct CodeNode
{
	char* code;//instruction string
	char* label;//NULL if no label
	char* operation;
	unsigned short addr;
	struct CodeNode* next;
};

struct LabelNode
{
	char lable[100];
	unsigned short addr;
	struct LableNode* next;
};

char* MyGetLine()
{
	char* buff = (char*)calloc(100, sizeof(char));
	char temp;
	int cnt = 0;
	int flag = 0;
	while (1) {
		temp = getchar();
		if (temp == EOF) {
			if (flag) return buff;
			else return NULL;
		}if (temp == '\n') {
			flag = 1;
			return buff;
			
		}
		else {
			flag = 1;
			buff[cnt] = temp;
			cnt++;
		}
	}
}

struct CodeNode* ReadCode()
{
	struct CodeNode* head = NULL;
	struct CodeNode* tail = NULL;
	char* buff = NULL;
	while (buff = MyGetLine()) {
		if (head == NULL) {
			head = (struct CodeNode*)malloc(sizeof(struct CodeNode));
			head->code = buff;
			head->next = NULL;
			tail = head;
		}
		else {
			tail->next = (struct CodeNode*)malloc(sizeof(struct CodeNode));
			tail = tail->next;
			tail->code = buff;
			tail->next = NULL;
		}
	}
	return head;
}

char* MyGetWord(char* string)
{
	char* buff = (char*)calloc(100, sizeof(char));
	char temp;
	int cnt = 0;
	int flag = 0;
	while (1) {
		temp = getchar();
		if (temp == '\0') {
			return buff;
		}
		else if (temp=='\t'||temp==' ') {
			if (flag) return buff;
			else continue;
		}
		else {
			flag = 1;
			buff[cnt] = temp;
			cnt++;
		}
	}
}

bool IsLable(char* word)
{
	//不检查Label是否包含非法字符和是否以数字开头，只对比保留字
	//也不考虑保留字其他大小写的情况
	static const char* ReservedWord[33] = {
		".ORIG", ".FILL", ".BLKW", ".STRINGZ", ".END",
		"BR", "BRn", "BRz", "BRp", "BRnz", "BRnp", "BRzp", "BRnzp",
		"ADD", "AND", "NOT", "LD", "LDI", "LDR", "LEA", "ST", "STI", "STR", "TRAP", "JMP", "JSR", "RTI",
		"GETC", "OUT", "PUTS", "IN", "PUTSP", "HALT"
	};
	for (int i = 0; i < 33; i++) {
		if (strcmp(word, ReservedWord[i]) == 0) {
			return false;
		}
	}
	return true;
}

void testout(struct CodeNode* CodeHead)
{
	while (CodeHead) {
		printf("***%s***\n", CodeHead->code);
		CodeHead = CodeHead->next;
	}
}

int main()
{
	struct CodeNode* CodeHead = ReadCode();
	struct LabelNode* LabelHead = ReadLabel(CodeHead);
	//output(CodeHead, LabelHead);
	//testout(CodeHead);

	return 0;
}