# iOS Holistic Solution SDK

Describes how AppsFlyer and Firebase Remote Config A/B testing can be used with
Appodeal iOS SDK of version 2.6 and above to send attribution data to Stack Data Core.

## Table of Contents

* [Integration](#integration)
* [Usage](#usage)
* [Connectors](#connectors)
  + [AppsFlyer](#appsflyer)
  + [RemoteConfig](#remoteconfig)
  + [Appodeal](#appodeal)

## Integration

1. Add folowing lines into your `Podfile`

``` ruby

source 'https://cdn.cocoapods.org/'
source 'https://github.com/appodeal/CocoaPods.git'

install! 'cocoapods', :deterministic_uuids => false, :warn_for_multiple_pod_sources => false
use_frameworks!

def holistic_solution
    pod 'HolisticSolutionSDK'

    # If you doesn't use some of connectors you can 
    # integrate only explicit sub pods
    #
    # pod 'HolisticSolutionSDK/Core'
    # pod 'HolisticSolutionSDK/Appodeal'
    # pod 'HolisticSolutionSDK/AppsFlyer'
    # pod 'HolisticSolutionSDK/FirebaseRemoteConfig'
end

target 'App' do
  project 'App.xcodeproj'
  holistic_solution
end

``` 

2. Run `pod install` 

## Usage

Holistic Solution SDK will initialise AppsFlyer, fetch Firebase Remote Config and sync all required data to Appodeal. There is `HSApp` class to provide described functional. Call configure method with instance of `HSAppConfiguration` will trigger initialisation.

Required parameters for `HSAppConfiguration` is **attibution**, **product testing** and **advertising** service connectors. By default they are AppsFlyer, FirebaseRemoteConfig and Appodeal. Core also supports passing of array of connectors instead of single instance. **Timeout** in this case is timeout for **one** operation: starting attribution service or fetching remote config. By default the value is **30 sec**.

1. Import SDK umbrella header or module into your `AppDelegate` file. 

*Objective-C*

```obj-c
#import <HolisticSolutionSDK/HolisticSolutionSDK.h>
```

*Swift*
```swift
import HolisticSolutionSDK
```

2. Add folowing code at application did finish launching event.

*Objective-C*

```obj-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    HSAppsFlyerConnector *appsFlyer = [[HSAppsFlyerConnector alloc] initWithDevKey:<#(NSString * _Nonnull)#>
                                                                             appId:<#(NSString * _Nonnull)#>
                                                                              keys:<#(NSArray<NSString *> * _Nonnull)#>];
    HSRemoteConfigConnector *remoteConfig = [[HSRemoteConfigConnector alloc] initWithKeys:<#(NSArray<NSString *> * _Nonnull)#>
                                                                                 defaults:<#(NSDictionary<NSString *,NSObject *> * _Nullable)#>
                                                                       expirationDuration:<#(NSTimeInterval)#>];
    HSAppodealConnector *appodeal = [[HSAppodealConnector alloc] init];
    HSAppConfiguration *configuration = [[HSAppConfiguration alloc] initWithAttribution:appsFlyer
                                                                         productTesting:remoteConfig
                                                                            advertising:appodeal
                                                                                timeout:<#(NSTimeInterval)#>];
    [HSApp configureWithConfiguration:configuration completion:^(NSError *error) {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        }
        // Initialise Appodeal here
    }];
    return YES;
}
```

*Swift*
```swift
func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    Appodeal.setLogLevel(.verbose)
    let appsFlyer = HSAppsFlyerConnector(devKey: <#T##String#>, 
                                          appId: <#T##String#>,   
                                          keys: <#T##[String]#>)
    let remoteConfig = HSRemoteConfigConnector(keys: <#T##[String]#>, 
                                                defaults: <#T##[String : NSObject]?#>, 
                                                expirationDuration: <#T##TimeInterval#>)
    let appodeal = HSAppodealConnector()
    let configuration = HSAppConfiguration(attribution: appsFlyer,
                                            productTesting: remoteConfig,
                                            advertising: appodeal
                                            timeout: 30)
    HSApp.configure(configuration: configuration) { error in
        error.map { print($0.localizedDescription) }
        // Initialize Appodeal here
    }
    return true
}
```


## Connectors

### AppsFlyer

Connector for **AppsFlyer** attribution system. After `-[HSApp configureWithConfiguration:completion:]` was called this connector will start `AppsFlyer SDK` and set conversion listeners.

| Parameter | Description |
|---|---|
| devKey | Developer key |
| appId | Application ID |
| keys | Array of keys from conversion data that connector will send to Appodeal. If it is empty, connector will send all conversion data object |

### RemoteConfig

Connector for **Firebase Remote Config** system. After `-[HSApp configureWithConfiguration:completion:]` was called this connector will start `Firebase App` (if it wasn't started) and tries to fetch and activate config.

| Parameter | Description |
|---|---|
| defaults | Default config |
| expirationDuration | Expiration duration for config |
| keys | Array of keys from config that connector will send to Appodeal. If it is empty, connector will send all config object |

### Appodeal

Connector for **Appodeal SDK**. After `-[HSApp configureWithConfiguration:completion:]` was called this connector will just recieve data from attribution and product testing systems. **It will not initialise Appodeal**
