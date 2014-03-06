//
//  MediaViewController.m
//  Connect SDK Sampler App
//
//  Created by Andrew Longstaff on 9/17/13.
//  Copyright (c) 2014 LG Electronics. All rights reserved.
//

#import "MediaViewController.h"

@interface MediaViewController ()

@end

@implementation MediaViewController
{
    LaunchSession *_launchSession;
    id<MediaControl> _mediaControl;
    
    ServiceSubscription *_playStateSubscription;
    ServiceSubscription *_volumeSubscription;

    NSTimeInterval _estimatedMediaPosition;
    NSTimeInterval _mediaDuration;
    NSTimer *_playTimer;
}

#pragma mark - UIViewController creation/destruction methods

- (void) addSubscriptions
{
    if (self.device)
    {
        if ([self.device hasCapability:kMediaPlayerDisplayImage]) [_displayPhotoButton setEnabled:YES];
        if ([self.device hasCapability:kMediaPlayerDisplayVideo]) [_displayVideoButton setEnabled:YES];
    } else
    {
        [self removeSubscriptions];
    }
}

- (void) removeSubscriptions
{
    [self resetMediaControlComponents];
    
    [_displayPhotoButton setEnabled:NO];
    [_displayVideoButton setEnabled:NO];
}

- (void) resetMediaControlComponents
{
    if (_playTimer)
    {
        [_playTimer invalidate];
        _playTimer = nil;
    }

    if (_playStateSubscription)
        [_playStateSubscription unsubscribe];

    if (_volumeSubscription)
        [_volumeSubscription unsubscribe];
    
    _launchSession = nil;
    _mediaControl = nil;

    _estimatedMediaPosition = 0;
    _mediaDuration = 0;
    
    [_closeMediaButton setEnabled:NO];
    
    [_playButton setEnabled:NO];
    [_pauseButton setEnabled:NO];
    [_stopButton setEnabled:NO];
    [_rewindButton setEnabled:NO];
    [_fastForwardButton setEnabled:NO];
    
    _currentTimeLabel.text = @"--:--";
    _durationLabel.text = @"--:--";
    
    [_seekSlider setEnabled:NO];
    [_volumeSlider setEnabled:NO];
    
    [_seekSlider setValue:0 animated:NO];
    [_volumeSlider setValue:0 animated:NO];
}

- (void) enableMediaControlComponents
{
    if ([self.device hasCapability:kMediaControlPlay]) [_playButton setEnabled:YES];
    if ([self.device hasCapability:kMediaControlPause]) [_pauseButton setEnabled:YES];
    if ([self.device hasCapability:kMediaControlStop]) [_stopButton setEnabled:YES];
    if ([self.device hasCapability:kMediaControlRewind]) [_rewindButton setEnabled:YES];
    if ([self.device hasCapability:kMediaControlFastForward]) [_fastForwardButton setEnabled:YES];

    if ([self.device hasCapability:kMediaControlPlayStateSubscribe])
    {
        [_mediaControl subscribePlayStateWithSuccess:^(MediaControlPlayState playState)
        {
            NSLog(@"play state change %@", @(playState));

            if (playState == MediaControlPlayStatePlaying)
            {
                if (_playTimer)
                    [_playTimer invalidate];

                [_mediaControl getDurationWithSuccess:^(NSTimeInterval duration)
                {
                    NSLog(@"duration change %@", @(duration));
                    _mediaDuration = duration;
                } failure:^(NSError *error)
                {
                    NSLog(@"get duration failure: %@", error.localizedDescription);
                }];

                [_mediaControl getPositionWithSuccess:^(NSTimeInterval position)
                {
                    NSLog(@"position change %@", @(position));
                    _estimatedMediaPosition = position;
                } failure:^(NSError *error)
                {
                    NSLog(@"get position failure: %@", error.localizedDescription);
                }];

                if ([self.device hasCapability:kMediaControlDuration] && [self.device hasCapability:kMediaControlSeek])
                    [_seekSlider setEnabled:YES];

                _playTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updatePlayerControls) userInfo:nil repeats:YES];
            } else if (playState == MediaControlPlayStateFinished)
            {
                [self resetMediaControlComponents];
            } else
            {
                if (_playTimer)
                    [_playTimer invalidate];

                [_seekSlider setEnabled:NO];
            }
        } failure:^(NSError *error)
        {
            NSLog(@"subscribe play state failure: %@", error.localizedDescription);
        }];
    }

    if ([self.device hasCapability:kVolumeControlMuteSet]) [_volumeSlider setEnabled:YES];

    if ([self.device hasCapability:kVolumeControlVolumeSubscribe])
    {
        _volumeSubscription = [self.device.volumeControl subscribeVolumeWithSuccess:^(float volume)
        {
            [_volumeSlider setValue:volume];
            [_volumeSlider setEnabled:YES];
            NSLog(@"volume changed to %f", volume);
        } failure:^(NSError *error)
        {
            NSLog(@"Subscribe Vol Error %@", error.localizedDescription);
        }];
    } else if ([self.device hasCapability:kVolumeControlVolumeGet])
    {
        [self.device.volumeControl getVolumeWithSuccess:^(float volume)
        {
            [_volumeSlider setValue:volume];
            NSLog(@"Get vol %f", volume);
        } failure:^(NSError *error)
        {
            NSLog(@"Get Vol Error %@", error.localizedDescription);
        }];
    }
}

