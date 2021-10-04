Pod::Spec.new do |spec|
  spec.name         = "HolisticSolutionSDK"
  spec.version      = "2.0.2"
  spec.summary      = "The HolisticSolutionSDK provides easy to use API for integration attribution, product testing and advertising platform."
  spec.description  = <<-DESC
  The Holistic Solution SDK is iOS framework. It provides easy to use API for integration attribution, product testing and advertising platform.
  It contains AppsFlyer, Firebase Remote Config, Appodeal connectors. The framework allows to send all data to Stack Holistic Solution service without 
  additional synchronisation code.
                   DESC
  spec.homepage     = "https://explorestack.com"
  spec.license      = { :type => "GPLv3", :file => "LICENSE" }
  spec.author       = { "appodeal" => "https://appodeal.com" }
  spec.platform     = :ios, "10.0"

  spec.source       = { :git => "https://github.com/appodeal/Stack-HolisticSolutionSDK-iOS.git", :tag => "v#{spec.version}" }

  spec.requires_arc = true
  spec.static_framework = true
  spec.swift_versions = "4.0", "4.2", "5.0", "5.1", "5.2"
  spec.default_subspecs = "Full"

  spec.pod_target_xcconfig = { 
    "VALID_ARCHS": "arm64 armv7 armv7s x86_64",
    "VALID_ARCHS[sdk=iphoneos*]": "arm64 armv7 armv7s",
    "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
  }

  spec.user_target_xcconfig = { 
    "VALID_ARCHS": "arm64 armv7 armv7s x86_64",
    "VALID_ARCHS[sdk=iphoneos*]": "arm64 armv7 armv7s",
    "VALID_ARCHS[sdk=iphonesimulator*]": "x86_64"
  }

  spec.subspec "Core" do |ss|
  	ss.source_files = "HolisticSolutionSDK/**/*.{h,swift}"
    ss.dependency "Appodeal", "2.10.3-Beta"
    ss.dependency "StackIAB", "1.4.4"
    ss.dependency "StackConsentManager", "1.1.2"

  	ss.exclude_files = 
  		"HolisticSolutionSDK/AppsFlyer",
      "HolisticSolutionSDK/Adjust",
  		"HolisticSolutionSDK/Firebase",
      "HolisticSolutionSDK/Facebook"
  end

  spec.subspec "AdNetworks" do |ss|
    ss.dependency 'APDAdColonyAdapter', '2.10.3.1-Beta' 
    ss.dependency 'APDAmazonAdsAdapter', '2.10.3.1-Beta' 
    ss.dependency 'APDAppLovinAdapter', '2.10.3.1-Beta' 
    ss.dependency 'APDBidMachineAdapter', '2.10.3.1-Beta' # Required
    ss.dependency 'APDFacebookAudienceAdapter', '2.10.3.1-Beta' 
    ss.dependency 'APDGoogleAdMobAdapter', '2.10.3.1-Beta' 
    ss.dependency 'APDIronSourceAdapter', '2.10.3.1-Beta' 
    ss.dependency 'APDMyTargetAdapter', '2.10.3.1-Beta' 
    ss.dependency 'APDOguryAdapter', '2.10.3.1-Beta' 
    ss.dependency 'APDSmaatoAdapter', '2.10.3.1-Beta' 
    ss.dependency 'APDStartAppAdapter', '2.10.3.1-Beta' 
    ss.dependency 'APDUnityAdapter', '2.10.3.1-Beta' 
    ss.dependency 'APDVungleAdapter', '2.10.3.1-Beta' 
    ss.dependency 'APDYandexAdapter', '2.10.3.1-Beta' 
  end
  
  spec.subspec "Adjust" do |ss|
    ss.source_files = "HolisticSolutionSDK/Adjust"
    ss.dependency "HolisticSolutionSDK/Core"
    ss.dependency "Adjust", "4.29.6"
    ss.dependency "AdjustPurchase", "1.0.0"
  end

  spec.subspec "AppsFlyer" do |ss|
    ss.source_files = "HolisticSolutionSDK/AppsFlyer"
    ss.dependency "HolisticSolutionSDK/Core"
    ss.dependency "AppsFlyerFramework", "6.4.0"
  end

  spec.subspec "Firebase" do |ss|
    ss.source_files = "HolisticSolutionSDK/Firebase"
    ss.dependency "HolisticSolutionSDK/Core"
    ss.dependency "Firebase/Core", "8.8.0"
    ss.dependency "Firebase/Analytics", "8.8.0"
  	ss.dependency "Firebase/RemoteConfig", "8.8.0"
  end

  spec.subspec "Facebook" do |ss|
    ss.source_files = "HolisticSolutionSDK/Facebook"
    ss.dependency "HolisticSolutionSDK/Core"
    ss.dependency "FBSDKCoreKit", "11.2.1"
  end

  spec.subspec "Full" do |ss| 
  	ss.dependency "HolisticSolutionSDK/Core"
    ss.dependency "HolisticSolutionSDK/AdNetworks"
  	ss.dependency "HolisticSolutionSDK/Adjust"
  	ss.dependency "HolisticSolutionSDK/AppsFlyer"
  	ss.dependency "HolisticSolutionSDK/Firebase"
    ss.dependency "HolisticSolutionSDK/Facebook"
  end
end
