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

/**
 主机名称 - ReachAbility
 */
- (NSString *)hostname;

/**
 主机IP地址 - ReachAbility
 */
- (NSString *)getIPAddressForHost:(NSString *)theHost;

/**
 本机IP地址 - ReachAbility
 */
- (NSString *)localIPAddress;

/**
 本机 WiFi IP地址 - ReachAbility
 */
- (NSString *)localWiFiIPAddress;

/**
 本机 WiFi IP地址数组 - ReachAbility
 */
- (NSArray *)localWiFiIPAddresses;

// Availability tests
- (BOOL)hostAvailable:(NSString *)theHost;

/**
 网络是否可用 - ReachAbility
 */
- (BOOL)networkAvailable;

/**
 WLAN是否可用 - ReachAbility
 */
- (BOOL)activeWLAN;

/**
 WWAN是否可用 - ReachAbility
 */
- (BOOL)activeWWAN;

/**
 个人热点是否可用 - ReachAbility
 */
- (BOOL)activePersonalHotspot;

/**
 检查WiFi - ReachAbility
 */
- (BOOL)performWiFiCheck;

/**
 设置网络可用性观察者 - ReachAbility
 */
- (BOOL)scheduleReachAbilityWatcher:(id <ReachAbilityWatcher>)watcher;

/**
 取消网络可用性观察者 - ReachAbility
 */
- (void)unscheduleReachAbilityWatcher;

@end
