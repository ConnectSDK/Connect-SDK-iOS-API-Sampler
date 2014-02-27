//
//  MediaViewController.h
//  Connect SDK Sampler App
//
//  Created by Andrew Longstaff on 9/17/13.
//  Copyright (c) 2014 LG Electronics. All rights reserved.
//

#import "ContentViewController.h"

@interface MediaViewController : ContentViewController

@property (weak, nonatomic) IBOutlet UIButton *displayPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *displayVideoButton;
@property (weak, nonatomic) IBOutlet UIButton *closeMediaButton;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *rewindButton;
@property (weak, nonatomic) IBOutlet UIButton *fastForwardButton;

- (IBAction)displayPhoto:(id)sender;
- (IBAction)displayVideo:(id)sender;
- (IBAction)closeMedia:(id)sender;

-(IBAction)playClicked:(id)sender;
-(IBAction)pauseClicked:(id)sender;
-(IBAction)stopClicked:(id)sender;
-(IBAction)rewindClicked:(id)sender;
-(IBAction)fastForwardClicked:(id)sender;

@end
