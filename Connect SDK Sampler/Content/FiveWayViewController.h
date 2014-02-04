//
//  FiveWayViewController.h
//  Connect SDK Sampler App
//
//  Created by Andrew Longstaff on 9/19/13.
//  Copyright (c) 2014 LG Electronics. All rights reserved.
//

#import "ContentViewController.h"∂
#import "TouchpadView.h"

@interface FiveWayViewController : ContentViewController<UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIButton *homeButton;
@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic, strong) IBOutlet UIButton *clickButton;
@property (nonatomic, strong) IBOutlet UIButton *leftButton;
@property (nonatomic, strong) IBOutlet UIButton *rightButton;
@property (nonatomic, strong) IBOutlet UIButton *upButton;
@property (nonatomic, strong) IBOutlet UIButton *downButton;

@property (nonatomic, strong) IBOutlet UITextField *keyboard;
@property (nonatomic, strong) IBOutlet TouchpadView *touchpad;

-(IBAction)homeClicked:(id)sender;
-(IBAction)backClicked:(id)sender;
-(IBAction)clickClicked:(id)sender;

-(IBAction)leftDown:(id)sender;
-(IBAction)rightDown:(id)sender;
-(IBAction)upDown:(id)sender;
-(IBAction)downDown:(id)sender;
-(IBAction)buttonUp:(id)sender;

-(IBAction)keyboardEnterText:(id)sender;

@end
