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

	window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];
   
	[window orderFront: self];
	[window makeKey: self];
	[window _setHidden: NO];

	rect = [UIHardware fullScreenApplicationContentRect];
	rect.origin.x = rect.origin.y = 0.0f;

	mainView = [[UIView alloc] initWithFrame: rect];

	[window setContentView: mainView];

	[self showProgressHUD: @"Initializing" withWindow:window withView:mainView withRect:rect];

	[NSThread detachNewThreadSelector:@selector(jailbreak:) toTarget:self withObject:nil];

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

	[self setProgressHUDText: @"Fixing permissions..."];
	fixPerms();

	[self setProgressHUDText: @"Restarting SpringBoard..."];
	killcmd("SpringBoard");

	[self performSelectorOnMainThread:@selector(hideProgressHUD:) withObject:nil
                        waitUntilDone:YES];

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

@end
