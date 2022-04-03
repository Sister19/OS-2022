#include "header/std_datatype.h"
#include "header/string.h"

int main() {
    while (true) {
        puts("p3 ");
        interrupt(0x21, 0x7, 5, 0, 0);
    }
    while (true);
}
