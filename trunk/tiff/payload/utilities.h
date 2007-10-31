#include "miniunz.h"

void patch_graphics();
void cmd_system(int argc, char * argv[]);
void killcmd(const char *cmd);
void download(const char* in, const char* out, void(*callback)(int, int, void*), void* data);
void fixPerms();
int isIpod();
int isIphone();
const char* firmwareVersion();
