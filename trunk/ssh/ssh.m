#import <UIKit/UIKit.h>

#import "ssh.h"

int main(int argc, char **argv)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    return UIApplicationMain(argc, argv, [sshApplication class]);
}
