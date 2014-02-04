//
//  MediaViewController.m
//  Connect SDK Sampler App
//
//  Created by Andrew Longstaff on 9/17/13.
//  Copyright (c) 2014 LG Electronics. All rights reserved.
//

#import "MediaViewController.h"

@interface MediaViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation MediaViewController
{
    NSArray *_mediaListArray;

    ServiceSubscription *_channelInfoSubscription;
    ServiceSubscription *_3DSubscription;
}

#pragma mark - UIViewController creation/destruction methods

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    _off = [[UIBarButtonItem alloc] initWithTitle:@"Off" style:UIBarButtonItemStylePlain target:self action:@selector(offClicked:)];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBar.topItem.leftBarButtonItem = _off;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.navigationController.navigationBar.topItem.leftBarButtonItem = nil;
}

- (void) addSubscriptions
{
    if (self.device)
    {
        [_playButton setEnabled:YES];
        [_pauseButton setEnabled:YES];
        [_stopButton setEnabled:YES];
        [_rewindButton setEnabled:YES];
        [_fastForwardButton setEnabled:YES];
        [_off setEnabled:YES];
        [_tv3DButton setEnabled:YES];

        _channelInfoSubscription = [self.device.tvControl subscribeChannelInfoWithSuccess:^(ChannelInfo *channelInfo)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"getChannelInfo success");

                _mediaListArray = @[
                        [NSString stringWithFormat:@"Channel number: %@", channelInfo.number],
                        [NSString stringWithFormat:@"Channel name: %@", channelInfo.name],
                        [NSString stringWithFormat:@"Channel ID: %@", channelInfo.id]
                ];
                [_mediaList reloadData];
            });
        } failure:^(NSError *error)
        {
            NSLog(@"getChannelInfo error: %@", error.localizedDescription);
        }];

        _3DSubscription = [self.device.tvControl subscribe3DEnabledWithSuccess:^(BOOL tv3DEnabled)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                _tv3DButton.selected = tv3DEnabled;
            });
        } failure:^(NSError *error)
        {
            NSLog(@"Subscribe to 3D mode error: %@", error.localizedDescription);
        }];
    } else
    {
        [self removeSubscriptions];
    }
}

- (void) removeSubscriptions
{
    if (_channelInfoSubscription)
        [_channelInfoSubscription unsubscribe];

    if (_3DSubscription)
        [_3DSubscription unsubscribe];

    [_playButton setEnabled:NO];
    [_pauseButton setEnabled:NO];
    [_stopButton setEnabled:NO];
    [_rewindButton setEnabled:NO];
    [_fastForwardButton setEnabled:NO];
    [_off setEnabled:NO];
    [_tv3DButton setEnabled:NO];

    dispatch_async(dispatch_get_main_queue(), ^{
        _mediaListArray = nil;
        [_mediaList reloadData];
    });
}

#pragma mark - Remote Control methods

-(void)playClicked:(id)sender
{
    [self.device.mediaControl playWithSuccess:^(id responseObject)
    {
        NSLog(@"play success");
    } failure:^(NSError *error)
    {
        NSLog(@"play failure: %@", error.localizedDescription);
    }];
}

-(void)pauseClicked:(id)sender
{
    [self.device.mediaControl pauseWithSuccess:^(id responseObject)
    {
        NSLog(@"pause success");
    } failure:^(NSError *error)
    {
        NSLog(@"pause failure: %@", error.localizedDescription);
    }];
}

-(void)stopClicked:(id)sender
{
    [self.device.mediaControl stopWithSuccess:^(id responseObject)
    {
        NSLog(@"stop success");
    } failure:^(NSError *error)
    {
        NSLog(@"stop failure: %@", error.localizedDescription);
    }];
}

-(void)rewindClicked:(id)sender
{
    [self.device.mediaControl rewindWithSuccess:^(id responseObject)
    {
        NSLog(@"rewind success");
    } failure:^(NSError *error)
    {
        NSLog(@"rewind failure: %@", error.localizedDescription);
    }];
}

-(void)fastForwardClicked:(id)sender
{
    [self.device.mediaControl fastForwardWithSuccess:^(id responseObject)
    {
        NSLog(@"fast forward success");
    } failure:^(NSError *error)
    {
        NSLog(@"fast forward failure: %@", error.localizedDescription);
    }];
}

-(void) offClicked:(id)sender
{
    [self.device.powerControl powerOffWithSuccess:^(id responseObject)
    {
        NSLog(@"power off success");
    } failure:^(NSError *error)
    {
        NSLog(@"power off failure: %@", error.localizedDescription);
    }];
}

- (IBAction)tv3D:(id)sender
{
    BOOL enabled = !self.tv3DButton.selected;

    [self.device.tvControl set3DEnabled:enabled success:^(id responseObject)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            self.tv3DButton.selected = enabled;
        });
    } failure:^(NSError *error)
    {
        NSLog(@"set 3D failure: %@", error.localizedDescription);
    }];
}

#pragma mark - Media UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_mediaListArray)
        return _mediaListArray.count;
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ConnectSDKSamplerMediaChooser";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    cell.textLabel.text = [_mediaListArray objectAtIndex:(NSUInteger) indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"key: clicked %@", [_mediaListArray objectAtIndex:(NSUInteger) indexPath.row]);
}

@end
