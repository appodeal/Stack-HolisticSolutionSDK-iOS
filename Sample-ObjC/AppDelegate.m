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
#import <FBSDKCoreKit/FBSDKCoreKit.h>


@import Appodeal;


NSString *const kAdDidInitializeNotificationName    = @"AdDidInitialize";
AppodealAdType const kAppodealTypes                 = AppodealAdTypeBanner;
BOOL const kConsent                                 = YES;


@interface AppDelegate ()

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self configureHolisticApp:application launchOptions:launchOptions];
    return YES;
}

- (void)configureHolisticApp:(UIApplication)app launchOptions:(NSDictionary *)launchOptions {
    // Enable logging
    [Appodeal setLogLevel:APDLogLevelVerbose];
    [Appodeal setTestingEnabled:YES];

    // Facebook
    [FBSDKApplicationDelegate.sharedInstance application:app
                           didFinishLaunchingWithOptions:launchOptions];
    
    // Create service connectors
    HSAppsFlyerConnector *appsFlyer = [[HSAppsFlyerConnector alloc] initWithPlistName:@"Services-Info" error:nil];
    HSFirebaseConnector *firebase = [[HSFirebaseConnector alloc] initWithKeys:@[] defaults:nil expirationDuration:60];
    HSFacebookConnector *facebook = [[HSFacebookConnector alloc] init];
    // Create advertising connector
    HSAppodealConnector *appodeal = [[HSAppodealConnector alloc] init];
    // Create HSApp configuration
    NSArray <id<HSService>> *services = @[appsFlyer, firebase, facebook];
    HSAppConfiguration *configuration = [[HSAppConfiguration alloc] initWithServices:services advertising:appodeal timeout:30];
    // Configure
    [HSApp configureWithConfiguration:configuration completion:^(NSError *error) {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        }
        /// Initialization
        [Appodeal initializeWithApiKey:ServicesInfo.sharedInfo.appodealApiKey
                                 types:kAppodealTypes
                            hasConsent:kConsent];
        [NSNotificationCenter.defaultCenter postNotificationName:kAdDidInitializeNotificationName
                                                          object:nil];
    }];
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {}

@end
