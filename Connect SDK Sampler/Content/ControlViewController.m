//
//  FiveWayViewController.m
//  Connect SDK Sampler App
//
//  Created by Andrew Longstaff on 9/19/13.
//  Copyright (c) 2014 LG Electronics. All rights reserved.
//

#import "ControlViewController.h"

typedef enum
{
    FivewayKeyUp = 0,
    FivewayKeyDown,
    FivewayKeyLeft,
    FivewayKeyRight,
} FivewayKey;

#define FIVEWAY_DELAY 0.2

@interface ControlViewController ()

@end

@implementation ControlViewController{
    NSTimer *_timer;

    ServiceSubscription *_keyboardSubscription;
}

- (void)addSubscriptions
{
    if (self.device)
    {
        if ([self.device hasCapability:kKeyboardControlSubscribe])
        {
            _keyboardSubscription = [self.device.keyboardControl subscribeKeyboardStatusWithSuccess:^(KeyboardInfo *info)
            {
                NSLog(@"keyboard status changed: visible:%@ type:%@", @(info.isVisible), @(info.keyboardType));

                if (info.isVisible)
                    [self getKeyboardFocusWithType:info.keyboardType];
                else
                    [self resignKeyboardFocus];
            } failure:^(NSError *error)
            {
                NSLog(@"keyboard subscription error %@", error.localizedDescription);
            }];
        } else
        {
            if ([self.device hasCapability:kKeyboardControlSend])
                [_keyboardButton setEnabled:YES];
        }

        if ([self.device hasCapability:kMouseControlConnect])
        {
            [self.device.mouseControl connectMouseWithSuccess:^(id responseObject)
            {
                NSLog(@"mouse connection success");

                _touchpad.mouseControl = self.device.mouseControl;
                _touchpad.userInteractionEnabled = YES;
            } failure:^(NSError *error)
            {
                NSLog(@"mouse connection error %@", error.localizedDescription);
            }];
        }

        if ([self.device hasCapability:kFivewayControlUp]) [_upButton setEnabled:YES];
        if ([self.device hasCapability:kFivewayControlDown]) [_downButton setEnabled:YES];
        if ([self.device hasCapability:kFivewayControlLeft]) [_leftButton setEnabled:YES];
        if ([self.device hasCapability:kFivewayControlRight]) [_rightButton setEnabled:YES];
        if ([self.device hasCapability:kFivewayControlOK]) [_clickButton setEnabled:YES];
        if ([self.device hasCapability:kFivewayControlHome]) [_homeButton setEnabled:YES];
        if ([self.device hasCapability:kFivewayControlBack]) [_backButton setEnabled:YES];
    } else
    {
        [self removeSubscriptions];
    }
}

- (void)removeSubscriptions
{
    if (_keyboardSubscription)
        [_keyboardSubscription unsubscribe];

    [self.device.mouseControl disconnectMouse];

    _touchpad.userInteractionEnabled = NO;

    [_upButton setEnabled:NO];
    [_downButton setEnabled:NO];
    [_leftButton setEnabled:NO];
    [_rightButton setEnabled:NO];
    [_clickButton setEnabled:NO];
    [_homeButton setEnabled:NO];
    [_backButton setEnabled:NO];

    [_keyboardButton setEnabled:NO];
}

#pragma mark - Connect SDK API sampler methods

- (void)clickClicked:(id)sender
{
    [self.device.fivewayControl okWithSuccess:nil failure:nil];
}

- (void)homeClicked:(id)sender
{
    [self.device.fivewayControl homeWithSuccess:nil failure:nil];
}

- (void)backClicked:(id)sender
{
    [self.device.fivewayControl backWithSuccess:nil failure:nil];
}

- (void)upDown:(id)sender
{
    [self.device.fivewayControl upWithSuccess:nil failure:nil];

    if(_timer != nil)
        [_timer invalidate];

    _timer = [NSTimer scheduledTimerWithTimeInterval:FIVEWAY_DELAY target:self selector:@selector(hButtonHold) userInfo:@{@"keyCode":@(FivewayKeyUp)} repeats:YES];
}

- (void)downDown:(id)sender
{
    [self.device.fivewayControl downWithSuccess:nil failure:nil];

    if(_timer != nil)
        [_timer invalidate];

    _timer = [NSTimer scheduledTimerWithTimeInterval:FIVEWAY_DELAY target:self selector:@selector(hButtonHold) userInfo:@{@"keyCode":@(FivewayKeyDown)} repeats:YES];
}

- (void)leftDown:(id)sender
{
    [self.device.fivewayControl leftWithSuccess:nil failure:nil];

    if(_timer != nil)
        [_timer invalidate];

    _timer = [NSTimer scheduledTimerWithTimeInterval:FIVEWAY_DELAY target:self selector:@selector(hButtonHold) userInfo:@{@"keyCode":@(FivewayKeyLeft)} repeats:YES];
}

- (void)rightDown:(id)sender
{
    [self.device.fivewayControl rightWithSuccess:nil failure:nil];

    if(_timer != nil)
        [_timer invalidate];

    _timer = [NSTimer scheduledTimerWithTimeInterval:FIVEWAY_DELAY target:self selector:@selector(hButtonHold) userInfo:@{@"keyCode":@(FivewayKeyRight)} repeats:YES];
}

- (void)buttonUp:(id)sender
{
    [_timer invalidate];
    _timer = nil;
}

- (IBAction)toggleKeyboard:(id)sender
{
    if ([_keyboard isFirstResponder])
        [self resignKeyboardFocus];
    else
        [self getKeyboardFocusWithType:UIKeyboardTypeDefault];
}

#pragma mark - Mouse methods
- (void) hButtonHold
{
    NSNumber *buttonKeyCode = [[_timer userInfo] objectForKey:@"keyCode"];
    int buttonKey = [buttonKeyCode intValue];

    switch (buttonKey)
    {
        case FivewayKeyUp: [self.device.fivewayControl upWithSuccess:nil failure:nil]; break;
        case FivewayKeyDown: [self.device.fivewayControl downWithSuccess:nil failure:nil]; break;
        case FivewayKeyLeft: [self.device.fivewayControl leftWithSuccess:nil failure:nil]; break;
        case FivewayKeyRight: [self.device.fivewayControl rightWithSuccess:nil failure:nil]; break;
        default:break;
    }
}

#pragma mark - Keyboard & UITextField methods

-(void) getKeyboardFocusWithType:(UIKeyboardType)type
{
    [_keyboard setKeyboardType:type];
    [_keyboard becomeFirstResponder];
}

-(void) resignKeyboardFocus
{
    [_keyboard resignFirstResponder];
}

-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    [textField setText:@"*"];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.device hasCapability:kKeyboardControlSendEnter])
        [self.device.keyboardControl sendEnterWithSuccess:nil failure:nil];

    if (![self.device hasCapability:kKeyboardControlSubscribe])
        [self resignKeyboardFocus];

    return NO;
}

-(void) keyboardEnterText:(id)sender
{
    NSString *newString = [_keyboard text];

    if ([newString length] == 0)
    {
        NSLog(@"Received delete key code");

        if ([self.device hasCapability:kKeyboardControlSendDelete])
            [self.device.keyboardControl sendDeleteWithSuccess:nil failure:nil];
    } else
    {
        NSString *stringToSend = [newString substringToIndex:1];

        NSLog(@"Received string to send: %@", stringToSend);

        if ([self.device hasCapability:kKeyboardControlSend])
            [self.device.keyboardControl send:stringToSend success:nil failure:nil];
    }

    [_keyboard setText:@"*"];
}

@end
