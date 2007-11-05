struct Patch {
        unsigned int offset;
        unsigned int old;
        unsigned int new;
};

void patch(char* MS_FILE, long MS_SIZE, struct Patch *patches, char enforce);

