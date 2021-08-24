platform :ios, '10.0'
workspace 'HolisticSolutionSDK.xcworkspace'

source 'https://cdn.cocoapods.org/'
source 'https://github.com/appodeal/CocoaPods.git'

install! 'cocoapods', :deterministic_uuids => false, :warn_for_multiple_pod_sources => false
use_frameworks!

def appodeal
  pod 'Appodeal', '2.10.2'
  pod 'APDAdColonyAdapter', '2.10.2.1' 
  pod 'APDAmazonAdsAdapter', '2.10.2.1' 
  pod 'APDAppLovinAdapter', '2.10.2.1' 
  pod 'APDBidMachineAdapter', '2.10.2.2'
  pod 'APDFacebookAudienceAdapter', '2.10.2.1' 
  pod 'APDGoogleAdMobAdapter', '2.10.2.2' 
  pod 'APDIronSourceAdapter', '2.10.2.2' 
  pod 'APDMyTargetAdapter', '2.10.2.1' 
  pod 'APDOguryAdapter', '2.10.2.1' 
  pod 'APDSmaatoAdapter', '2.10.2.1' 
  pod 'APDStartAppAdapter', '2.10.2.2' 
  pod 'APDUnityAdapter', '2.10.2.1' 
  pod 'APDVungleAdapter', '2.10.2.2' 
  pod 'APDYandexAdapter', '2.10.2.2' 
  pod 'StackConsentManager', '1.1.2'
end

def firebase
  pod 'Firebase/Core', '8.6.0'
  pod 'Firebase/Analytics', '8.6.0'
  pod 'Firebase/RemoteConfig', '8.6.0'
end

def appsflyer
  pod 'AppsFlyerFramework', '6.3.5'
end

def facebook 
  pod 'FBSDKCoreKit', '11.1.0'
end

def adjust
  pod 'Adjust', '4.29.5'
  pod 'AdjustPurchase', :git => 'https://github.com/adjust/ios_purchase_sdk', :tag => 'v1.0.0'
end

def deps
  firebase
  appsflyer
  adjust
  facebook
  appodeal
end


target 'HolisticSolutionSDK' do
  project 'HolisticSolutionSDK.xcodeproj'
  deps
end

target 'Sample-Swift' do
  project 'Sample-Swift.xcodeproj'
	deps
end

target 'Sample-ObjC' do
  project 'Sample-ObjC.xcodeproj'
	deps
end
