# iOS Holistic Solution SDK

Describes how AppsFlyer and Firebase Remote Config A/B testing can be used with
Appodeal iOS SDK of version 2.6 and above to send attribution data to Stack Data Core.

## Table of Contents

* [Integration](#integration)
* [Usage](#usage)
  + [Purchases](#purchases)
  + [Events](#events)
* [Services](#services)
  + [AppsFlyer](#appsflyer)
  + [Firebase](#firebase)
  + [Facebook](#facebook)
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
    # pod 'HolisticSolutionSDK/Firebase'
    # pod 'HolisticSolutionSDK/Facebook'
end

target 'App' do
  project 'App.xcodeproj'
  holistic_solution
end

``` 

2. Run `pod install` 

3. If you project doesn't contains swift code, please create new empty swift file in project root.

## Usage

Holistic Solution SDK will initialise AppsFlyer, fetch Firebase Remote Config and sync all required data to Appodeal. There is `HSApp` class to provide described functional. Call configure method with instance of `HSAppConfiguration` will trigger initialisation.

Required parameters for `HSAppConfiguration` is array of **service connecors** and **advertising** service connectors. By default they are AppsFlyer, FirebaseRemoteConfig and Appodeal. **Timeout** in this case is timeout for **one** operation: starting attribution service or fetching remote config. By default the value is **30 sec**.

> **We highly recommend to use all service connectors**

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

``` obj-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // AppsFlyer
    HSAppsFlyerConnector *appsFlyer = [[HSAppsFlyerConnector alloc] initWithDevKey:<#(NSString * _Nonnull)#>
                                                                             appId:<#(NSString * _Nonnull)#>
                                                                              keys:<#(NSArray<NSString *> * _Nonnull)#>];
    // Firebase
    HSFirebaseConnector *firebase = [[HSFirebaseConnector alloc] initWithKeys:<#(NSArray<NSString *> * _Nonnull)#>
                                                                     defaults:<#(NSDictionary<NSString *,NSObject *> * _Nullable)#>
                                                           expirationDuration:<#(NSTimeInterval)#>];
    // Facebook
    HSFacebookConnector *facebook = [[HSFacebookConnector alloc] init];
    // Appodeal 
    HSAppodealConnector *appodeal = [[HSAppodealConnector alloc] init];
    // Configure HSApp
    NSArray <id<HSService>> *services = @[appsFlyer, firebase, facebook];
    HSAppConfiguration *configuration = [[HSAppConfiguration alloc] initWithServices:services 
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
``` swift
func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // AppsFlyer
    let appsFlyer = HSAppsFlyerConnector(devKey: <#T##String#>, 
                                         appId: <#T##String#>,   
                                         keys: <#T##[String]#>)
    // Firebase
    let firebase = HSFirebaseConnector(keys: <#T##[String]#>, 
                                       defaults: <#T##[String : NSObject]?#>, 
                                       expirationDuration: <#T##TimeInterval#>)
    // Facebook
    let facebook = HSFacebookConnector()
    // Appodeal 
    let appodeal = HSAppodealConnector()
    // Configure services
    let services: [HSService] = [appsFlyer, firebase, facebook]
    let configuration = HSAppConfiguration(services: services, 
                                           advertising: appodeal, 
                                           timeout: <#T##TimeInterval#>)
    HSApp.configure(configuration: configuration) { error in
        error.map { print($0.localizedDescription) }
        // Initialize Appodeal here
    }
    return true
}
```

Check that HSApp has been initialized:

*Objective-C*
```obj-c
BOOL inititalised = HSApp.initialised;
```

*Swift*
```swift
let inititalised = HSApp.initialised
```

### Purchases

Holistic solution SDK allows to validate and track in-app purchases by AppsFlyer connector. Data returned in `success` of `failure` blocks are the same to AppsFlyer data. [See docs](https://support.appsflyer.com/hc/en-us/articles/207032066-iOS-SDK-integration-for-developers#core-apis-53-inapp-purchase-validation).

*Objective-C*
``` obj-c
[HSApp validateAndTrackInAppPurchaseWithProductId:<#(NSString * _Nonnull)#> 
                                            price:<#(NSString * _Nonnull)#> 
                                         currency:<#(NSString * _Nonnull)#> 
                                    transactionId:<#(NSString * _Nonnull)#> 
                             additionalParameters:<#(NSDictionary * _Nonnull)#> 
                                          success:<#^(NSDictionary * _Nonnull)success#> 
                                          failure:<#^(NSError * _Nullable, id _Nullable)failure#>];
```

*Swift*
```swift
HSApp.validateAndTrackInAppPurchase(
    productId: <#T##String#>, 
    price: <#T##String#>, 
    currency: <#T##String#>, 
    transactionId: <#T##String#>, 
    additionalParameters: <#T##[AnyHashable : Any]#>, 
    success: <#T##(([AnyHashable : Any]) -> Void)?##(([AnyHashable : Any]) -> Void)?##([AnyHashable : Any]) -> Void#>, 
    failure: <#T##((Error?, Any?) -> Void)?##((Error?, Any?) -> Void)?##(Error?, Any?) -> Void#>
)
```

### Events

Holistic solution SDK allows to send events to Firebase, AppsFlyer and Facebook analytics systems.

*Objective-C*
``` obj-c
[HSApp trackEvent:<#(NSString * _Nonnull)#> 
 customParameters:<#(NSDictionary<NSString *,id> * _Nullable)#>];
```

*Swift*
```swift
HSApp.trackEvent(<#T##eventName: String##String#>, 
                 customParameters: <#T##[String : Any]?#>)
```

## Services
 
There is description of all supported service connectors.

### AppsFlyer

Connector for **AppsFlyer** attribution system. After `-[HSApp configureWithConfiguration:completion:]` was called this connector will start `AppsFlyer SDK` and set conversion listeners.

| Parameter | Description |
|---|---|
| devKey | Developer key |
| appId | Application ID |
| keys | Array of keys from conversion data that connector will send to Appodeal. If it is empty, connector will send all conversion data object |

To get `AppsFlyerTrackerDelegate` set `delegate` property of connector.

*Objective-C*
```obj-c
appsFlyer.delegate = self;
```

*Swift*
```swift
appsFlyer.delegate = self
```

### Firebase

Connector for **Firebase Remote Config** and **Firebase Analytics** system. After `-[HSApp configureWithConfiguration:completion:]` was called this connector will start `Firebase App` (if it wasn't started) and tries to fetch and activate config.

| Parameter | Description |
|---|---|
| defaults | Default config |
| expirationDuration | Expiration duration for config |
| keys | Array of keys from config that connector will send to Appodeal. If it is empty, connector will send all config object |

### Facebook

Connector for **Facebook Analytics** system. Facebook analytics automatic initialisation should be enabled. Also project's `Info.plist` should contains [all required keys](https://developers.facebook.com/docs/app-events/getting-started-app-events-ios#step-5--configure-your-project).


### Appodeal

Connector for **Appodeal SDK**. After `-[HSApp configureWithConfiguration:completion:]` was called this connector will just recieve data from attribution and product testing systems. **It will not initialise Appodeal**
