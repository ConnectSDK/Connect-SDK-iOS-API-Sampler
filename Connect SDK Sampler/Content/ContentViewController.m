//
//  ContentViewController.m
//  Connect SDK Sampler App
//
//  Created by Andrew Longstaff on 9/17/13.
//  Copyright (c) 2014 LG Electronics. All rights reserved.
//

#import "ContentViewController.h"

@interface ContentViewController ()

@end

@implementation ContentViewController
{
    BOOL hasSubscriptions;
}

@synthesize device = _device;

#pragma mark - UIView setup/destruct

- (void) commonInit
{
    hasSubscriptions = NO;
}

- (id) init
{
    self = [super init];
    
    if (self)
    {
        [self commonInit];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self commonInit];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void) appDidBecomeActive:(NSNotification *)notification
{
    [self viewDidAppear:NO];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.device == nil)
        [self removeSubscriptions];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self removeSubscriptions];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void) dealloc
{
    NSLog(@"dealloc");
    
    [self removeSubscriptions];
}

#pragma mark - Device setup

- (void) setDevice:(ConnectableDevice *)device
{
    if (_device)
    {
        [self removeSubscriptions];
        _device = nil;
    }
    
    if (device)
    {
        _device = device;
        [self addSubscriptions];
    }
}

#pragma mark - Custom functionality to be overridden

- (void) addSubscriptions { NSLog(@"This should be overridden"); }
- (void) removeSubscriptions { NSLog(@"This should be overridden"); }

@end
