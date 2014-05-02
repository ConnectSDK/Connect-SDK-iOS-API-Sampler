//
//  BaseViewController.m
//  Connect SDK Sampler App
//
//  Created by Andrew Longstaff on 9/17/13.
//  Connect SDK Sample App by LG Electronics
//
//  To the extent possible under law, the person who associated CC0 with
//  this sample app has waived all copyright and related or neighboring rights
//  to the sample app.
//
//  You should have received a copy of the CC0 legalcode along with this
//  work. If not, see http://creativecommons.org/publicdomain/zero/1.0/.
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void) appDidBecomeActive:(NSNotification *)notification
{
    [self viewDidAppear:NO];
}

- (void) appDidEnterBackground:(NSNotification *)notification { /* to be overridden */ }

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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
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
