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

- (IBAction)synthesizePurchase:(UIButton *)sender {
    [HSApp validateAndTrackInAppPurchaseWithProductId:@"some product id"
                                                price:@"9.99"
                                             currency:@"USD"
                                        transactionId:@"some transaction id"
                                 additionalParameters:@{}
                                              success:^(NSDictionary *response) {
        NSLog(@"Purchase is valid. Data %@", response.description);
    }
                                              failure:^(NSError *error, id response) {
        NSLog(@"Error while validate purchase.");
    }];
}

- (IBAction)synthesizeEvent:(UIButton *)sender {
    [[Appodeal hs] trackEvent:@"level_started" customParameters:nil];
}

@end
