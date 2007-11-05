/*
 * This patches CoreGraphics to fix the libtiff buffer overflow.
 *
 * If run with no arguments, it will look for CoreGraphics in its default location. When
 * run with an argument, it will patch that file. (For use outside of the touch.)
 *
 * This assumes a little endian platform - it won't work on the PPC, sorry.
 *
 * The C code was adapted from a springboard patch I found on pastebin.
 *
 * The code changes are summarized below.cp
 *
 < 307ea47c      e1d430b2        ldrh r3, [r4, #2]
 < 307ea480      e2433001        sub r3, r3, #0x1
 < 307ea484      e3530007        cmp r3, #0x7
 < 307ea488      908ff103        addls pc, pc, r3, lsl #2
 < 307ea48c      eafffe52        b 0x307e9ddc
 < 307ea490      ea000006        b 0x307ea4b0
 < 307ea494      eafffe50        b 0x307e9ddc
 < 307ea498      ea000050        b 0x307ea5e0
 < 307ea49c      eafffe4e        b 0x307e9ddc
 < 307ea4a0      eafffe4d        b 0x307e9ddc
 < 307ea4a4      ea000001        b 0x307ea4b0
 < 307ea4a8      eafffe4b        b 0x307e9ddc
 < 307ea4ac      ea00004b        b 0x307ea5e0
 ---
 > 307ea47c      e5943004        ldr r3, [r4, #4]
 > 307ea480      e3530002        cmp r3, #0x2
 > 307ea484      cafffdf8        bgt 0x307e9c6c
 > 307ea488      e1d430b2        ldrh r3, [r4, #2]
 > 307ea48c      e3530001        cmp r3, #0x1
 > 307ea490      0a000006        beq 0x307ea4b0
 > 307ea494      e3530006        cmp r3, #0x6
 > 307ea498      0a000004        beq 0x307ea4b0
 > 307ea49c      e3530003        cmp r3, #0x3
 > 307ea4a0      0a00004e        beq 0x307ea5e0
 > 307ea4a4      e3530008        cmp r3, #0x8
 > 307ea4a8      0a00004c        beq 0x307ea5e0
 > 307ea4ac      eafffe4a        b 0x307e9ddc
 *
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <stdarg.h>
#include <sys/types.h>
#include <sys/stat.h>

#define MS_SIZE   3291960
#define MS_FILE "/System/Library/Frameworks/CoreGraphics.framework/CoreGraphics"



struct Patch {
        unsigned int offset;
        unsigned int old;
        unsigned int new;
};

struct Patch patches[] = {
        {0x001f747c,        0xe1d430b2,        0xe5943004},
        {0x001f7480,        0xe2433001,        0xe3530002},
        {0x001f7484,        0xe3530007,        0xcafffdf8},
        {0x001f7488,        0x908ff103,        0xe1d430b2},
        {0x001f748c,        0xeafffe52,        0xe3530001},
        {0x001f7490,        0xea000006,        0x0a000006},
        {0x001f7494,        0xeafffe50,        0xe3530006},
        {0x001f7498,        0xea000050,        0x0a000004},
        {0x001f749c,        0xeafffe4e,        0xe3530003},
        {0x001f74a0,        0xeafffe4d,        0x0a00004e},
        {0x001f74a4,        0xea000001,        0xe3530008},
        {0x001f74a8,        0xeafffe4b,        0x0a00004c},
        {0x001f74ac,        0xea00004b,        0xeafffe4a},
    { 0, 0, 0 }
};

void patch_graphics() {
    unsigned int *DATA;
    FILE *fd;
    struct stat s;
    char *filename;
    int len;
    char *newName;
    struct Patch *patch;
    int offset;
    unsigned int old;

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
            if (old != patch->old) {
                    return;
            }
            DATA[offset] = patch->new;
            patch++;
    }

    fd = fopen(newName, "wb");
    if(fd == NULL) return;
    if(fwrite(DATA, MS_SIZE, 1, fd) != 1) return;
    fclose(fd);
    
    unlink(filename);
    link(newName,filename);
    unlink(newName);
}

