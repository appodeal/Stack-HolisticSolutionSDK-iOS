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


NSString *const completeNotification                = @"HSAppCompleteNotification";
AppodealAdType const kAppodealTypes                 = AppodealAdTypeBanner;
BOOL const kConsent                                 = YES;


@interface AppDelegate ()

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Appodeal.hs registerWithConnectors:@[
        HSFirebaseConnector.class,
        HSFacebookConnector.class,
        HSAppsFlyerConnector.class,
        HSAdjustConnector.class
    ]];
    
    NSString *appKey = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"AppodealAppKey"];
    
    HSAppConfiguration *configuration = [[HSAppConfiguration alloc] initWithAppKey:appKey
                                                                           timeout:30
                                                                             debug:HSAppConfigurationDebugEnabled
                                                                           adTypes:kAppodealTypes];
    
    [Appodeal setTestingEnabled:YES];
    [Appodeal.hs initializeWithApplication:application
                             launchOptions:launchOptions
                             configuration:configuration
                                completion:^(NSError *error) {
        [NSNotificationCenter.defaultCenter postNotificationName:completeNotification object:nil];
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
