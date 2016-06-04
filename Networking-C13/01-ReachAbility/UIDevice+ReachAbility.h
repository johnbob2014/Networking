//
//  UIDevice+ReachAbility.h
//  Networking-C13
//
//  Created by 张保国 on 16/6/2.
//  Copyright © 2016年 BobZhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <sys/socket.h>
#include <netinet/in.h>

@protocol ReachAbilityWatcher <NSObject>
- (void)reachAbilityChanged;
@end

@interface UIDevice (ReachAbility)
+ (NSString *)stringFromAddress: (const struct sockaddr *)address;
+ (BOOL)addressFromString:(NSString *)IPAddress address:(struct sockaddr_in *)address;
+ (NSData *)dataFromAddress:(struct sockaddr_in)address;
+ (NSString *)addressFromData:(NSData *)addressData;
+ (NSString *)portFromData:(NSData *)addressData;

// Retrieve connectivity info
- (NSString *)hostname;
- (NSString *)getIPAddressForHost:(NSString *)theHost;
- (NSString *)localIPAddress;
- (NSString *)localWiFiIPAddress;
- (NSArray *)localWiFiIPAddresses;

// Availability tests
- (BOOL)hostAvailable:(NSString *)theHost;

/**
    网络是否可用
 */
- (BOOL)networkAvailable;

/**
    WLAN是否可用
 */
- (BOOL)activeWLAN;

/**
    WWAN是否可用
 */
- (BOOL)activeWWAN;


- (BOOL)activePersonalHotspot;
- (BOOL)performWiFiCheck;

- (BOOL)scheduleReachAbilityWatcher:(id <ReachAbilityWatcher>)watcher;
- (void)unscheduleReachAbilityWatcher;

@end
