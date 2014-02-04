//
//  MediaViewController.h
//  Connect SDK Sampler App
//
//  Created by Andrew Longstaff on 9/17/13.
//  Copyright (c) 2014 LG Electronics. All rights reserved.
//

#import "ContentViewController.h"

@interface MediaViewController : ContentViewController

@property (nonatomic, strong) UIBarButtonItem *off;
@property (nonatomic, strong) IBOutlet UIButton *playButton;
@property (nonatomic, strong) IBOutlet UIButton *pauseButton;
@property (nonatomic, strong) IBOutlet UIButton *stopButton;
@property (nonatomic, strong) IBOutlet UIButton *rewindButton;
@property (nonatomic, strong) IBOutlet UIButton *fastForwardButton;
@property (nonatomic, strong) IBOutlet UITableView *mediaList;
@property (weak, nonatomic) IBOutlet UIButton *tv3DButton;

-(IBAction)playClicked:(id)sender;
-(IBAction)pauseClicked:(id)sender;
-(IBAction)stopClicked:(id)sender;
-(IBAction)rewindClicked:(id)sender;
-(IBAction)fastForwardClicked:(id)sender;
-(void) offClicked:(id)sender;
- (IBAction)tv3D:(id)sender;

@end
