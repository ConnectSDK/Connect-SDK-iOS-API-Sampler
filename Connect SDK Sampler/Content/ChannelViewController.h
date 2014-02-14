//
//  ChannelViewController.h
//  Connect SDK Sampler App
//
//  Created by Andrew Longstaff on 9/18/13.
//  Copyright (c) 2014 LG Electronics. All rights reserved.
//

#import "ContentViewController.h"

@interface ChannelViewController : ContentViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UIStepper *volStepper;
@property (nonatomic, strong) IBOutlet UISlider *volSlider;
@property (nonatomic, strong) IBOutlet UISwitch *muteSwitch;

@property (nonatomic, strong) IBOutlet UIStepper *channelStepper;
@property (nonatomic, strong) IBOutlet UITableView *channels;

@property (weak, nonatomic) IBOutlet UIButton *toastButton;

-(IBAction)volumeStepperChange:(id)sender;
-(IBAction)volumeSliderChange:(id)sender;
-(IBAction)muteSwitchChange:(id)sender;
-(IBAction)channelStepperChange:(id)sender;
- (IBAction)showToast:(id)sender;

@end
