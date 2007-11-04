#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UISwitchControl.h>
#import <UIKit/UIPreferencesTableCell.h>
#import <UIKit/UIPreferencesTextTableCell.h>
#import <UIKit/UIPreferencesControlTableCell.h>
#import <UIKit/UIProgressHUD.h>
#import <UIKit/UITextField.h>
#import <UIKit/UIPushButton.h>

@interface sshApplication : UIApplication {
	UIView *mainView;
	UIWindow *window;
	UIPreferencesTableCell *preferencesHeader;
	UIPreferencesTableCell *sshControl;
	UISwitchControl *sshControl_switch;
	UIPreferencesTableCell **groupcell;
	UIProgressHUD *progress;

	UIPreferencesTableCell *passwordHeader;
	UIPreferencesTextTableCell *password;
	UIPreferencesTableCell *passwordText;
}

- (BOOL) isSshEnabled;
- (void) setSSHSliderStatus;
- (void) setSSHSliderMain;
- (void) doEnableSsh:(id)anObject;

- (void) showProgressHUD:(NSString *)label;
- (void) hideProgressHUD;
- (void) doShowProgressHUD:(NSString *)label;
- (void) doHideProgressHUD:(id) anObject;
- (void) setProgressHUDText:(NSString *) label;
- (void) setProgressHUDTextMain:(id) label;

- (void) disableSsh;
- (void) enableSsh;
- (void) buttonPressed;

- (void) setPassword;
@end
