    #define _CRT_SECURE_NO_WARNINGS
#include<stdio.h>
#include<stdlib.h>

//memory
short MEM[0xFFFF];

//initialize all memory as 0x7777
void IniMem();

//load instructions into MEM
//return the first addr
unsigned short Load();

//read a 16bits string in buffer
//return address of string after read 16 chars
//or return NULL while reading EOF
char* MyGetLine();

//turn a 16bits string into an unsigned short
unsigned short StrToNum(char* str);

//pick up imm in an instruction string, “len” is the length of imm
short SEXT(unsigned int instruction, int len);

//return a regester number in a particular place in an instruction
short TellReg(unsigned int instruction, int highbit);

int main()
{   
    IniMem();
    short REG[8];
    for (int i = 0; i < 8; i++) REG[i] = 0x7777;// initialize

    unsigned short temp1, temp2, temp3;
    unsigned short OpCode = 0;
    unsigned short CurrentIS = 0;
    unsigned short CC = 0b010;
    unsigned short PC = Load();

    while (1) {
        CurrentIS = MEM[PC];
        PC++;
        OpCode = CurrentIS >> 12;//decoder
        switch (OpCode) {
            case 0b0000://BR
                temp2 = TellReg(CurrentIS, 11);
                if (temp2 & CC) {
                    temp1 = SEXT(CurrentIS, 9);
                    PC += temp1;
                }
                break;
            case 0b0001://ADD
                if (CurrentIS & 0b100000) {
                    temp1 = SEXT(CurrentIS, 5);
                    temp2 = TellReg(CurrentIS, 11);
                    temp3 = TellReg(CurrentIS, 8);
                    REG[temp2] = REG[temp3] + temp1;
                }
                else {
                    temp1 = TellReg(CurrentIS, 2);
                    temp2 = TellReg(CurrentIS, 11);
                    temp3 = TellReg(CurrentIS, 8);
                    REG[temp2] = REG[temp3] + REG[temp1];
                }

                if (REG[temp2] > 0) CC = 0b001;
                else if (REG[temp2] == 0) CC = 0b010;
                else CC = 0b100;
                break;
            case 0b0010://LD
                temp1 = SEXT(CurrentIS, 9);
                temp2 = TellReg(CurrentIS, 11);
                temp3 = PC + temp1;
                REG[temp2] = MEM[temp3];

                if (REG[temp2] > 0) CC = 0b001;
                else if (REG[temp2] == 0) CC = 0b010;
                else CC = 0b100;
                break;
            case 0b0011://ST
                temp1 = SEXT(CurrentIS, 9);
                temp2 = TellReg(CurrentIS, 11);
                temp3 = PC + temp1;
                MEM[temp3] = REG[temp2];
                break;
            case 0b0100://JSR JSRR
                REG[7] = PC;
                if (CurrentIS & 0b100000000000) {//JSR
                    temp1 = SEXT(CurrentIS, 11);
                    PC += temp1;
                }
                else {//JSRR
                    temp2 = TellReg(CurrentIS, 8);
                    PC = REG[temp2];
                }
                break;
            case 0b0101://AND
                if (CurrentIS & 0b100000) {
                    temp1 = SEXT(CurrentIS, 5);
                    temp2 = TellReg(CurrentIS, 11);
                    temp3 = TellReg(CurrentIS, 8);
                    REG[temp2] = REG[temp3] & temp1;
                }
                else {
                    temp1 = TellReg(CurrentIS, 2);
                    temp2 = TellReg(CurrentIS, 11);
                    temp3 = TellReg(CurrentIS, 8);
                    REG[temp2] = REG[temp3] & REG[temp1];
                }

                if (REG[temp2] > 0) CC = 0b001;
                else if (REG[temp2] == 0) CC = 0b010;
                else CC = 0b100;
                break;
            case 0b0110://LDR
                temp1 = SEXT(CurrentIS, 6);
                temp2 = TellReg(CurrentIS, 11);
                temp3 = TellReg(CurrentIS, 8);
                temp3 = REG[temp3];
                REG[temp2] = MEM[temp3 + temp1];

                if (REG[temp2] > 0) CC = 0b001;
                else if (REG[temp2] == 0) CC = 0b010;
                else CC = 0b100;
                break;
            case 0b0111://STR
                temp1 = SEXT(CurrentIS, 6);
                temp2 = TellReg(CurrentIS, 11);
                temp3 = TellReg(CurrentIS, 8);
                temp3 = REG[temp3];
                MEM[temp3 + temp1] = REG[temp2];
                break;
            case 0b1000://RTI, NOT REQUIRED
                break;
            case 0b1001://NOT
                temp1 = TellReg(CurrentIS, 8);
                temp2 = TellReg(CurrentIS, 11);
                REG[temp2] = ~REG[temp1];

                if (REG[temp2] > 0) CC = 0b001;
                else if (REG[temp2] == 0) CC = 0b010;
                else CC = 0b100;
                break;
            case 0b1010://LDI
                temp2 = TellReg(CurrentIS, 11);
                temp1 = PC + SEXT(CurrentIS, 9);
                temp1 = MEM[temp1];
                REG[temp2] = MEM[temp1];
                
                if (REG[temp2] > 0) CC = 0b001;
                else if (REG[temp2] == 0) CC = 0b010;
                else CC = 0b100;
                break;
            case 0b1011://STI
                temp2 = TellReg(CurrentIS, 11);
                temp1 = PC + SEXT(CurrentIS, 9);
                temp1 = MEM[temp1];
                MEM[temp1] = REG[temp2];
                break;
            case 0b1100://JMP
                temp2 = TellReg(CurrentIS, 8);
                PC = REG[temp2];
                break;
            case 0b1101://SPARE
                break;
            case 0b1110://LEA
                temp1 = SEXT(CurrentIS, 9);
                temp2 = TellReg(CurrentIS, 11);
                REG[temp2] = temp1 + PC;
                break;
            case 0b1111://TRAP, NOT REQUIRED
                for (int i = 0; i < 8; i++) {
                    printf("R%d = x%04hX\n", i, REG[i]);
                }
                return 0;
        }
    }
}

