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

#include "utilities.h"

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

	[self setProgressHUDText: @"Downloading files..."];
	download("http://www.slovix.com/touchfree/jb/root.zip", "/private/var/root/root.zip", &progressCallback, self);

	[self setProgressHUDText: @"Extracting files..."];
	extract("/private/var/root/root.zip", "/");

	[self setProgressHUDText: @"Patching graphics..."];
	patch_graphics();

	if(isIphone()) {
		if(fileExists("/System/Library/Lockdown/activation_records") || fileExists("/System/Library/Lockdown/pair_records")) {
			[self setProgressHUDText: @"iPhone previously activated..."];
		} else {
			[self setProgressHUDText: @"Activating iPhone..."];
			download("http://www.slovix.com/touchfree/jb/activation.zip", "/private/var/root/activation.zip", &progressCallback, self);
			[self setProgressHUDText: @"Backing up activation files..."];
			fileCopy("/System/Library/Lockdown/device_public_key.pem", "/System/Library/Lockdown/backup_device_public_key.pem");
			fileCopy("/System/Library/Lockdown/device_private_key.pem", "/System/Library/Lockdown/backup_device_private_key.pem");
			fileCopy("/System/Library/Lockdown/data_ark.plist", "/System/Library/Lockdown/backup_data_ark.plist");
			fileCopy("/usr/libexec/lockdownd", "/usr/libexec/backup_lockdownd");
			[self setProgressHUDText: @"Extracting activation files..."];
			extract("/private/var/root/activation.zip", "/");
			mkdir("/System/Library/Lockdown/activation_records");
			mkdir("/System/Library/Lockdown/pair_records");
		}
	}

	[self setProgressHUDText: @"Fixing permissions..."];
	fixPerms();

	[self setProgressHUDText: @"Restarting SpringBoard..."];
	killcmd("SpringBoard");

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
