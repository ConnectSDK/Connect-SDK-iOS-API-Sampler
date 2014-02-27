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
    
    ServiceSubscription *_playPositionSubscription;
    ServiceSubscription *_muteSubscription;
    ServiceSubscription *_volumeSubscription;
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
    if (_playPositionSubscription)
        [_playPositionSubscription unsubscribe];
    
    if (_muteSubscription)
        [_muteSubscription unsubscribe];
    
    if (_volumeSubscription)
        [_volumeSubscription unsubscribe];
    
    _launchSession = nil;
    _mediaControl = nil;
    
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
    
    if ([self.device hasCapability:kMediaControlPositionSubscribe])
    {
        [_mediaControl subscribePositionWithSuccess:^(NSTimeInterval position) {
            // TODO: implement position
        } failure:^(NSError *error) {
            NSLog(@"subscribe position failure: %@", error.localizedDescription);
        }];
    }
    
    // TODO: subscribe to volume
    
    // TODO: subscribe to mute
}

#pragma mark - Connect SDK API sampler methods

- (IBAction)displayPhoto:(id)sender {
    [self resetMediaControlComponents];
    
    NSURL *mediaURL = [NSURL URLWithString:@"http://www.freesoftwaremagazine.com/files/nodes/3466/fig_sintel_style_study.jpg"];
    NSURL *iconURL = [NSURL URLWithString:@"http://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn1/t5/s48x48/50354_121158371242322_7687_q.jpg"];
    NSString *title = @"Sintel Character Design";
    NSString *description = @"Blender Open Movie Project";
    NSString *mimeType = @"image/jpeg";
    
    [self.device.mediaPlayer displayImage:mediaURL
                                  iconURL:iconURL
                                    title:title
                              description:description
                                 mimeType:mimeType
                                  success:^(LaunchSession *launchSession, id<MediaControl> mediaControl) {
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
    
    NSURL *mediaURL = [NSURL URLWithString:@"http://download.blender.org/durian/trailer/sintel_trailer-720p.mp4"];
    NSURL *iconURL = [NSURL URLWithString:@"http://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn1/t5/s48x48/50354_121158371242322_7687_q.jpg"];
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

- (IBAction)seekChanged:(id)sender
{
    if (!_mediaControl)
    {
        [self resetMediaControlComponents];
        return;
    }
    
    // TODO: implement seek
}

- (IBAction)volumeChanged:(id)sender
{
    // TODO: implement volume/mute etc
}

@end
