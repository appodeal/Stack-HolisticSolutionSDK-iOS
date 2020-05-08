//
//  ServiceInfo.h
//  Sample-ObjC
//
//  Created by Stas Kochkin on 08.05.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ServicesInfo : NSObject

@property (nonatomic, copy, readonly) NSString *appodealApiKey;
@property (nonatomic, copy, readonly) NSString *appsFlyerDevId;
@property (nonatomic, copy, readonly) NSString *appsFlyerAppId;

+ (instancetype)sharedInfo;

@end

NS_ASSUME_NONNULL_END
