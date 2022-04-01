#include "header/string.h"

void puts(char *str) {
    interrupt(0x21, 0, str, 0, 0);
}
