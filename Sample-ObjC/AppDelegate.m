//
//  AppDelegate.m
//  ObjcSample
//
//  Created by artur on 06.05.2020.
//  Copyright © 2020 artur. All rights reserved.
//

#import "AppDelegate.h"
#import "ServicesInfo.h"
#import <HolisticSolutionSDK/HolisticSolutionSDK.h>

@import Appodeal;


NSString *const kAdDidInitializeNotificationName    = @"AdDidInitialize";
AppodealAdType const kAppodealTypes                 = AppodealAdTypeBanner;
BOOL const kConsent                                 = YES;


@interface AppDelegate ()

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Enable logging
    [Appodeal setLogLevel:APDLogLevelVerbose];
    HSAppsFlyerConnector *appsFlyer = [[HSAppsFlyerConnector alloc] initWithPlistName:@"Services-Info"
                                                                                error:nil];
    HSRemoteConfigConnector *remoteConfig = [[HSRemoteConfigConnector alloc] initWithKeys:@[]
                                                                                 defaults:nil
                                                                       expirationDuration:60];
    HSAppodealConnector *appodeal = [[HSAppodealConnector alloc] init];
    HSAppConfiguration *configuration = [[HSAppConfiguration alloc] initWithAttribution:appsFlyer
                                                                         productTesting:remoteConfig
                                                                            advertising:appodeal
                                                                                timeout:15];
    [HSApp configureWithConfiguration:configuration completion:^(NSError *error) {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        }
        // Test Mode
        [Appodeal setTestingEnabled:YES];
        /// Initialization
        [Appodeal initializeWithApiKey:ServicesInfo.sharedInfo.appodealApiKey
                                 types:kAppodealTypes
                            hasConsent:kConsent];
        [NSNotificationCenter.defaultCenter postNotificationName:kAdDidInitializeNotificationName
                                                          object:nil];
    }];
    return YES;
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {}

@end