- (void) updatePlayerControls
{
    _estimatedMediaPosition += 1;

    if (_mediaDuration <= 0)
        return;

    float progress = (float) (_estimatedMediaPosition / _mediaDuration);

    if (progress > 1.0f)
        return;

    _seekSlider.value = progress;

    [_currentTimeLabel setText:[self stringForTimeInterval:_estimatedMediaPosition]];
    [_durationLabel setText:[self stringForTimeInterval:_mediaDuration]];
}

- (NSString *) stringForTimeInterval:(NSTimeInterval)timeInterval
{
    NSInteger ti = (NSInteger) timeInterval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);

    NSString *time;

    if (hours > 0)
        time = [NSString stringWithFormat:@"%02i:%02i:%02i", hours, minutes, seconds];
    else
        time = [NSString stringWithFormat:@"%02i:%02i", minutes, seconds];

    return time;
}

#pragma mark - Connect SDK API sampler methods

- (IBAction)displayPhoto:(id)sender {
    [self resetMediaControlComponents];
    
    NSURL *mediaURL = [NSURL URLWithString:@"http://demo.idean.com/jeremy-white/cast/media/photo.jpg"];
    NSURL *iconURL = [NSURL URLWithString:@"http://demo.idean.com/jeremy-white/cast/media/photoIcon.jpg"];
    NSString *title = @"Sintel Character Design";
    NSString *description = @"Blender Open Movie Project";
    NSString *mimeType = @"image/jpeg";
    
    [self.device.mediaPlayer displayImage:mediaURL
                                  iconURL:iconURL
                                    title:title
                              description:description
                                 mimeType:mimeType
                                  success:^(LaunchSession *launchSession, id<MediaControl> mediaControl) {
                                      NSLog(@"display photo success");

                                      _launchSession = launchSession;
                                      
                                      if ([self.device hasCapability:kMediaPlayerClose])
                                          [_closeMediaButton setEnabled:YES];
                                  }
                                  failure:^(NSError *error) {
                                      NSLog(@"display photo failure: %@", error.localizedDescription);
                                  }];
}

- (IBAction)displayVideo:(id)sender {
    [self resetMediaControlComponents];
    
    NSURL *mediaURL = [NSURL URLWithString:@"http://demo.idean.com/jeremy-white/cast/media/video.mp4"];
    NSURL *iconURL = [NSURL URLWithString:@"http://demo.idean.com/jeremy-white/cast/media/videoIcon.jpg"];
    NSString *title = @"Sintel Trailer";
    NSString *description = @"Blender Open Movie Project";
    NSString *mimeType = @"video/mp4";
    BOOL shouldLoop = NO;
    
    [self.device.mediaPlayer displayVideo:mediaURL
                                  iconURL:iconURL
                                    title:title
                              description:description
                                 mimeType:mimeType
                               shouldLoop:shouldLoop
                                  success:^(LaunchSession *launchSession, id<MediaControl> mediaControl) {
                                      NSLog(@"display video success");

                                      _launchSession = launchSession;
                                      _mediaControl = mediaControl;
                                      
                                      if ([self.device hasCapability:kMediaPlayerClose])
                                          [_closeMediaButton setEnabled:YES];
                                      
                                      [self enableMediaControlComponents];
                                  }
                                  failure:^(NSError *error) {
                                      NSLog(@"display video failure: %@", error.localizedDescription);
                                  }];
}

