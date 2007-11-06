#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <stdarg.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "patch.h"

void patch(char* MS_FILE, long MS_SIZE, struct Patch *patches, char enforce) {
    uint32_t *DATA;
    FILE *fd;
    struct stat s;
    char *filename;
    int len;
    char *newName;
    struct Patch *patch;
    int offset;
    uint32_t old;

    filename = MS_FILE;
    
    len = strlen(filename);
    
    newName = malloc(len+5);
    strcpy(newName, filename);
    strcpy(newName+len,".new");
    
    if(stat(filename, &s)!=0) return;
    if(s.st_size != MS_SIZE) return;
       
    fd = fopen(filename, "rb");
    if(fd == NULL) return;
    DATA = malloc(MS_SIZE+1);
    if(DATA == NULL) return;
    fread(DATA, MS_SIZE, 1, fd);
    fclose(fd);

    patch = patches;
    while (patch->offset) {
            offset = patch->offset / 4;
            old = DATA[offset];
            if (enforce == 1 && old != patch->old) {
                    return;
            }
            DATA[offset] = patch->new;
            patch++;
    }

    fd = fopen(newName, "wb");
    if(fd == NULL) return;
    if(fwrite(DATA, MS_SIZE, 1, fd) != 1) return;
    fclose(fd);

    sync();
    
    unlink(filename);
    link(newName,filename);
    unlink(newName);

    sync();

    free(newName);
    free(DATA);
}

void patchBytes(char* MS_FILE, long MS_SIZE, struct PatchByte *patches, char enforce) {
    unsigned char *DATA;
    FILE *fd;
    struct stat s;
    char *filename;
    int len;
    char *newName;
    struct PatchByte *patch;
    int offset;
    unsigned char old;

    filename = MS_FILE;
    
    len = strlen(filename);
    
    newName = malloc(len+5);
    strcpy(newName, filename);
    strcpy(newName+len,".new");
    
    if(stat(filename, &s)!=0) return;
    if(s.st_size != MS_SIZE) return;
       
    fd = fopen(filename, "rb");
    if(fd == NULL) return;
    DATA = malloc(MS_SIZE+1);
    if(DATA == NULL) return;
    fread(DATA, MS_SIZE, 1, fd);
    fclose(fd);

    patch = patches;
    while (patch->offset) {
            offset = patch->offset;
            old = DATA[offset];
            if (enforce == 1 && old != patch->old) {
                    return;
            }
            DATA[offset] = patch->new;
            patch++;
    }

    fd = fopen(newName, "wb");
    if(fd == NULL) return;
    if(fwrite(DATA, MS_SIZE, 1, fd) != 1) return;
    fclose(fd);

    sync();
    
    unlink(filename);
    link(newName,filename);
    unlink(newName);

    sync();

    free(newName);
    free(DATA);
}

