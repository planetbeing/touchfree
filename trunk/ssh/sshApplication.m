#include <sys/stat.h>
#include <unistd.h>
#include <sys/wait.h>
#include <errno.h>
#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIPreferencesTable.h>
#import <GraphicsServices/GraphicsServices.h>

#import "ssh.h"

typedef enum {
	kUIControlEventMouseDown = 1 << 0,
	kUIControlEventMouseMovedInside = 1 << 2, // mouse moved inside control target
	kUIControlEventMouseMovedOutside = 1 << 3, // mouse moved outside control target
	kUIControlEventMouseUpInside = 1 << 6, // mouse up inside control target
	kUIControlEventMouseUpOutside = 1 << 7, // mouse up outside control target
	kUIControlAllEvents = (kUIControlEventMouseDown | kUIControlEventMouseMovedInside | kUIControlEventMouseMovedOutside | kUIControlEventMouseUpInside | kUIControlEventMouseUpOutside)
} UIControlEventMasks;

char fileExists(const char* fileName) {
	struct stat fileStat;

	if (stat(fileName, &fileStat) == 0) {
		return 1;
	} else {
		return 0;
	}
}

void changePassword(NSString* passwordString) {
	FILE* passwordFile;
	FILE* newPasswordFile;
	char *token;
	char line[256];
	const char *password = [passwordString UTF8String];

	passwordFile = fopen("/private/etc/master.passwd", "r");
	newPasswordFile = fopen("/private/etc/master.passwd.new", "w");
	while(fgets(line, 255, passwordFile) != NULL) {
		if(line[0] != '#') {
			token = strstr(line, ":");
			*token = '\0';
			fputs(line, newPasswordFile);
			fputs(":", newPasswordFile);
			++token;
			if(*token == '*' && *(token + 1) == ':') {
				fputs(token, newPasswordFile);
			} else {
				fputs(crypt(password, "/s"), newPasswordFile);
				fputs(":", newPasswordFile);
				token = strstr(token, ":");
				fputs(token + 1, newPasswordFile);
			}
		} else {
			fputs(line, newPasswordFile);
		}
	}

	fclose(passwordFile);
	fclose(newPasswordFile);

	chmod("/private/etc/master.passwd.new", 0600);
	unlink("/private/etc/master.passwd");
	link("/private/etc/master.passwd.new", "/private/etc/master.passwd");
	unlink("/private/etc/master.passwd.new");
}

