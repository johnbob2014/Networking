//
//  TestBedViewController.m
//  Networking-C13
//
//  Created by 张保国 on 16/6/4.
//  Copyright © 2016年 BobZhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utility.h"

#pragma mark - TBVC_01

#import "UIDevice+Reachability.h"
@interface TBVC_01 : UIViewController <ReachAbilityWatcher>
@end

@implementation TBVC_01
{
    UITextView *textView;
}

- (void)loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    textView = [[UITextView alloc] init];
    textView.editable = NO;
    textView.font = [UIFont fontWithName:@"Futura" size:IS_IPAD ? 24.0f : 12.0f];
    textView.textColor = COOKBOOK_PURPLE_COLOR;
    textView.text = @"";
    [self.view addSubview:textView];
    PREPCONSTRAINTS(textView);
    STRETCH_VIEW(self.view, textView);
    
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Test", @selector(runTests));
}


- (void)log:(id)formatstring,...
{
    va_list arglist;
    if (!formatstring) return;
    va_start(arglist, formatstring);
    NSString *outstring = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
    va_end(arglist);
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSString *newString = [NSString stringWithFormat:@"%@\n%@: %@", textView.text, [NSDate date], outstring];
        textView.text = newString;
        [textView scrollRangeToVisible:NSMakeRange(newString.length, 1)];
    }];
}

// Run basic reachability tests
- (void)runTests
{
    // Many of the following reachability tests can block.  In your production code, they should not be run in the main thread.
    
    [[[NSOperationQueue alloc] init] addOperationWithBlock:
     ^{
         UIDevice *device = [UIDevice currentDevice];
         [self log:@"\n\nReachability Tests"];
         [self log:@"Current host: %@", [device hostname]];
         [self log:@"Local WiFi IP: %@", [device localWiFiIPAddress]];
         [self log:@"All WiFi IP: %@", [device localWiFiIPAddresses]];
         
         [self log:@"Network available?: %@", [device networkAvailable] ? @"Yes" : @"No"];
         [self log:@"Active WLAN?: %@", [device activeWLAN] ? @"Yes" : @"No"];
         [self log:@"Active WWAN?: %@", [device activeWWAN] ? @"Yes" : @"No"];
         [self log:@"Active hotspot?: %@", [device activePersonalHotspot] ? @"Yes" : @"No"];
         
         [self checkAddresses];
     }];
}

- (void)checkAddresses
{
    UIDevice *device = [UIDevice currentDevice];
    if (![device networkAvailable]) return;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[[NSOperationQueue alloc] init] addOperationWithBlock:
     ^{
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             [self log:@"\n\nChecking IP Addresses"];
         }];
         NSString *google = [device getIPAddressForHost:@"www.google.com"];
         NSString *amazon = [device getIPAddressForHost:@"www.amazon.com"];
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             [self log:@"Google: %@", google];
             [self log:@"Amazon: %@", amazon];
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             
             [self checkSites];
         }];
     }];
}

- (void)checkSite:(NSString *)urlString
{
    UIDevice *device = [UIDevice currentDevice];
    [self log:@"• %@ : %@", urlString, [device hostAvailable:urlString] ? @"available" : @"not available"];
}

// Note, if your ISP redirects unavailable sites to their own servers, these will give false positives.
- (void)checkSites
{
    [[[NSOperationQueue alloc] init] addOperationWithBlock:
     ^{
         NSDate *date = [NSDate date];
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             [self log:@"\n\nChecking Site Availability"];
         }];
         NSOperationQueue * siteCheckOperationQueue = [[NSOperationQueue alloc] init];
         [siteCheckOperationQueue addOperationWithBlock:^{
             [self checkSite:@"www.google.com"];
             [self checkSite:@"www.ericasadun.com"];
             [self checkSite:@"www.notverylikely.com"];
             [self checkSite:@"192.168.0.108"];
             [self checkSite:@"pearson.com"];
             [self checkSite:@"www.pearson.com"];
         }];
         [siteCheckOperationQueue waitUntilAllOperationsAreFinished];
         
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             [self log:@"Elapsed time: %0.1f", [[NSDate date] timeIntervalSinceDate:date]];
         }];
     }];
}

- (void)reachAbilityChanged
{
    [self log:@"\n\n**** REACHABILITY CHANGED! ****"];
    [self runTests];
}

@end

#pragma mark - TBVC_02


