//
//  AppViewController.h
//  Connect SDK Sampler App
//
//  Created by Andrew Longstaff on 9/17/13.
//  Copyright (c) 2014 LG Electronics. All rights reserved.
//

#import "ContentViewController.h"

@interface AppViewController : ContentViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *apps;
@property (nonatomic, strong) IBOutlet UIButton *browserButton;
@property (nonatomic, strong) IBOutlet UIButton *simpleImageButton;
@property (nonatomic, strong) IBOutlet UIButton *simpleVideoButton;
@property (weak, nonatomic) IBOutlet UIButton *netflixButton;
@property (weak, nonatomic) IBOutlet UIButton *huluButton;
@property (weak, nonatomic) IBOutlet UIButton *youtubeButton;

- (IBAction)browserPressed:(id)sender;
- (IBAction)simpleImagePressed:(id)sender;
- (IBAction)simpleVideoPressed:(id)sender;
- (IBAction)netflixPressed:(id)sender;
- (IBAction)huluPressed:(id)sender;
- (IBAction)youtubePressed:(id)sender;

@end
