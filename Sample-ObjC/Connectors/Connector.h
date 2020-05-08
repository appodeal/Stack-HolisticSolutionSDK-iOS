//
//  Connector.h
//  ObjcSample
//
//  Created by artur on 07.05.2020.
//  Copyright © 2020 artur. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol Connector <NSObject>

typedef void (^Completion)(void);

- (void)inititalise:(Completion)completion;

@end


