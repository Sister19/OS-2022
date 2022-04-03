#include "header/std_datatype.h"
#include "header/string.h"

int main() {
    // interrupt(0x21, 0x8, "abc", 0, 0);
    interrupt(0x21, 0x8, "abc", 0, 0);
    while (true) {
        puts("periodic ");
        interrupt(0x21, 0x7, 5, 0, 0);
    }


    puts("Halo shell!");
    while (true);
}
