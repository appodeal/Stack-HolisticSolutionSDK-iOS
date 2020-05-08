//
//  RemoteConfigConnector.m
//  ObjcSample
//
//  Created by artur on 07.05.2020.
//  Copyright © 2020 artur. All rights reserved.
//

#import "RemoteConfigConnector.h"

@import Appodeal;
@import Firebase;


NSTimeInterval const kRemoteConfigExpirationDuration = 60;

@interface RemoteConfigConnector()

@property (nonatomic, strong) FIRRemoteConfig *remoteConfig;
@property (nonatomic, copy) NSArray <NSString *> *keys;

@end


@implementation RemoteConfigConnector

- (instancetype)init {
    self = [super init];
    if (self) {
        self.keys = @[
            @"first_feature_enabled",
            @"second_feature_enabled"
        ];
    }
    return self;
}

- (FIRRemoteConfig *)remoteConfig {
    if (!_remoteConfig) {
        NSMutableDictionary *defaults = [NSMutableDictionary dictionaryWithCapacity:self.keys.count];
        [self.keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
            defaults[key] = @"true";
        }];
        
        FIRRemoteConfigSettings *settings = [[FIRRemoteConfigSettings alloc] init];
        settings.minimumFetchInterval = 0;
        
        _remoteConfig = [FIRRemoteConfig remoteConfig];
        _remoteConfig.configSettings = settings;
        
        [_remoteConfig setDefaults:defaults];
    }
    return _remoteConfig;
}

- (void)inititalise:(Completion)completion {
    [FIRApp configure];
    // Get instance id
    /*
    [FIRInstanceID.instanceID instanceIDWithHandler:^(FIRInstanceIDResult *result, NSError *error) {
        NSLog(@"Device token is %@", result.token);
    }];
    */
    // Fetch config
    __weak typeof(self) weakSelf = self;
    [self.remoteConfig fetchWithExpirationDuration:kRemoteConfigExpirationDuration
                                 completionHandler:^(FIRRemoteConfigFetchStatus status, NSError *error) {
        if (status == FIRRemoteConfigFetchStatusSuccess) {
            [weakSelf activate:completion];
        } else {
            NSLog(@"Remote config fetch error");
            completion ? completion() : nil;
        }
    }];
}

- (void)activate:(Completion)completion {
    __weak typeof(self) weakSelf = self;
    // Activate config
    [self.remoteConfig activateWithCompletionHandler:^(NSError *error) {
        // Get keywords for Appodeal
        NSMutableDictionary <NSString *, NSString *> *extras = [NSMutableDictionary dictionaryWithCapacity:1];
        extras[@"keywords"] = [weakSelf remoteConfigKeywords];
        dispatch_async(dispatch_get_main_queue(), ^{
            // Send keywords as extras
            [Appodeal setExtras:extras];
            completion ? completion() : nil;
        });
    }];
}

- (NSString *)remoteConfigKeywords {
    // Transform values by keys to comma joined string
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:self.keys.count];
    [self.keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        NSString *value = [self.remoteConfig configValueForKey:key].stringValue;
        if (value) {
            [values addObject:value];
        }
    }];
    NSString *keywords = [values componentsJoinedByString:@","];
    return keywords;
}

@end
