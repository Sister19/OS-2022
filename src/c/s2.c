#include "header/std_datatype.h"
#include "header/string.h"

int main() {
    while (true) {
        interrupt(0x21, 0x8, "sadsad", 0, 0);
        puts("p2 ");
        interrupt(0x21, 0x7, 5, 0, 0);
    }
    while (true);
}
