platform :ios, '9.0'
workspace 'Sample.xcworkspace'

source 'https://cdn.cocoapods.org/'
source 'https://github.com/appodeal/CocoaPods.git'

install! 'cocoapods', :deterministic_uuids => false, :warn_for_multiple_pod_sources => false
use_frameworks!

def appodeal
  pod 'Appodeal', '>= 2.6.0'
# Uncomment followed adapters
  # pod 'APDAdColonyAdapter', '2.6.3.1' 
  # pod 'APDAmazonAdsAdapter', '2.6.3.1' 
  # pod 'APDAppLovinAdapter', '2.6.3.2' 
  # pod 'APDAppodealAdExchangeAdapter', '2.6.3.1' 
  # pod 'APDChartboostAdapter', '2.6.3.1' 
  # pod 'APDFacebookAudienceAdapter', '2.6.3.2' 
  # pod 'APDGoogleAdMobAdapter', '2.6.3.1' 
  # pod 'APDInMobiAdapter', '2.6.3.1' 
  # pod 'APDInnerActiveAdapter', '2.6.3.1' 
  # pod 'APDIronSourceAdapter', '2.6.3.1' 
  # pod 'APDMintegralAdapter', '2.6.3.1' 
  # pod 'APDMyTargetAdapter', '2.6.3.2' 
  # pod 'APDOguryAdapter', '2.6.3.2' 
  # pod 'APDOpenXAdapter', '2.6.3.1' 
  # pod 'APDPubnativeAdapter', '2.6.3.1' 
  # pod 'APDSmaatoAdapter', '2.6.3.1' 
  # pod 'APDStartAppAdapter', '2.6.3.3' 
  # pod 'APDTapjoyAdapter', '2.6.3.1' 
  # pod 'APDUnityAdapter', '2.6.3.1' 
  # pod 'APDVungleAdapter', '2.6.3.1' 
  # pod 'APDYandexAdapter', '2.6.3.1' 
end

def firebase
  pod 'Firebase/Analytics'
  pod 'Firebase/RemoteConfig'
end

def appsflyer
  pod 'AppsFlyerFramework'
end

def deps
  firebase
  appsflyer
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
