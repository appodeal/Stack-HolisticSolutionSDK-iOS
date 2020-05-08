//
//  AppDelegate.m
//  ObjcSample
//
//  Created by artur on 06.05.2020.
//  Copyright © 2020 artur. All rights reserved.
//

#import "AppDelegate.h"
#import "RemoteConfigConnector.h"
#import "AppsFlyerConnector.h"
#import "ServicesInfo.h"

@import Appodeal;


NSString *const kAdDidInitializeNotificationName    = @"AdDidInitialize";
AppodealAdType const kAppodealTypes                 = AppodealAdTypeBanner;
BOOL const kConsent                                 = YES;


@interface AppDelegate ()

@property (nonatomic, strong) NSHashTable <id<Connector>> *connectors;

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Appodeal setLogLevel:APDLogLevelVerbose];
    
    [self setUpConnectors];
    [self connect:^{
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

- (void)setUpConnectors {
    RemoteConfigConnector *firebase = [[RemoteConfigConnector alloc] init];
    AppsFlyerConnector *appsflyer = [[AppsFlyerConnector alloc] init];
    
    self.connectors = [NSHashTable hashTableWithOptions:NSHashTableStrongMemory];
    [self.connectors addObject:firebase];
    [self.connectors addObject:appsflyer];
}

- (void)connect:(Completion)completion {
    dispatch_group_t group = dispatch_group_create();
    [self.connectors.allObjects enumerateObjectsUsingBlock:^(id<Connector> connector, NSUInteger idx, BOOL *stop) {
        dispatch_group_enter(group);
        [connector inititalise:^{
            dispatch_group_leave(group);
        }];
    }];
    dispatch_group_notify(group, dispatch_get_main_queue(), completion);
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {}

@end
