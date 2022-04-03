// Kernel header

#include "std_datatype.h"
#include "std_lib.h"

struct message {
    byte current_directory;
    char arg1[64];
    char arg2[64];
    char arg3[64];
    byte other[319];
};

extern void putInMemory(int segment, int address, byte b);
extern int interrupt(int int_number, int AX, int BX, int CX, int DX);
extern void makeInterrupt21();
extern void launchProgram(int segment);
extern void setPIT();
extern void usleep(int d);
extern void useKernelDataMemory();
extern void setDataSegment(int segment);
extern int getCurrentDataSegment();

void fillKernelMap();
void handleInterrupt21(int AX, int BX, int CX, int DX);
void printString(char *string);
void readString(char *string);
void clearScreen();
void sleep(int second);
void contextSwitch();

void writeSector(byte *buffer, int sector_number);
void readSector(byte *buffer, int sector_number);

void write(struct file_metadata *metadata, enum fs_retcode *return_code);
void read(struct file_metadata *metadata, enum fs_retcode *return_code);

void executeProgram(struct file_metadata *metadata, int segment);

void shell();
