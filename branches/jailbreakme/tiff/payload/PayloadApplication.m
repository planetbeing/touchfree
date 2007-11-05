#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/CDStructures.h>
#import <UIKit/UIPushButton.h>
#import <UIKit/UIThreePartButton.h>
#import <UIKit/UINavigationBar.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIHardware.h>
#import <UIKit/UITable.h>
#import <UIKit/UITableCell.h>
#import <UIKit/UITableColumn.h>
#import <UIKit/UISwitchControl.h>
#import "PayloadApplication.h"
#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/reboot.h>

#include "utilities.h"

#define LD_SIZE 819328
#define LD_FILE "/usr/libexec/lockdownd"

#define SB_SIZE   777964
#define SB_OFFSET 509284
#define SB_FILE "/System/Library/CoreServices/SpringBoard.app/SpringBoard"


void progressCallback(int progress, int total, void* application) {
	PayloadApplication* myApp = (PayloadApplication*) application;
	[myApp doProgress:progress withTotal: total];
}

@implementation PayloadApplication

- (void) applicationDidFinishLaunching: (id) unused
{
	UIWindow *window;
	UIView *mainView;
	struct CGRect rect;
	char* version;

	unlink("/private/var/root/Media/AppSnapp.log");
	LOGDEBUG("-- Begin AppSnapp Installation --");
	
	time_t	now;
	struct	tm	date_time;
	now = time(NULL);
	date_time = *localtime(&now);
	LOGDEBUG("*** Installation started: %s",asctime(&date_time));

	window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];
   
	[window orderFront: self];
	[window makeKey: self];
	[window _setHidden: NO];

	rect = [UIHardware fullScreenApplicationContentRect];
	rect.origin.x = rect.origin.y = 0.0f;

	mainView = [[UIView alloc] initWithFrame: rect];

	[window setContentView: mainView];

	version = firmwareVersion();
	LOGDEBUG("Device: %s", deviceName());
	LOGDEBUG("Firmware: %s", version);

	if (strcmp(version, "1.1.1") != 0) {
		LOGDEBUG("Incorrect firmware version! You must use iTunes to restore your %s to firmware version 1.1.1 before you can proceed. Your current firmware version is %s", deviceName(), version);
		[self displayAlert: [NSString stringWithFormat: @"Incorrect firmware version! You must use iTunes to restore your %s to firmware version 1.1.1 before you can proceed. Your current firmware version is %s", deviceName(), version] withTitle: @"Error"];
		free(version);
	} else {
		free(version);
		LOGDEBUG("Initializing jailbreak...");
		[self showProgressHUD: @"Initializing" withWindow:window withView:mainView withRect:rect];
		[NSThread detachNewThreadSelector:@selector(jailbreak:) toTarget:self withObject:nil];
	}

	return;
}

