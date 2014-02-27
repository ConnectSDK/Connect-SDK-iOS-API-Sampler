//
//  SamplerViewController.m
//  Connect SDK Sampler App
//
//  Created by Andrew Longstaff on 9/9/13.
//  Copyright (c) 2014 LG Electronics. All rights reserved.
//

#import "SamplerViewController.h"
#import "BaseViewController.h"

@interface SamplerViewController ()

@end

@implementation SamplerViewController{
    DiscoveryManager *_discoveryManager;
    DevicePicker *_devicePicker;
    ConnectableDevice *_device;

    UIBarButtonItem *_connectToggleItem;
    UILabel *_disabledMessage;
    
    BOOL showSplashMessage;
}

#pragma mark - UIView setup/destruct methods

-(void) viewDidLoad
{
    self.title = @"Connect SDK Sampler";

    _discoveryManager = [DiscoveryManager sharedManager];
    _discoveryManager.pairingLevel = ConnectableDevicePairingLevelOn;
    [_discoveryManager startDiscovery];

    self.delegate = self;
    
    _connectToggleItem = [[UIBarButtonItem alloc] initWithTitle:@"Connect" style:UIBarButtonItemStylePlain target:self action:@selector(hConnect:)];
    self.navigationItem.rightBarButtonItem = _connectToggleItem;
    
    showSplashMessage = YES;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (showSplashMessage)
    {
        [self disableViewWithMessage:@"Connect to a device to begin"];
        showSplashMessage = NO;
    }
}

- (void) enableView
{
    self.view.userInteractionEnabled = YES;
    _connectToggleItem.title = @"Connected";
    
    if (_disabledMessage == nil)
        return;
    
    [_disabledMessage removeFromSuperview];
    _disabledMessage = nil;
    
    UIViewController *visibleViewController = [self visibleViewController];
    
    if ([visibleViewController isKindOfClass:[BaseViewController class]])
    {
        BaseViewController *contentViewController = (BaseViewController *) self.selectedViewController;
        contentViewController.device = _device;
    }
}

- (void) disableViewWithMessage:(NSString *)message
{
    UIViewController *visibleViewController = [self visibleViewController];
    
    if ([visibleViewController isKindOfClass:[BaseViewController class]])
    {
        BaseViewController *contentViewController = (BaseViewController *) self.selectedViewController;
        contentViewController.device = nil;
    }

    if (_disabledMessage)
    {
        [_disabledMessage removeFromSuperview];
        _disabledMessage = nil;
    }
    
    self.view.userInteractionEnabled = NO;
    _connectToggleItem.title = @"Connect";

    UIViewController *viewController = [self visibleViewController];
    
    _disabledMessage = [[UILabel alloc] initWithFrame:viewController.view.bounds];
    _disabledMessage.textColor = [UIColor whiteColor];
    _disabledMessage.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.75f];
    _disabledMessage.textAlignment = NSTextAlignmentCenter;
    _disabledMessage.text = message;
    
    [self.view addSubview:_disabledMessage];
}

- (UIViewController *) visibleViewController
{
    // TODO: cover case where we come back to More view controller
    
    UIViewController *viewController;
    
    if ([self.selectedViewController isKindOfClass:[BaseViewController class]])
        viewController = self.selectedViewController;
    else if (self.selectedViewController == self.tabBarController.moreNavigationController)
        viewController = self.tabBarController.moreNavigationController.visibleViewController;
    else
        viewController = self.tabBarController.selectedViewController;
    
    return viewController;
}

#pragma mark - UITabBarDelegate methods

-(void) tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[BaseViewController class]])
    {
        BaseViewController *contentViewController = (BaseViewController*)viewController;
        contentViewController.device = _device;
        
        if (self.navigationController.navigationBarHidden)
            [self.navigationController setNavigationBarHidden:NO animated:YES];
    } else
    {
        if ([viewController isKindOfClass:[UINavigationController class]])
            ((UINavigationController *)viewController).delegate = self;
        
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController isKindOfClass:[BaseViewController class]])
    {
        BaseViewController *contentViewController = (BaseViewController*)viewController;
        contentViewController.device = _device;
    }
}

#pragma mark - Actions

- (void) hConnect:(id)sender
{
    if (_device)
        [_device disconnect];
    else
        [self findDevice];
}

#pragma mark - Device Discovery

-(void)findDevice
{
    [_discoveryManager startDiscovery];

    if (_devicePicker == nil)
    {
        _devicePicker = [_discoveryManager devicePicker];
        _devicePicker.delegate = self;
    }

    _devicePicker.currentDevice = _device;
    [_devicePicker showPicker:nil];
}

#pragma mark - DevicePickerDelegate methods

- (void)devicePicker:(DevicePicker *)picker didSelectDevice:(ConnectableDevice *)device
{
    _device = device;
    _device.delegate = self;
    [_device connect];
}

#pragma mark - ConnectableDeviceDelegate

- (void) connectableDeviceReady:(ConnectableDevice *)device
{
    [self enableView];
}

- (void) connectableDeviceDisconnected:(ConnectableDevice *)device withError:(NSError *)error
{
    _device.delegate = nil;
    _device = nil;

    if (error)
        [self disableViewWithMessage:error.localizedDescription];
    else
        [self disableViewWithMessage:@"Device has become disconnected."];
}

@end
