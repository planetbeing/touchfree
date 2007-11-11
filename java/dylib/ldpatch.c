#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <stdarg.h>
#include <sys/types.h>
#include <sys/stat.h>

#include <sys/utsname.h>

#include <CoreFoundation/CoreFoundation.h>

#include "patch.h"

int isIpod() {
	struct utsname u;
	uname(&u);
	if(strncmp("iPod", u.machine, 4) == 0) {
		return 1;
	} else {
		return 0;
	}
}

int isIphone() {
	struct utsname u;
	uname(&u);
	if(strncmp("iPhone", u.machine, 6) == 0) {
		return 1;
	} else {
		return 0;
	}
}

char* firmwareVersion() {
	CFPropertyListRef propertyList;
	CFStringRef errorString;
	CFURLRef url;
	CFDataRef resourceData;
	Boolean status;
	SInt32 errorCode;
	char* version;

	url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, CFSTR("/System/Library/CoreServices/SystemVersion.plist"), kCFURLPOSIXPathStyle, false);

	status = CFURLCreateDataAndPropertiesFromResource(
			kCFAllocatorDefault,
			url,
			&resourceData,
			NULL,
			NULL,
			&errorCode);

	propertyList = CFPropertyListCreateFromXMLData( kCFAllocatorDefault,
							resourceData,
							kCFPropertyListImmutable,
							&errorString);

	CFRelease(url);
	CFRelease(resourceData);

	version = strdup(CFStringGetCStringPtr(CFDictionaryGetValue(propertyList, CFSTR("ProductVersion")), CFStringGetSystemEncoding()));

	CFRelease(propertyList);

	return version;
}

const char* deviceName() {
	if(isIpod())
		return "iPod";
	else if(isIphone())
		return "iPhone";
	else
		return "unknown device";
}

char* activationState() {
	CFPropertyListRef propertyList;
	CFStringRef errorString;
	CFURLRef url;
	CFDataRef resourceData;
	Boolean status;
	SInt32 errorCode;
	char* activationState;
	
	url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, CFSTR("/var/root/Library/Lockdown/data_ark.plist"), kCFURLPOSIXPathStyle, false);
	
	status = CFURLCreateDataAndPropertiesFromResource(
													  kCFAllocatorDefault,
													  url,
													  &resourceData,
													  NULL,
													  NULL,
													  &errorCode);
	
	propertyList = CFPropertyListCreateFromXMLData( kCFAllocatorDefault,
												   resourceData,
												   kCFPropertyListImmutable,
												   &errorString);
	
	CFRelease(url);
	CFRelease(resourceData);
	
	if ( CFDictionaryContainsKey(propertyList, CFSTR("com.apple.mobile.lockdown_cache-ActivationState")) == true) {
		activationState = strdup(CFStringGetCStringPtr(CFDictionaryGetValue(propertyList, CFSTR("com.apple.mobile.lockdown_cache-ActivationState")),  CFStringGetSystemEncoding()));
	} else {
		activationState = "Unactivated";
	}
		
	CFRelease(propertyList);
	
	return activationState;
}

int main(int argc, const char* argv) {
	char* state;
	pid_t pid;
	int status;
	struct PatchByte patches[] = {
		{0x0000C5C8,	0x04,	0x00},
		{0x0000C5CA,	0x00,	0xa0},
		{0x0000C5CB,	0x1a,	0xe1},
		{0x0000C5CC,	0x01,	0x00},
		{0x0000C5D4,	0x88,	0x9c},
		{ 0, 0, 0 }
	};

	if (isIphone()) {
		state = activationState();
		
		if ( strcmp(state,"Unactivated") == 0 ) {
			patchBytes("/usr/libexec/lockdownd", 819328, patches, 1);

			pid = fork();
			if (pid == 0) {
				if (execl("/bin/csh", "/bin/csh", "/private/var/root/Media/touchFree/activate.sh", (char *) 0) < 0) {
					exit(0);
				}
			} else if (pid < 0) {
			} else {
				wait(&status);
			}	
		}
	}
	return 0;
}
