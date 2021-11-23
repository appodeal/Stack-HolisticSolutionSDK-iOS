#!/bin/sh


SCHEME="AdjustPurchase"
VERSION="1.0.1"

start=`date +%s`
# ----------------------------------
# CLEAR TEMPORARY AND RELEASE PATHS
# ----------------------------------
function prepare {
    rm -rf "./build"
    rm -rf "./release"
}

# ----------------------------------
# BUILD PLATFORM SPECIFIC FRAMEWORKS
# ----------------------------------
function xcframework {
    scheme="$1"
    # iOS devices
    xcodebuild archive \
        -workspace "HolisticSolutionSDK.xcworkspace" \
        -scheme "$scheme" \
        -archivePath "./build/ios.xcarchive" \
        -sdk iphoneos \
        GCC_GENERATE_DEBUGGING_SYMBOLS=NO \
        STRIP_INSTALLED_PRODUCT=YES \
        LINK_FRAMEWORKS_AUTOMATICALLY=NO \
		OTHER_CFLAGS="-fembed-bitcode -Qunused-arguments" \
		ONLY_ACTIVE_ARCH=NO \
		DEPLOYMENT_POSTPROCESSING=YES \
		MACH_O_TYPE=staticlib \
		IPHONEOS_DEPLOYMENT_TARGET=9.0 \
		DEBUG_INFORMATION_FORMAT="dwarf" \
        SKIP_INSTALL=NO | xcpretty

    # iOS simulator
    xcodebuild archive \
        -workspace "HolisticSolutionSDK.xcworkspace" \
        -scheme "$scheme" \
        -archivePath "./build/ios_sim.xcarchive" \
        -sdk iphonesimulator \
        GCC_GENERATE_DEBUGGING_SYMBOLS=NO \
        STRIP_INSTALLED_PRODUCT=YES \
        LINK_FRAMEWORKS_AUTOMATICALLY=NO \
		OTHER_CFLAGS="-fembed-bitcode -Qunused-arguments" \
		ONLY_ACTIVE_ARCH=NO \
		DEPLOYMENT_POSTPROCESSING=YES \
		MACH_O_TYPE=staticlib \
		IPHONEOS_DEPLOYMENT_TARGET=9.0 \
		DEBUG_INFORMATION_FORMAT="dwarf" \
        SKIP_INSTALL=NO | xcpretty

    # -------------------
    # PACKAGE XCFRAMEWORK
    # -------------------

    xcodebuild -create-xcframework \
        -framework "./build/ios.xcarchive/Products/Library/Frameworks/$scheme.framework" \
        -framework "./build/ios_sim.xcarchive/Products/Library/Frameworks/$scheme.framework" \
        -output "./release/$scheme.xcframework"
}

# ----------------------------------
# COMPRESS
# ----------------------------------
function compress {
    cd "./release"
    xcframeworks+=( "$SCHEME.xcframework" )
    zip -r "$SCHEME.zip" "${xcframeworks[@]}"
    cd -
}

# ----------------------------------
# UPLOAD TO AWS S3
# ----------------------------------
function upload {
    aws s3 cp "$(PWD)/release/$SCHEME.zip" "s3://appodeal-ios/$SCHEME/$VERSION/$SCHEME.zip" --acl public-read
}

function checksum {
    name="$1.xcframework.zip"
    swift package compute-checksum "$(PWD)/release/$name"
}

prepare
xcframework "$SCHEME"

cp LICENSE './release'
compress
upload

end=`date +%s`
runtime=$((end-start))
echo "🚀 Build finished at: $runtime seconds"