//
//  ServiceInfo.m
//  Sample-ObjC
//
//  Created by Stas Kochkin on 08.05.2020.
//  Copyright © 2020 com.appodeal. All rights reserved.
//

#import "ServicesInfo.h"


@interface ServicesInfo ()

@property (nonatomic, copy, readwrite) NSString *appodealApiKey;

@end

@implementation ServicesInfo

+ (instancetype)sharedInfo {
    static ServicesInfo *_sharedInfo;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInfo = [[ServicesInfo alloc] init];
    });
    return _sharedInfo;
}

- (instancetype)init {
    if (self = [super init]) {
        [self populateFromServiceInfoPlist];
    }
    return self;
}
 
- (void)populateFromServiceInfoPlist {
    NSString *path = [NSBundle.mainBundle pathForResource:@"Services-Info" ofType:@"plist"];
    NSData *xml = [NSFileManager.defaultManager contentsAtPath:path];
    NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:xml
                                                                    options:NSPropertyListMutableContainersAndLeaves
                                                                     format:nil
                                                                      error:nil];
    self.appodealApiKey = plist[@"Appodeal"][@"ApiKey"];
}

@end
