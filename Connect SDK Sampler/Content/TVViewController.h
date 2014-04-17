//
//  TVViewController.h
//  Connect SDK Sampler App
//
//  Created by Andrew Longstaff on 9/18/13.
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

@interface TVViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>

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
