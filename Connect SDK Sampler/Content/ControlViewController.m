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
        _keyboardSubscription = [self.device.keyboardControl subscribeKeyboardStatusWithSuccess:^(KeyboardInfo *info)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                if (info.isVisible)
                    [self getKeyboardFocusWithType:info.keyboardType];
                else
                    [self resignKeyboardFocus];
            });
        } failure:^(NSError *error)
        {
            NSLog(@"keyboard subscription error %@", error.localizedDescription);
        }];

        [self.device.mouseControl connectMouseWithSuccess:^(id responseObject)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [self setupControls];
            });
        } failure:nil];
    } else
    {
        [self removeSubscriptions];
    }
}

- (void)setupControls
{
    _touchpad.mouseControl = self.device.mouseControl;

    [_leftButton setEnabled:YES];
    [_rightButton setEnabled:YES];
    [_upButton setEnabled:YES];
    [_downButton setEnabled:YES];
    [_clickButton setEnabled:YES];
    [_homeButton setEnabled:YES];
    [_backButton setEnabled:YES];
}

- (void)removeSubscriptions
{
    [_keyboardSubscription unsubscribe];
    [self.device.mouseControl disconnectMouse];

    [_leftButton setEnabled:NO];
    [_rightButton setEnabled:NO];
    [_upButton setEnabled:NO];
    [_downButton setEnabled:NO];
    [_clickButton setEnabled:NO];
    [_homeButton setEnabled:NO];
    [_backButton setEnabled:NO];
}

#pragma mark - Actions

- (void)homeClicked:(id)sender
{
    [self.device.fivewayControl homeWithSuccess:nil failure:nil];
}

- (void)backClicked:(id)sender
{
    [self.device.fivewayControl backWithSuccess:nil failure:nil];
}

- (void)clickClicked:(id)sender
{
    [self.device.fivewayControl okWithSuccess:nil failure:nil];
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

- (void)buttonUp:(id)sender
{
    [_timer invalidate];
    _timer = nil;
}

- (IBAction)toggleKeyboard:(id)sender {
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

-(void) textFieldDidBeginEditing:(UITextField *)textField{
    [textField setText:@"*"];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (self.device.keyboardControl)
        [self.device.keyboardControl sendEnterWithSuccess:nil failure:nil];

    return NO;
}

-(void) keyboardEnterText:(id)sender{
    NSString *newString = [_keyboard text];
    NSLog(@"String %@", newString);
    if([newString length] == 0){
        if(self.device.keyboardControl)
            [self.device.keyboardControl sendDeleteWithSuccess:nil failure:nil];
    }
    else{
        if(self.device.keyboardControl)
            [self.device.keyboardControl send:[newString substringFromIndex:1] success:nil failure:nil];
    }
    [_keyboard setText:@"*"];
}

@end
