#include <unistd.h>

struct Patch {
        unsigned int offset;
        uint32_t old;
        uint32_t new;
};

struct PatchByte {
        unsigned int offset;
        uint8_t old;
        uint8_t new;
};


void patch(char* MS_FILE, long MS_SIZE, struct Patch *patches, char enforce);
void patchBytes(char* MS_FILE, long MS_SIZE, struct PatchByte *patches, char enforce);