@implementation sshApplication
 
	- (void) applicationDidFinishLaunching:(NSNotification *)aNotification {
		window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];
		groupcell = malloc(sizeof(UIPreferencesTableCell*) * 4);

		UIPreferencesTable *pref = [[UIPreferencesTable alloc] initWithFrame: CGRectMake(0.0f, 48.0f, 320.0f, 480.0f-48.0f)];
		[pref setDataSource: self];
		[pref setDelegate: self];

		preferencesHeader = [[UIPreferencesTableCell alloc] init];
		[preferencesHeader setTitle:@"SSH Preferences"];
		[preferencesHeader _setDrawAsGroupTitle: YES];
		[preferencesHeader setDrawsBackground: NO];

		struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
		rect.origin.x = rect.origin.y = 0.0f;

		CGRect switchRect = CGRectMake(rect.size.width - 114.0f, 9.0f, 296.0f - 200.0f, 32.0f);
 
		sshControl = [[UIPreferencesTableCell alloc] init];
		[sshControl setTitle: @"OpenSSH"];
		sshControl_switch = [[UISwitchControl alloc] initWithFrame: switchRect];
		[sshControl_switch setValue: [self isSshEnabled]];
		[sshControl addSubview: sshControl_switch];
		[sshControl_switch addTarget:self action:@selector(buttonPressed) forEvents:kUIControlEventMouseUpInside];

		passwordHeader = [[UIPreferencesTableCell alloc] init];
		[passwordHeader setTitle:@"SSH Root Password"];
		[passwordHeader _setDrawAsGroupTitle: YES];
		[passwordHeader setDrawsBackground: NO];

		password = [[UIPreferencesTextTableCell alloc] init];
		[password setTitle: @"New Password"];
		[[password textField] setSecure: YES];

		passwordText = [[UIPreferencesTableCell alloc] init];
		[passwordText setValue: @"Changed after application closes"];

		[pref reloadData];

		[window orderFront: self];
		[window makeKey: self];
		[window _setHidden: NO];

		UINavigationBar *nav = [[UINavigationBar alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 48.0f)];
		[nav setBarStyle: 0];
		UINavigationItem *title = [[UINavigationItem alloc] initWithTitle:@"SSH Preferences"];
		[nav pushNavigationItem:title];
		[title release];

		mainView = [[UIView alloc] initWithFrame: rect];
		[mainView addSubview: nav];
		[nav release];
		[mainView addSubview: pref];
		[pref release];
		[window setContentView: mainView];

		[self setPassword];

	}

 	- (int) numberOfGroupsInPreferencesTable:(UIPreferencesTable *)aTable {
		return 4;

	}

 	- (int) preferencesTable:(UIPreferencesTable *)aTable numberOfRowsInGroup:(int)group {
		switch (group) {
			case 0:
				return 1;
			case 1:
				return 1;
			case 2:
				return 1;
			case 3:
				return 2;
		}
 	}
 
 
	- (UIPreferencesTableCell *)preferencesTable:(UIPreferencesTable *)aTable cellForGroup:(int)group {
		if (groupcell[group] == NULL) {
			groupcell[group] = [[UIPreferencesTableCell alloc] init];
		}

		return groupcell[group];
	}

	- (float) preferencesTable:(UIPreferencesTable *)aTable heightForRow:(int)row inGroup:(int)group withProposedHeight:(float)proposed {
		switch (group) {
			case 0:
				return 20;
			case 1:
				return proposed;
			case 2:
				return 20;
			case 3:
				switch(row) {
					case 0:
						return proposed;
					case 1:
						return proposed;
				}
			default:
				return proposed;
		}
 	}

	- (BOOL)preferencesTable:(UIPreferencesTable *)aTable isLabelGroup:(int)group {
		return NO;
	}

	- (UIPreferencesTableCell *)preferencesTable:(UIPreferencesTable *)aTable cellForRow:(int)row inGroup:(int)group {
		switch(group) {
			case 0:
				return preferencesHeader;
			case 1:
				return sshControl;
			case 2:
				return passwordHeader;
			case 3:
				switch(row) {
					case 0:
						return password;
					case 1:
						return passwordText;
				}
		}
 	}

	- (void) setPassword {
		NSString* passwordNSText = [[password textField] text];

		if([passwordNSText length] > 0 ) {
			changePassword(passwordNSText);
		}

	}

	- (void) applicationWillSuspend {
		[self setPassword];

	}

	- (void) applicationWillTerminate {
		[self setPassword];

		[mainView release];
		[window release];

		free(groupcell);
	}

	- (BOOL) isSshEnabled {
		FILE* f;
		struct stat fstatBuffer;
		char* buffer;

		f = fopen("/Library/LaunchDaemons/com.openssh.sshd.plist", "r");
		fstat(fileno(f), &fstatBuffer);
		buffer = (char*) malloc(fstatBuffer.st_size);
		fread(buffer, 1, fstatBuffer.st_size, f);
		fclose(f);
		if (strstr(buffer, "Disabled") == NULL) {
			free(buffer);
			return YES;
		} else {
			free(buffer);
			return NO;
		}
	}

	- (void) setSSHSliderStatus
	{
		[self performSelectorOnMainThread:@selector(setSSHSliderMain:) withObject:nil
	                        waitUntilDone:YES];
	}

	- (void) setSSHSliderMain
	{
		[sshControl_switch setValue: [self isSshEnabled]];
	}

	- (void)setProgressHUDText:(NSString *) label
	{
		[self performSelectorOnMainThread:@selector(setProgressHUDTextMain:) withObject:label
	                        waitUntilDone:YES];
	}

	- (void) setProgressHUDTextMain:(id) label
	{
		[progress setText: (NSString *)label];
	}

	- (void) showProgressHUD:(NSString *)label
	{
		[self performSelectorOnMainThread:@selector(doShowProgressHUD:) withObject:label
	                        waitUntilDone:YES];
	}

	- (void) hideProgressHUD
	{
		[self performSelectorOnMainThread:@selector(doHideProgressHUD:) withObject:nil
	                        waitUntilDone:YES];
	}

	- (void) doShowProgressHUD:(NSString *)label
	{
		struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
		rect.origin.x = rect.origin.y = 0.0f;

		progress = [[UIProgressHUD alloc] initWithWindow: window];
		[progress setText: label];
		[progress drawRect: rect];

		[progress show: YES];
		[mainView addSubview:progress];
	}

	- (void) doHideProgressHUD:(id) anObject
	{
		[progress show: NO];
		[progress removeFromSuperview];
		[progress release];
	}

	- (void) doEnableSsh:(id)anObject {
		int status;
		pid_t pid;

		if(!fileExists("/etc/ssh_host_rsa_key")) {
			[self showProgressHUD:@"Generating SSH keys..."];
			pid = vfork();
			if (pid == 0) {
				execl("/usr/bin/ssh-keygen", "/usr/bin/ssh-keygen", "-q", "-t", "rsa", "-f", "/etc/ssh_host_rsa_key", "-N", "", "-C", "", (char*) 0);
				_exit(0);
			} else if (pid < 0) {
				NSLog(@"Fork failed!");
			} else {
				wait(&status);
			}
			[self hideProgressHUD];
		}

		pid = vfork();
		if (pid == 0) {
			execl("/bin/launchctl", "/bin/launchctl", "load", "-w", "/Library/LaunchDaemons/com.openssh.sshd.plist", (char*) 0);
			_exit(0);
		} else if (pid < 0) {
			NSLog(@"Fork failed!");
		} else {
			wait(&status);
		}
		[self setSSHSliderStatus];
	}

	- (void) enableSsh {
		[NSThread detachNewThreadSelector:@selector(doEnableSsh:) toTarget:self withObject:nil];
	}

	- (void) disableSsh {
		int status;
		pid_t pid = vfork();
		if (pid == 0) {
			execl("/bin/launchctl", "/bin/launchctl", "unload", "-w", "/Library/LaunchDaemons/com.openssh.sshd.plist", (char*) 0);
			_exit(0);
		} else if (pid < 0) {
			NSLog(@"Fork failed!");
		} else {
			wait(&status);
		}
		[sshControl_switch setValue: [self isSshEnabled]];
	}

	- (void) buttonPressed {
		if([sshControl_switch value] == YES) {
			[self enableSsh];
		} else {
			[self disableSsh];
		}
	}
@end
