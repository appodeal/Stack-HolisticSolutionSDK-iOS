# iOS Holistic Solution SDK

Describes how AppsFlyer and Firebase Remote Config A/B testing can be used with
Appodeal iOS SDK of version 2.6 and above to send attribution data to Stack Data Core.

## Table of Contents

* [Integration](#integration)
* [Usage](#usage)
  + [Purchases](#purchases)
  + [Events](#events)

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
    # pod 'HolisticSolutionSDK/AppsFlyer'
    # pod 'HolisticSolutionSDK/Adjust'
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

Holistic Solution SDK will synchronize consent status (GDRP, CCPA, ATT), initialise Adjsut, AppsFlyer, fetch Firebase Remote Config and sync all required data to Appodeal. After this HS SDK will initialize Appodeal. There is `HSApp` class to provide described functional. Call configure method with instance of `HSAppConfiguration` will trigger initialisation.

Required parameters for `HSAppConfiguration` is array of **service connecors** and **advertising** service connectors. By default they are AppsFlyer, FirebaseRemoteConfig and Appodeal. **Timeout** in this case is timeout for **one** operation: starting attribution service or fetching remote config. By default the value is **30 sec**.

> **We highly recommend to use all service connectors**

1. Import SDK umbrella header or module into your `AppDelegate` file. 

*Objective-C*

```obj-c
#import <HolisticSolutionSDK/HolisticSolutionSDK.h>
#import <Appodeal/Appodeal.h>
```

*Swift*
```swift
import HolisticSolutionSDK
import Appodeal
```

2. Add folowing code at application did finish launching event.

*Objective-C*

``` obj-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     [Appodeal.hs registerWithConnectors:@[
        HSFirebaseConnector.class,
        HSFacebookConnector.class,
        HSAppsFlyerConnector.class,
        HSAdjustConnector.class
    ]];
    
    HSAppConfiguration *configuration = [[HSAppConfiguration alloc] initWithAppKey:<#(NSString * _Nonnull)#>
                                                                           timeout:<#(NSTimeInterval)#>
                                                                             debug:<#(enum HSAppConfigurationDebug)#> 
                                                                           adTypes:<#(AppodealAdType)#>];
    
    [Appodeal.hs initializeWithApplication:application
                             launchOptions:launchOptions
                             configuration:configuration
                                completion:^(NSError *error) {
        // Holistic solution initialization completed 
    }];
    return YES;
}
```

*Swift*
``` swift
func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
    let connectors: [Service.Type] = [
        AppsFlyerConnector.self,
        AdjustConnector.self,
        FirebaseConnector.self,
        FacebookConnector.self
    ]
        
    let configuration: AppConfiguration = .init(
        appKey: <#T##String#>,
        timeout: <#T##TimeInterval#>,
        debug: <#T##AppConfiguration.Debug#>,
        adTypes: <#T##AppodealAdType#>
    )
        
    Appodeal.hs.register(connectors: connectors)
    Appodeal.hs.initialize(
        application: application,
        launchOptions: launchOptions,
        configuration: configuration
    ) { _ in
        // Holistic solution initialization completed 
    }

    return true
}
```

### Purchases

Holistic solution SDK allows to validate and track in-app purchases by AppsFlyer or Adjust connector. Bloks `success` of `failure` indicates result of validation.

*Objective-C*
``` obj-c
[Appodeal.hs validateAndTrackInAppPurchaseWithProductId:<#(NSString * _Nonnull)#>
                                                       type:<#(enum HSPurchaseType)#>
                                                      price:<#(NSString * _Nonnull)#>
                                                   currency:<#(NSString * _Nonnull)#>
                                              transactionId:<#(NSString * _Nonnull)#>
                                       additionalParameters:<#(NSDictionary<NSString *,id> * _Nonnull)#>
                                                    success:<#^(NSDictionary * _Nonnull)success#>
                                                    failure:<#^(NSError * _Nullable, id _Nullable)failure#>];
```

*Swift*
```swift
Appodeal.hs.validateAndTrackInAppPurchase(
    productId: <#T##String#>,
    type: <#T##PurchaseType#>,
    price: <#T##String#>,
    currency: <#T##String#>,
    transactionId: <#T##String#>,
    additionalParameters: <#T##[String : Any]#>,
    success: <#T##(([AnyHashable : Any]) -> Void)?##(([AnyHashable : Any]) -> Void)?##([AnyHashable : Any]) -> Void#>,
    failure: <#T##((Error?, Any?) -> Void)?##((Error?, Any?) -> Void)?##(Error?, Any?) -> Void#>
)
```

### Events

Holistic solution SDK allows to send events to Firebase, AppsFlyer, Adjust and Facebook analytics systems.

*Objective-C*
``` obj-c
[Appodeal.hs trackEvent:<#(NSString * _Nonnull)#> customParameters:<#(NSDictionary<NSString *,id> * _Nullable)#>];
```

*Swift*
```swift
Appodeal.hs.trackEvent(<#T##eventName: String##String#>, customParameters: <#T##[String : Any]?#>)
```