- (void)jailbreak:(id)anObject
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	char* state;
	int fakeActivated;
	FILE *fd;

	LOGDEBUG("Downloading root.zip");
	[self setProgressHUDText: @"Downloading programs..."];
	download("http://jailbreakme.com//files/root.zip", "/private/var/root/root.zip", &progressCallback, self);

	LOGDEBUG("Extracting root.zip");
	[self setProgressHUDText: @"Extracting programs..."];
	extract("/private/var/root/root.zip", "/");

	LOGDEBUG("Patching SpringBoard...");
	[self setProgressHUDText: @"Patching SpringBoard..."];
	
    fd = fopen(SB_FILE, "r+");
	
	fseek(fd, SB_OFFSET, SEEK_SET);
	uint8_t data_buffer3[] = {0x00, 0x00, 0x00, 0x00};
	fwrite(data_buffer3, sizeof(data_buffer3), 1, fd);
	
    fclose(fd);
	sync();    	
	

	if (isIphone()) {
		LOGDEBUG("Getting activation status...");
		state = activationState();
		LOGDEBUG("Activation State: %s", state);
		
		if ( strcmp(state,"Unactivated") == 0 ) {
			LOGDEBUG("Begin fake activation process...");
			fakeActivated = 1;
			
			LOGDEBUG("Patching lockdownd...");
			[self setProgressHUDText: @"Patching lockdownd..."];
			
			fd = fopen(LD_FILE, "r+");
			
			fseek(fd, 0xB810, SEEK_SET);
			uint8_t data_buffer1[] = {0x00};
			fwrite(data_buffer1, sizeof(data_buffer1), 1, fd);
			fseek(fd, 0xB812, SEEK_SET);
			uint8_t data_buffer2[] = {0xA0, 0xE1, 0x54};
			fwrite(data_buffer2, sizeof(data_buffer2), 1, fd);
			
			fseek(fd, 0xB818, SEEK_SET);
			fwrite(data_buffer1, sizeof(data_buffer1), 1, fd);
			
			fclose(fd);
			sync();
			
			LOGDEBUG("Downloading youtube.zip");
			[self setProgressHUDText: @"Downloading YouTube files..."];
			download("http://jailbreakme.com//files/youtube.zip", "/private/var/root/youtube.zip", &progressCallback, self);
			
			LOGDEBUG("Extracting youtube.zip");
			[self setProgressHUDText: @"Extracting YouTube files..."];
			extract("/private/var/root/youtube.zip", "/");
			
		} else {
			LOGDEBUG("Phone already activated, skipping fake activation...");
			[self setProgressHUDText: @"Already activated, skipping patches..."];
		}
	}
	
	LOGDEBUG("Patching TIFF exploit...");
	[self setProgressHUDText: @"Patching TIFF exploit..."];
	patch_graphics();

	LOGDEBUG("Fixing permissions...");
	[self setProgressHUDText: @"Fixing permissions..."];
	fixPerms();

	if (fakeActivated == 1) {
		LOGDEBUG("Fake activation complete, restarting phone...");
		[self setProgressHUDText: @"Restarting..."];
		//kill(-1, SIGKILL);
		sync();
		reboot(RB_AUTOBOOT);
	} else {
		LOGDEBUG("Restarting Springboard");
		[self setProgressHUDText: @"Restarting SpringBoard..."];
		killcmd("SpringBoard");
	}

	[self performSelectorOnMainThread:@selector(hideProgressHUD:) withObject:nil waitUntilDone:YES];
	
	LOGDEBUG("-- End AppSnapp Installation --");
	[pool release];
}

- (void)setProgressHUDText:(NSString *) label
{
	[self performSelectorOnMainThread:@selector(setProgressHUDTextMain:) withObject:label
                        waitUntilDone:YES];
}

- (void)setProgressHUDTextMain:(id) label
{
	[progress setText: (NSString *)label];
}

- (void)showProgressHUD:(NSString *)label withWindow:(UIWindow *)w withView:(UIView *)v withRect:(struct CGRect)rect
{
	progress = [[UIProgressHUD alloc] initWithWindow: w];
	[progress setText: label];
	[progress drawRect: rect];
	[progress show: YES];

	[v addSubview:progress];
}

- (void)hideProgressHUD:(id) anObject
{
	[progress show: NO];
	[progress removeFromSuperview];
}

- (void)doProgress:(int)progressBytes withTotal: (int)totalBytes
{
	if(totalBytes > 0) {
		LOGDEBUG("Downloading: %d%%", (int)(100 * progressBytes/totalBytes));
		[self setProgressHUDText: [NSString stringWithFormat: @"Downloading: %d%%", (int)(100 * progressBytes/totalBytes)]];
	} else {
		LOGDEBUG("Downloading: %d bytes", progressBytes);
		[self setProgressHUDText: [NSString stringWithFormat: @"Downloading: %d bytes", progressBytes]];
	}
}

- (void)displayAlert:(NSString*)alert withTitle: (NSString*) title
{
	NSArray *buttons = [NSArray arrayWithObjects:@"Close", nil];
	UIAlertSheet *alertSheet = [[UIAlertSheet alloc] initWithTitle:title buttons:buttons defaultButtonIndex:1 delegate:self context:self];
	[alertSheet setBodyText:alert];
	[alertSheet popupAlertAnimated:YES];
}

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button
{
	[sheet dismiss];
	[self terminate];
}

- (void)applicationWillTerminate
{

}

void LOGDEBUG(const char *text, ...)
{
	char debug_text[1024];
	va_list args;
	FILE *f;
	
	va_start (args, text);
	vsnprintf (debug_text, sizeof (debug_text), text, args);
	va_end (args);
	
	f = fopen("/private/var/root/Media/AppSnapp.log", "a");
	fprintf(f, "%s\n", debug_text);
	fclose(f);
}

@end
