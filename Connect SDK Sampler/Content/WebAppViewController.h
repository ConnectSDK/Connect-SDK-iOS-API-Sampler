//
//  WebAppViewController.h
//  Connect SDK Sampler
//
//  Created by Jeremy White on 2/26/14.
//  Connect SDK Sample App by LG Electronics
//
//  To the extent possible under law, the person who associated CC0 with
//  this sample app has waived all copyright and related or neighboring rights
//  to the sample app.
//
//  You should have received a copy of the CC0 legalcode along with this
//  work. If not, see http://creativecommons.org/publicdomain/zero/1.0/.
//

#import "BaseViewController.h"

@interface WebAppViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIButton *launchButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *sendJSONButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (weak, nonatomic) IBOutlet UITextView *statusTextView;

- (IBAction)launchWebApp:(id)sender;
- (IBAction)sendMessage:(id)sender;
- (IBAction)closeWebApp:(id)sender;

@end
