//
//  InputViewController.h
//  Connect SDK Sampler App
//
//  Created by Andrew Longstaff on 9/18/13.
//  Copyright (c) 2014 LG Electronics. All rights reserved.
//

#import "ContentViewController.h"

@interface InputViewController : ContentViewController<UITabBarDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView *inputs;

@property (weak, nonatomic) IBOutlet UIButton *launchPickerButton;
@property (weak, nonatomic) IBOutlet UIButton *closePickerButton;

- (IBAction)launchPicker:(id)sender;
- (IBAction)closePicker:(id)sender;

@end
