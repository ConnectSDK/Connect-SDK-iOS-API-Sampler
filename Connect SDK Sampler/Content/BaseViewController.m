//
//  ContentViewController.m
//  Connect SDK Sampler App
//
//  Created by Andrew Longstaff on 9/17/13.
//  Copyright (c) 2014 LG Electronics. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController
{
    BOOL _initialViewing;
    BOOL _hasSubscriptions;
}

@synthesize device = _device;

#pragma mark - UIView setup/destruct

- (void) commonInit
{
    _initialViewing = YES;
    _hasSubscriptions = NO;
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
    
    if (self.device == nil || _initialViewing)
    {
        [self removeSubscriptions];
        _initialViewing = NO;
    }
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
    if (_device || _initialViewing)
    {
        [self removeSubscriptions];
        _device = nil;
        _initialViewing = NO;
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
