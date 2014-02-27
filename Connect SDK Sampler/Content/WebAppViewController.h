//
//  WebAppViewController.h
//  Connect SDK Sampler
//
//  Created by Jeremy White on 2/26/14.
//  Copyright (c) 2014 LGE. All rights reserved.
//

#import "ContentViewController.h"

@interface WebAppViewController : ContentViewController

@property (weak, nonatomic) IBOutlet UIButton *launchButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *sendJSONButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (weak, nonatomic) IBOutlet UITextView *statusTextView;

- (IBAction)launchWebApp:(id)sender;
- (IBAction)sendMessage:(id)sender;
- (IBAction)closeWebApp:(id)sender;

@end
