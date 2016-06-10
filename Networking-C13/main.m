/*
 想测试哪个主题，就取消 #define 主题名 的注释，并把其余的主题注释掉
 */

@import UIKit;

#define TBVC_01
//#define TBVC_04

#import "Utility.h"
#import "UIDevice+ReachAbility.h"
#import "TestBedViewController.h"

#pragma mark - Application Setup

@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
@property (nonatomic, strong) UIWindow *window;
@end

@implementation TestBedAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.tintColor = COOKBOOK_PURPLE_COLOR;
    
#ifdef TBVC_01
    TBVC_01_ReachAbility *tbvc = [[TBVC_01_ReachAbility alloc] init];
#endif
    
#ifdef TBVC_04
    TBVC_04_BackgroundTransfers *tbvc = [[TBVC_04_BackgroundTransfers alloc] init];
#endif
    
    tbvc.edgesForExtendedLayout = UIRectEdgeNone;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tbvc];
    _window.rootViewController = nav;
    [_window makeKeyAndVisible];

#ifdef TBVC_01
    [[UIDevice currentDevice] scheduleReachAbilityWatcher:tbvc];
#endif
    
    return YES;
}

#ifdef TBVC_04
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler{
    TBVC_04_BackgroundTransfers *tbvc=(TBVC_04_BackgroundTransfers *)[(UINavigationController *)self.window.rootViewController topViewController];
    tbvc.view.backgroundColor = [UIColor greenColor];
    tbvc.statusLabel.text = @"BACKGROUND DOWNLOAD COMPLETED!";
    [self presentNotification];
    completionHandler();
}

- (void)presentNotification{
    UILocalNotification *noti = [[UILocalNotification alloc] init];
    noti.alertBody = @"Download Complete!";
    noti.alertAction = @"Background Transfer";
    noti.soundName = UILocalNotificationDefaultSoundName;
    noti.applicationIconBadgeNumber = 1;
    [[UIApplication sharedApplication] presentLocalNotificationNow:noti];
}
#endif

@end


#pragma mark - main

int main(int argc, char *argv[])
{
    @autoreleasepool
    {
        int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
        return retVal;
    }
}
