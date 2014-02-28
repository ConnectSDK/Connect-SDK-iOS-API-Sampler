//
//  InputViewController.h
//  Connect SDK Sampler App
//
//  Created by Andrew Longstaff on 9/18/13.
//  Copyright (c) 2014 LG Electronics. All rights reserved.
//

#import "BaseViewController.h"

@interface SystemViewController : BaseViewController<UITabBarDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIStepper *volumeStepper;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UISwitch *muteSwitch;

-(IBAction)volumeStepperChange:(id)sender;
-(IBAction)volumeSliderChange:(id)sender;
-(IBAction)muteSwitchChange:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *rewindButton;
@property (weak, nonatomic) IBOutlet UIButton *fastForwardButton;

-(IBAction)playClicked:(id)sender;
-(IBAction)pauseClicked:(id)sender;
-(IBAction)stopClicked:(id)sender;
-(IBAction)rewindClicked:(id)sender;
-(IBAction)fastForwardClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *inputs;

@property (weak, nonatomic) IBOutlet UIButton *launchPickerButton;
@property (weak, nonatomic) IBOutlet UIButton *closePickerButton;

- (IBAction)launchPicker:(id)sender;
- (IBAction)closePicker:(id)sender;

@end
