// Asisten Sister 19
// ! BUKAN KIT !
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef unsigned char byte;
typedef char bool;
#define true 1
#define false 0

struct file_metadata {
    FILE *file_ptr;        // Modified dibandingkan tugas
    char *node_name;
    byte parent_index;
    unsigned int filesize;
};

struct sector_entry {
    byte sector_numbers[16];
};

struct node_entry {
    byte parent_node_index;
    byte sector_entry_index;
    char name[14];
};

enum fs_retcode {
    FS_UNKNOWN_ERROR    = -1,
    FS_SUCCESS          = 0,
    FS_R_NODE_NOT_FOUND = 1,
    FS_R_TYPE_IS_FOLDER = 2,

    FS_W_FILE_ALREADY_EXIST   = 3,
    FS_W_NOT_ENOUGH_STORAGE   = 4,
    FS_W_MAXIMUM_NODE_ENTRY   = 5,
    FS_W_MAXIMUM_SECTOR_ENTRY = 6,
    FS_W_INVALID_FOLDER       = 7
};


// Fungsi penulisan, fungsi ini ekuivalen dengan tugas syscall write
void writer(byte buf[2880][512], struct file_metadata *metadata) {
    bool node_write_index_found, sector_write_index_found;
    bool writing_file, enough_empty_space;
    bool unique_filename, invalid_parent_index;
    unsigned int node_write_index, sector_write_index;
    unsigned int empty_space_size;
    int i;

    // Tahap 1 : Pengecekan pada filesystem node
    // Note, intentional out of bound indexing
    unique_filename        = true;
    node_write_index_found = false;
    for (i = 0; i < 64 && unique_filename; i++) {
        struct node_entry node_buffer;
        memcpy(&node_buffer, &(buf[0x101][i*16]), 16);

        // Cari dan simpan index yang berisikan node kosong pada filesystem node
        if (node_buffer.sector_entry_index == 0x00
              && node_buffer.parent_node_index == 0x00
              && !node_write_index_found) {
            node_write_index  = i;
            node_write_index_found = true;
        }

        // Validasi nama node
        if (node_buffer.parent_node_index == metadata->parent_index && !strcmp(node_buffer.name, metadata->node_name))
            unique_filename = false;
    }

    // Tahap 2 : Pengecekan parent index
    invalid_parent_index = false;
    if (metadata->parent_index != 0xFF) {
        if (buf[0x101][(metadata->parent_index)*16 + 1] != 0xFF)
            invalid_parent_index = true;
    }

    // Tahap 3 : Pengecekan tipe penulisan
    if (metadata->filesize != 0)
        writing_file = true;
    else
        writing_file = false;

    // Tahap 4 : Pengecekan ukuran untuk file
    if (writing_file) {
        enough_empty_space = false;
        empty_space_size   = 0;

        // Catatan : Meskipun map dapat digunakan sebagai penanda 512 sektor,
        //       hanya 0-255 dapat diakses dengan 1 byte sector_number pada sector
        for (i = 0; i < 256 && !enough_empty_space; i++) {
            if (buf[0x100][i] == 0)
                empty_space_size += 512;

            if (metadata->filesize <= empty_space_size)
                enough_empty_space = true;
        }
    }
    else
        enough_empty_space = true; // Jika folder abaikan tahap ini

    // Tahap 5 : Pengecekan filesystem sector
    if (writing_file) {
        sector_write_index_found = false;

        for (i = 0; i < 64 && !sector_write_index_found; i++) {
            struct sector_entry sector_entry_buffer;
            bool is_sector_entry_empty;
            int j;

            memcpy(&sector_entry_buffer, &(buf[0x103][16*i]), 16);

            is_sector_entry_empty = true;
            for (j = 0; j < 16; j++) {
                if (sector_entry_buffer.sector_numbers[j] != 0x00)
                    is_sector_entry_empty = false;
            }

            if (is_sector_entry_empty) {
                sector_write_index       = i;
                sector_write_index_found = true;
            }
        }
    }
    else
        sector_write_index_found = true;

    // Tahap 6 : Penulisan
    if (node_write_index_found
          && sector_write_index_found
          && unique_filename
          && !invalid_parent_index
          && enough_empty_space) {

        // Penulisan byte P dan nama node
        buf[0x101][16*node_write_index] = metadata->parent_index;
        memcpy(&(buf[0x101][16*node_write_index + 2]), metadata->node_name, strlen(metadata->node_name));

        // Menuliskan folder / file
        if (!writing_file) {
            buf[0x101][16*node_write_index + 1] = 0xFF;
            printf("Writer : Folder %s created\n", metadata->node_name);
        }
        else {
            bool writing_completed = false;
            unsigned int written_filesize = 0;
            int j = 0;
            buf[0x101][16*node_write_index + 1] = sector_write_index;

            for (i = 0; i < 512 && !writing_completed; i++) {
                if (buf[0x100][i] == 0) {
                    buf[0x100][i] = 1;
                    written_filesize += 512;

                    buf[0x103][16*sector_write_index + j] = i;

                    // Penulisan isi file
                    byte data_buffer[512];
                    for (int k = 0; k < 512; k++)
                        data_buffer[k] = 0;
                    fread(data_buffer, 512, 1, metadata->file_ptr);
                    memcpy(buf[i], data_buffer, 512);
                    j++;
                }

                if (written_filesize >= metadata->filesize)
                    writing_completed = true;
            }

            printf("Writer : Writing %s completed (%d bytes)\n", metadata->node_name, metadata->filesize);
        }

        // Update filesystem tidak diperlukan
    }

    // Tahap 7 : Return code error
    if (!unique_filename)
        fprintf(stderr, "Error : Name already exist\n");
    else if (!node_write_index_found)
        fprintf(stderr, "Error : Maximum node entry reached\n");
    else if (writing_file && !sector_write_index_found)
        fprintf(stderr, "Error : Maximum sector entry reached\n");
    else if (invalid_parent_index)
        fprintf(stderr, "Error : Invalid parent index\n");
    else if (!enough_empty_space)
        fprintf(stderr, "Error : Not enough space\n");
}



// Fungsi wrapper
void insert_file(byte buf[2880][512], char *fname, byte parent_idx) {
    struct file_metadata metadata;

    metadata.parent_index = parent_idx;

    FILE *ptr = fopen(fname, "rb");
    if (ptr == NULL) {
        fprintf(stderr, "Error : \"%s\" not found\n", fname);
        return;
    }

    // Relative path, filename resolve
    int slash_idx = -1;
    int i = 0;
    while (fname[i] != '\0') {
        if (fname[i] == '/' || fname[i] == '\\')
            slash_idx = i;
        i++;
    }

    char filename[128];
    if (slash_idx != -1)
        strcpy(filename, fname + slash_idx + 1);
    else
        strcpy(filename, fname);

    metadata.node_name = filename;

    metadata.file_ptr = ptr;
    byte temp[8190];
    fread(temp, 8192, 1, ptr);
    metadata.filesize = ftell(ptr);
    fclose(ptr);

    ptr = fopen(fname, "rb");
    writer(buf, &metadata);
}

void create_folder(byte buf[2880][512], char *fname, byte parent_idx) {
    struct file_metadata metadata;
    metadata.node_name    = fname;
    metadata.parent_index = parent_idx;
    metadata.filesize     = 0;
    writer(buf, &metadata);
}