//initialize memory as 0x7777
void IniMem()
{
    for (int i = 0; i < 0xFFFF; i++) {
        MEM[i] = 0x7777;
    }
}

//load instructions into MEM
//return the first addr
unsigned short Load()
{
    char temp;
    char* IS;
    unsigned short NowAddr = 0;
    unsigned short Head = 0;
    
    IS = MyGetLine();
    Head = StrToNum(IS);
    NowAddr = Head;
    while ((IS = MyGetLine()) != NULL) {
        MEM[NowAddr] = StrToNum(IS);
        NowAddr++;
    }
    return Head;
}

//read a 16bits string in buffer
//return address of string after read 16 chars
//or return NULL while reading EOF
char* MyGetLine()
{
    int count = 0;
    char temp;
    char* IS;
    IS = (char*)calloc(16, sizeof(char));
    while (1) {
        temp = getchar();
        if (temp == EOF) {
            return NULL;
        }
        if (temp != '\n') {
            IS[count] = temp;
            count++;
        }
        if (count >= 16) {
            return IS;
        }
    }
}

//turn a 16bits string into an unsigned short
unsigned short StrToNum(char* str)
{
    unsigned short factor = 1;
    unsigned short result = 0;
    for (int i = 15; i >= 0; i--) {
        result += (str[i] - 0x30) * factor;
        factor *= 2;
    }
    return result;
}

//pick up imm in an instruction, len is the length of imm you want
short SEXT(unsigned int instruction, int len)
{
    short result = 0;
    switch (len) {
    case 5:
        result = instruction << 11;
        result = result >> 11;
        if (result & 0b10000) {
            result = result | 0b1111111111100000;
        }
        break;
    case 6:
        result = instruction << 10;
        result = result >> 10;
        if (result & 0b100000) {
            result = result | 0b1111111111000000;
        }
        break;
    case 9:
        result = instruction << 7;
        result = result >> 7;
        if (result & 0b100000000) {
            result = result | 0b1111111000000000;
        }
        break;
    case 11:
        result = instruction << 5;
        result = result >> 5;
        if (result & 0b10000000000) {
            result = result | 0b1111100000000000;
        }
    }
    return result;
}

//return a regester number in a particular place in an instruction
short TellReg(unsigned int instruction, int highbit)
{
    unsigned short result = 0;
    switch (highbit) {
    case 11:
        result = instruction << 4;
        result = result >> 13;
        break;
    case 8:
        result = instruction << 7;
        result = result >> 13;
        break;
    case 2:
        result = instruction << 13;
        result = result >> 13;
        break;
    }
    return result;
}