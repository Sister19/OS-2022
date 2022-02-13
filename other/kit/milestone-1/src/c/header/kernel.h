// Kernel header

#include "std_datatype.h"
#include "std_lib.h"

// Fungsi bawaan
extern void putInMemory(int segment, int address, byte b);
extern int interrupt (int int_number, int AX, int BX, int CX, int DX);
extern void makeInterrupt21();

void handleInterrupt21(int AX, int BX, int CX, int DX);


// TODO : Implementasikan
void printString(char *string);
void readString(char *string);
void clearScreen();
