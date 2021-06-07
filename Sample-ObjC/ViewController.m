//
//  ViewController.m
//  ObjcSample
//
//  Created by artur on 06.05.2020.
//  Copyright © 2020 artur. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

#import <HolisticSolutionSDK/HolisticSolutionSDK.h>
#import <Appodeal/Appodeal.h>

@interface ViewController ()

@end

@implementation ViewController

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didInitialiseAd)
                                                     name:kAdDidInitializeNotificationName
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didInitialiseAd {
    [Appodeal showAd:AppodealShowStyleBannerBottom rootViewController:self];
}

@end
