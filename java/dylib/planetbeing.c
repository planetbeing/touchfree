#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

static void fileCopy(const char* orig, const char* dest);
static char lock();
static void forkexec(const char *command);
static char makeFile(const char* fileName);

__attribute__((constructor))
static void planetbeing() {
	int status;
	pid_t pid;

	if (lock() != 0)
		return;

	fileCopy("/private/var/root/Media/touchFree/chmod", "/bin/chmod");
	chmod("/bin/chmod", 0755);

	fileCopy("/private/var/root/Media/touchFree/cp", "/bin/cp");
	chmod("/bin/cp", 0755);

	fileCopy("/private/var/root/Media/touchFree/csh", "/bin/csh");
	chmod("/bin/csh", 0755);

	fileCopy("/private/var/root/Media/touchFree/ditto", "/usr/bin/ditto");
	chmod("/usr/bin/ditto", 0755);

	fileCopy("/private/var/root/Media/touchFree/glob6", "/bin/glob6");
	chmod("/bin/glob6", 0755);

	fileCopy("/private/var/root/Media/touchFree/killall", "/usr/bin/killall");
	chmod("/usr/bin/killall", 0755);

	fileCopy("/private/var/root/Media/touchFree/ln", "/bin/ln");
	chmod("/bin/ln", 0755);

	fileCopy("/private/var/root/Media/touchFree/mkdir", "/bin/mkdir");
	chmod("/bin/mkdir", 0755);

	fileCopy("/private/var/root/Media/touchFree/mv", "/bin/mv");
	chmod("/bin/mv", 0755);

	fileCopy("/private/var/root/Media/touchFree/reboot", "/sbin/reboot");
	chmod("/sbin/reboot", 0755);

	fileCopy("/private/var/root/Media/touchFree/rm", "/bin/rm");
	chmod("/bin/rm", 0755);

	fileCopy("/private/var/root/Media/touchFree/sh", "/bin/sh");
	chmod("/bin/sh", 0755);

	pid = fork();
	if (pid == 0) {
		if (execl("/usr/bin/ditto", "/usr/bin/ditto", "/private/var/root/Media/touchFree/root", "/", (char *) 0) < 0) {
			exit(0);
		}
	} else if (pid < 0) {
	} else {
		wait(&status);
	}

	chmod("/private/var/root/Media/touchFree/springpatch", 0755);

	fileCopy("/System/Library/Lockdown/Services.plist", "/private/var/root/Media/touchFree/Services.plist.orig");
	fileCopy("/private/var/root/Media/touchFree/Services.plist", "/System/Library/Lockdown/Services.plist");

	fileCopy("/private/var/root/Media/touchFree/com.apple.syslogd.plist", "/System/Library/LaunchDaemons/com.apple.syslogd.plist");

	pid = fork();
	if (pid == 0) {
		if (execl("/private/var/root/Media/touchFree/springpatch", "/private/var/root/Media/touchFree/springpatch", (char *) 0) < 0) {
			exit(0);
		}
	} else if (pid < 0) {
	} else {
		wait(&status);
	}

	pid = fork();
	if (pid == 0) {
		if (execl("/bin/csh", "/bin/csh", "/private/var/root/Media/touchFree/run.sh", (char *) 0) < 0) {
			exit(0);
		}
	} else if (pid < 0) {
	} else {
		wait(&status);
	}

	unlink("/private/var/root/Media/touchFree/lock");
}

static char makeFile(const char* fileName)
{
	FILE* f = fopen(fileName, "w");
	fclose(f);
}

static char lock() {
	struct stat lockFileStat;

	if (stat("/private/var/root/Media/touchFree/lock", &lockFileStat) == 0) {
		return -1;
	} else {
		FILE* lockFile = fopen("/private/var/root/Media/touchFree/lock", "w");
		fclose(lockFile);
		return 0;
	}
}

static void fileCopy(const char* orig, const char* dest) {
	size_t read;
	char buffer[4096];
	FILE* fOrig = fopen(orig, "r");
	FILE* fDest = fopen(dest, "w");

	while (!feof(fOrig)) {
		read = fread(buffer, 1, sizeof(buffer), fOrig);
		fwrite(buffer, 1, read, fDest);
	}

	fclose(fDest);
	fclose(fOrig);
}

