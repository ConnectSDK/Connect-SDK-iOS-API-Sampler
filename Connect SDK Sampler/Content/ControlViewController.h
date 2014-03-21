//
//  ControlViewController.h
//  Connect SDK Sampler App
//
//  Created by Andrew Longstaff on 9/19/13.
//  Copyright (c) 2014 LG Electronics. All rights reserved.
//

#import "BaseViewController.h"
#import "ControlTouchpadView.h"

@interface ControlViewController : BaseViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *clickButton;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UIButton *upButton;
@property (weak, nonatomic) IBOutlet UIButton *downButton;
@property (weak, nonatomic) IBOutlet UIButton *keyboardButton;

@property (weak, nonatomic) IBOutlet UITextField *keyboard;
@property (weak, nonatomic) IBOutlet ControlTouchpadView *touchpad;

-(IBAction)homeClicked:(id)sender;
-(IBAction)backClicked:(id)sender;
-(IBAction)clickClicked:(id)sender;

-(IBAction)upDown:(id)sender;
-(IBAction)downDown:(id)sender;
-(IBAction)leftDown:(id)sender;
-(IBAction)rightDown:(id)sender;
-(IBAction)buttonUp:(id)sender;

- (IBAction)toggleKeyboard:(id)sender;
-(IBAction)keyboardEnterText:(id)sender;

@end