- (IBAction)closeMedia:(id)sender
{
    if (!_launchSession)
    {
        [self resetMediaControlComponents];
        return;
    }
    
    [_launchSession closeWithSuccess:^(id responseObject) {
        NSLog(@"close media success");
        [self resetMediaControlComponents];
    } failure:^(NSError *error) {
        NSLog(@"close media failure: %@", error.localizedDescription);
    }];
}

-(void)playClicked:(id)sender
{
    if (!_mediaControl)
    {
        [self resetMediaControlComponents];
        return;
    }
    
    [_mediaControl playWithSuccess:^(id responseObject)
    {
        NSLog(@"play success");
    } failure:^(NSError *error)
    {
        NSLog(@"play failure: %@", error.localizedDescription);
    }];
}

-(void)pauseClicked:(id)sender
{
    if (!_mediaControl)
    {
        [self resetMediaControlComponents];
        return;
    }
    
    [_mediaControl pauseWithSuccess:^(id responseObject)
    {
        NSLog(@"pause success");
    } failure:^(NSError *error)
    {
        NSLog(@"pause failure: %@", error.localizedDescription);
    }];
}

-(void)stopClicked:(id)sender
{
    if (!_mediaControl)
    {
        [self resetMediaControlComponents];
        return;
    }
    
    [_mediaControl stopWithSuccess:^(id responseObject)
    {
        NSLog(@"stop success");
        [self resetMediaControlComponents];
    } failure:^(NSError *error)
    {
        NSLog(@"stop failure: %@", error.localizedDescription);
    }];
}

-(void)rewindClicked:(id)sender
{
    if (!_mediaControl)
    {
        [self resetMediaControlComponents];
        return;
    }
    
    [_mediaControl rewindWithSuccess:^(id responseObject)
    {
        NSLog(@"rewind success");
    } failure:^(NSError *error)
    {
        NSLog(@"rewind failure: %@", error.localizedDescription);
    }];
}

-(void)fastForwardClicked:(id)sender
{
    if (!_mediaControl)
    {
        [self resetMediaControlComponents];
        return;
    }
    
    [_mediaControl fastForwardWithSuccess:^(id responseObject)
    {
        NSLog(@"fast forward success");
    } failure:^(NSError *error)
    {
        NSLog(@"fast forward failure: %@", error.localizedDescription);
    }];
}

- (IBAction)startSeeking:(id)sender
{
    NSLog(@"start seeking");

    if (_playTimer)
        [_playTimer invalidate];
}

- (IBAction)seekChanged:(id)sender
{
    NSTimeInterval time = _seekSlider.value * _mediaDuration;
    NSString *timeString = [self stringForTimeInterval:time];

    _currentTimeLabel.text = timeString;
}

- (IBAction)stopSeeking:(id)sender
{
    if (!_mediaControl)
    {
        [self resetMediaControlComponents];
        return;
    }

    [_seekSlider setEnabled:NO];

    [_mediaControl getDurationWithSuccess:^(NSTimeInterval duration)
    {
        NSTimeInterval newTime = duration * _seekSlider.value;

        [_mediaControl seek:newTime success:^(id responseObject)
        {
            NSLog(@"seek success");

            [_seekSlider setEnabled:YES];
        } failure:^(NSError *error)
        {
            NSLog(@"seek failure: %@", error.localizedDescription);
        }];
    } failure:^(NSError *error)
    {
        NSLog(@"get duration failure: %@", error.localizedDescription);
    }];
}

- (IBAction)volumeChanged:(UISlider *)sender
{
    float vol = [_volumeSlider value];

    [self.device.volumeControl setVolume:vol success:^(id responseObject)
    {
        NSLog(@"Vol Change Success %f", vol);
    } failure:^(NSError *setVolumeError)
    {
        // For devices which don't support setVolume, we'll disable
        // slider and should encourage volume up/down instead

        NSLog(@"Vol Change Error %@", setVolumeError.description);

        sender.enabled = NO;
        sender.userInteractionEnabled = NO;

        [self.device.volumeControl getVolumeWithSuccess:^(float volume)
        {
            NSLog(@"Vol rolled back to actual %f", volume);

            sender.value = volume;
        } failure:^(NSError *getVolumeError)
        {
            NSLog(@"Vol serious error: %@", getVolumeError.localizedDescription);
        }];
    }];
}

@end
