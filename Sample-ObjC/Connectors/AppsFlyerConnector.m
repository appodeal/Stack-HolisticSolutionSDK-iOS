//
//  AppsFlyerConnector.m
//  ObjcSample
//
//  Created by artur on 07.05.2020.
//  Copyright © 2020 artur. All rights reserved.
//

#import "AppsFlyerConnector.h"
#import "ServicesInfo.h"

@import Appodeal;
@import AppsFlyerLib;


@interface AppsFlyerConnector() <AppsFlyerTrackerDelegate>

@end


@implementation AppsFlyerConnector

- (void)inititalise:(Completion)completion {
    // Configure AppsFlyer
    [AppsFlyerTracker.sharedTracker setAppsFlyerDevKey:ServicesInfo.sharedInfo.appsFlyerDevId];
    [AppsFlyerTracker.sharedTracker setAppleAppID:ServicesInfo.sharedInfo.appsFlyerAppId];
    [AppsFlyerTracker.sharedTracker setDelegate:self];
    // Set isDebug to true to see AppsFlyer debug logs
    [AppsFlyerTracker.sharedTracker setIsDebug:true];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(didLaunch)
                                               name:UIApplicationDidBecomeActiveNotification
                                             object:nil];
    
    // Set AppsFlyer tracker
    NSMutableDictionary <NSString *, NSString *> *extras = [NSMutableDictionary dictionaryWithCapacity:1];
    extras[kAPDAppsFlyerIdExtrasKey] = AppsFlyerTracker.sharedTracker.getAppsFlyerUID;
    [Appodeal setExtras:extras];
    
    // Notify completion
    dispatch_async(dispatch_get_main_queue(), ^{
        completion ? completion() : nil;
    });
}

- (void)didLaunch {
    [AppsFlyerTracker.sharedTracker trackAppLaunch];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - AppsFlyerTrackerDelegate

- (void)onConversionDataFail:(NSError *)error {}

- (void)onConversionDataSuccess:(NSDictionary *)conversionInfo {
    [Appodeal setSegmentFilter:conversionInfo];
}

@end
