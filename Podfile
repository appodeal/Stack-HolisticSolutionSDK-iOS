platform :ios, '10.0'
workspace 'HolisticSolutionSDK.xcworkspace'

source 'https://cdn.cocoapods.org/'
source 'https://github.com/appodeal/CocoaPods.git'

install! 'cocoapods', 
  :deterministic_uuids => false, 
  :warn_for_multiple_pod_sources => false
  
use_frameworks!

def appodeal
  pod 'Appodeal', '2.11.1'
  pod 'StackIAB', '1.5.2'
  pod 'APDAdColonyAdapter', '2.11.1.1'
  pod 'APDAmazonAdsAdapter', '2.11.1.1'
  pod 'APDAppLovinAdapter', '2.11.1.1'
  pod 'APDBidMachineAdapter', '2.11.1.1' # Required
  pod 'APDFacebookAudienceAdapter', '2.11.1.1'
  pod 'APDGoogleAdMobAdapter', '2.11.1.1'
  pod 'APDIronSourceAdapter', '2.11.1.1'
  pod 'APDMyTargetAdapter', '2.11.1.1'
  pod 'APDOguryAdapter', '2.11.1.1'
  pod 'APDUnityAdapter', '2.11.1.1'
  pod 'APDVungleAdapter', '2.11.1.1'
  pod 'APDYandexAdapter', '2.11.1.1'
  pod 'StackConsentManager', '1.1.2'
end

def firebase
  pod 'Firebase/Core', '8.11.0'
  pod 'Firebase/Analytics', '8.11.0'
  pod 'Firebase/RemoteConfig', '8.11.0'
end

def appsflyer
  pod 'AppsFlyerFramework', '6.5.1'
end

def facebook 
  pod 'FBSDKCoreKit', '12.3.0'
end

def adjust
  pod 'Adjust', '4.29.6'
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

target 'HolisticSolutionSDKTests' do
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


post_install do |installer|
  project = installer.pods_project
  project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'YES'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
    end
  end
end
