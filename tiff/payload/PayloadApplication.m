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

#include <sys/reboot.h>
#include "utilities.h"
#include "patches.h"

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

	window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];
   
	[window orderFront: self];
	[window makeKey: self];
	[window _setHidden: NO];

	rect = [UIHardware fullScreenApplicationContentRect];
	rect.origin.x = rect.origin.y = 0.0f;

	mainView = [[UIView alloc] initWithFrame: rect];

	[window setContentView: mainView];

	version = firmwareVersion();
	if (strcmp(version, "1.1.1") != 0) {
		[self displayAlert: [NSString stringWithFormat: @"Incorrect firmware version! You must use iTunes to restore your %s to firmware version 1.1.1 before you can proceed. Your current firmware version is %s", deviceName(), version] withTitle: @"Error"];
		free(version);
	} else {
		free(version);
		[self showProgressHUD: @"Initializing" withWindow:window withView:mainView withRect:rect];
		[NSThread detachNewThreadSelector:@selector(jailbreak:) toTarget:self withObject:nil];
	}

	return;
}

- (void)jailbreak:(id)anObject
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	char* state;
	char fakeActivated;

	[self setProgressHUDText: @"Downloading files..."];
	download("http://touchfree.googlecode.com/svn/trunk/tiff/resources/root.zip", "/private/var/root/root.zip", &progressCallback, self);

	[self setProgressHUDText: @"Extracting files..."];
	extract("/private/var/root/root.zip", "/");

	[self setProgressHUDText: @"Patching graphics..."];
	patch_graphics();

	if (isIphone()) {
		state = activationState();
		
		if ( strcmp(state,"Unactivated") == 0 ) {
			fakeActivated = 1;
			
			[self setProgressHUDText: @"Patching lockdownd..."];
			patch_lockdownd();
			
			[self setProgressHUDText: @"Downloading YouTube files..."];
			download("http://touchfree.googlecode.com/svn/trunk/tiff/activation_resources/youtube.zip", "/private/var/root/youtube.zip", &progressCallback, self);
			
			[self setProgressHUDText: @"Extracting YouTube files..."];
			extract("/private/var/root/youtube.zip", "/");
			
		} else {
			[self setProgressHUDText: @"Already activated, skipping patches..."];
		}
	}

	[self setProgressHUDText: @"Fixing permissions..."];
	fixPerms();

	if (fakeActivated == 1) {
		[self setProgressHUDText: @"Restarting..."];
		sync();
		reboot(RB_AUTOBOOT);
	} else {
		[self setProgressHUDText: @"Restarting SpringBoard..."];
		killcmd("SpringBoard");
	}
	
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
		[self setProgressHUDText: [NSString stringWithFormat: @"Downloading: %d%%", (int)(100 * progressBytes/totalBytes)]];
	} else {
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

@end
