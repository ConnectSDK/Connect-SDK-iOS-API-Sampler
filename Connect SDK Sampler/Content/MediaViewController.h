//
//  MediaViewController.h
//  Connect SDK Sampler App
//
//  Created by Andrew Longstaff on 9/17/13.
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

@interface MediaViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIButton *displayPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *displayVideoButton;
@property (weak, nonatomic) IBOutlet UIButton *playAudioButton;
@property (weak, nonatomic) IBOutlet UIButton *closeMediaButton;

- (IBAction)displayPhoto:(id)sender;
- (IBAction)displayVideo:(id)sender;
- (IBAction)playAudio:(id)sender;
- (IBAction)closeMedia:(id)sender;

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

@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UISlider *seekSlider;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UILabel *mediaTitle;
@property (weak, nonatomic) IBOutlet UILabel *artistName;

@property (weak, nonatomic) IBOutlet UIImageView *mediaIcon;

- (IBAction)startSeeking:(id)sender;
- (IBAction)seekChanged:(id)sender;
- (IBAction)stopSeeking:(id)sender;
- (IBAction)volumeChanged:(id)sender;

@end
