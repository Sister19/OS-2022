#include "header/filesystem.h"
#include "header/std_datatype.h"
#include "header/string.h"

void exit_program();

int main() {
    /*
        TODO : Implementasi cp
    */
    exit_program();
}

void exit_program() {
    struct file_metadata meta;
    meta.node_name    = "shell";
    meta.parent_index = 0x00;

    interrupt(0x21, 6, &meta, 0x2000, 0, 0);
}
