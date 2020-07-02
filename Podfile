platform :ios, '9.0'
workspace 'HolisticSolutionSDK.xcworkspace'

source 'https://cdn.cocoapods.org/'
source 'https://github.com/appodeal/CocoaPods.git'

install! 'cocoapods', :deterministic_uuids => false, :warn_for_multiple_pod_sources => false
use_frameworks!

def appodeal
  pod 'Appodeal', '>= 2.6'
end

def firebase
  pod 'Firebase/Core', '>= 6.20'
  pod 'Firebase/Analytics', '>= 6.20'
  pod 'Firebase/RemoteConfig', '>= 4.4'
end

def appsflyer
  pod 'AppsFlyerFramework', '>= 5.3'
end

def facebook 
  pod 'FBSDKCoreKit', '>= 6.0'
end

def deps
  firebase
  appsflyer
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
