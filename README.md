# iOS DataCore Sample

Describes how AppsFlyer and Firebase Remote Config A/B  testing can be used with
Appodeal iOS SDK of version 2.6.3 and above to send attribution data to Stack Data Core.


## Dynamic app/monetization behavior 

1. Use AppsFlyer callback onConversionDataSuccess to receive campaign name and other keys from AppsFlyer 

2. Campaign name can be used to set up monetization logic for whales and low—cost users. 

*Objective-C*

```obj-c
- (void)onConversionDataSuccess:(NSDictionary *)conversionInfo {
    [Appodeal setSegmentFilter:conversionInfo];
}
```

*Swift*
```swift
func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
    Appodeal.setSegmentFilter(conversionInfo)
}
```


## App product A/B testing using Firebase Remote Config

After you create remote config paramters you can send it to Appodeal. Appodeal will recieve Remote Config parameters as "keywords " — 
comma joined list of remote config paramters string values.

> Note. Appodeal can receive extras at any application lifecycle moment. But we recommend to set extras before Appodeal initialisation to avoid data missing.

*Objective-C*

```obj-c
- (void)activateRemoteConfig {
    // Configure app
    [FIRApp configure];
    // Fetch config
    __weak typeof(self) weakSelf = self;
    [self.remoteConfig fetchWithExpirationDuration:kRemoteConfigExpirationDuration
                                 completionHandler:^(FIRRemoteConfigFetchStatus status, NSError *error) {
        if (status == FIRRemoteConfigFetchStatusSuccess) {
            [self.remoteConfig activateWithCompletionHandler:^(NSError *error) {
                // Get keywords for Appodeal
                NSLog(@"Remote config is active");
                // Array of keys that was setted up in Firebase Dashboard
                NSArray *configKeys = @[
                    @"first_feature", 
                    @"second_feature"
                ];
                // Get values for keys
                NSMutableArray *values = [NSMutableArray arrayWithCapacity:configKeys];
                [configKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
                    NSString *value = [self.remoteConfig configValueForKey:key].stringValue;
                    if (value) {
                        [values addObject:value];
                    }
                }];
                // Transform array of values into comma joined string
                NSString *keywords = [values componentsJoinedByString:@","];
                // Create extras dictionary
                NSMutableDictionary <NSString *, NSString *> *extras = [NSMutableDictionary dictionaryWithCapacity:1];
                extras[@"keywords"] = keywords;
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Send extras to Appodeal
                    [Appodeal setExtras:extras];
                    // Initialise Appodeal SDK here
                });
            }];
        } else {
            NSLog(@"Remote config fetch error");
        }
    }];
}
```

*Swift*
```swift
func activateRemoteConfig() {
    // Configure app
    FirebaseApp.configure()
    // Fetch Remote Config
    config.fetch(withExpirationDuration: expirationDuration) { [weak self] status, error in
        // Fallback on fetch failed
        guard status == .success, error == nil else {
            print("Remote config fetch error")
            return
        }
            
        self?.config.activate { [weak self] error in
            print("Remote config is activated with error: \(error.debugDescription)")
            // Array of keys that was setted up in Firebase Dashboard
            let keys = [
                "first_feature",
                "second_feature"
            ]
            // Get values for keys
            let values = keys.compactMap { self?.config.configValue(forKey: $0).stringValue }
            // Transform array of values into comma joined string
            let keywords = values.joined(separator: ",")
            // Create extras dictionary
            let extras: [String: String] = [
                "keywords": keywords
            ]
            DispatchQueue.main.async {
                // Send extras to Appodeal
                Appodeal.setExtras(extras)
                // Initialise Appodeal SDK here
            }
        }
    }
}
```


## Avoid zero IDFA

*Objective-C*

```obj-c
NSMutableDictionary <NSString *, NSString *> *extras = [NSMutableDictionary dictionaryWithCapacity:1];
extras[kAPDAppsFlyerIdExtrasKey] = AppsFlyerTracker.sharedTracker.getAppsFlyerUID;
[Appodeal setExtras:extras];
```

*Swift*
```swift
Appodeal.setExtras([
    kAPDAppsFlyerIdExtrasKey: AppsFlyerTracker.shared().getAppsFlyerUID()
])
```