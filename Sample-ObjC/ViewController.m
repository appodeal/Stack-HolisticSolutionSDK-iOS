//
//  ViewController.m
//  ObjcSample
//
//  Created by artur on 06.05.2020.
//  Copyright © 2020 artur. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@import Appodeal;


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didInitialiseAd)
                                                 name:kAdDidInitializeNotificationName
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didInitialiseAd {
    [Appodeal showAd:AppodealShowStyleBannerTop rootViewController:self];
}

@end
