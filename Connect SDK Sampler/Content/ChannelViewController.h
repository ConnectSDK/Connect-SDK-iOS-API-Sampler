//
//  ChannelViewController.h
//  Connect SDK Sampler App
//
//  Created by Andrew Longstaff on 9/18/13.
//  Copyright (c) 2014 LG Electronics. All rights reserved.
//

#import "ContentViewController.h"

@interface ChannelViewController : ContentViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *incomingCallButton;
@property (weak, nonatomic) IBOutlet UIButton *powerOffButton;
@property (weak, nonatomic) IBOutlet UIButton *display3DButton;

- (IBAction)incomingCall:(id)sender;
- (IBAction)powerOff:(id)sender;
- (IBAction)display3D:(id)sender;

@property (weak, nonatomic) IBOutlet UIStepper *channelStepper;
@property (weak, nonatomic) IBOutlet UITableView *channels;

-(IBAction)channelStepperChange:(id)sender;

@end
