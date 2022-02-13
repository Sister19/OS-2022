#include "std_datatype.h"

// Implementasikan
void memcpy(byte *dest, byte *src, unsigned int n);
// Mengcopy n bytes yang ditunjuk src ke dest

unsigned int strlen(char *string);
// Mengembalikan panjang suatu null terminated string

bool strcmp(char *s1, char *s2);
// Mengembalikan true jika string sama

void strcpy(char *dst, char *src);
// Melakukan penyalinan null terminated string

void clear(byte *ptr, unsigned int n);
// Mengosongkan byte array yang memiliki panjang n
