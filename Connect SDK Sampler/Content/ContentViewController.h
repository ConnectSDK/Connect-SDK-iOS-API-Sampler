//
//  ContentViewController.h
//  Connect SDK Sampler App
//
//  Created by Andrew Longstaff on 9/17/13.
//  Copyright (c) 2014 LG Electronics. All rights reserved.
//

#import <ConnectSDK/ConnectSDK.h>

@interface ContentViewController : UIViewController

@property (nonatomic, assign) ConnectableDevice *device;

- (void) addSubscriptions;
- (void) removeSubscriptions;

@end
