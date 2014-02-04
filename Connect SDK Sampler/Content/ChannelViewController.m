//
//  ChannelViewController.m
//  Connect SDK Sampler App
//
//  Created by Andrew Longstaff on 9/18/13.
//  Copyright (c) 2014 LG Electronics. All rights reserved.
//

#import "ChannelViewController.h"

@interface ChannelViewController ()

@end

@implementation ChannelViewController
{
    NSArray *_channelList;
    ChannelInfo *_currentChannel;

    ServiceSubscription *_muteSubscription;
    ServiceSubscription *_volumeSubscription;
    ServiceSubscription *_channelInfoSubscription;
}

- (void) addSubscriptions
{
    NSLog(@"ChannelViewController::addSubscriptions with tv %@", self.device);
    
    if (self.device)
    {
        [_volStepper setEnabled:YES];
        [_volSlider setEnabled:YES];
        [_channelStepper setEnabled:YES];
        
        _channelList = [[NSArray alloc] init];
        
        _volumeSubscription = [self.device.volumeControl subscribeVolumeWithSuccess:^(float volume)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_volSlider setValue:volume];
                NSLog(@"Get vol %f", volume);
            });
        } failure:^(NSError *error)
        {
            NSLog(@"Get Vol Error %@", error.localizedDescription);
        }];

        _muteSubscription = [self.device.volumeControl subscribeMuteWithSuccess:^(BOOL mute)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_muteSwitch setOn:mute];
                [_muteSwitch setEnabled:YES];
            });
        } failure:^(NSError *subscribeError)
        {
            NSLog(@"Subscribe mute Error %@", subscribeError.localizedDescription);

            [self.device.volumeControl getMuteWithSuccess:^(BOOL mute)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_muteSwitch setOn:mute];
                    [_muteSwitch setEnabled:YES];
                });
            } failure:^(NSError *getError)
            {
                NSLog(@"Get mute Error %@", getError.localizedDescription);

                dispatch_async(dispatch_get_main_queue(), ^{
                    [_muteSwitch setEnabled:NO];
                });
            }];
        }];

        _channelInfoSubscription = [self.device.tvControl subscribeChannelInfoWithSuccess:^(ChannelInfo *channelInfo)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                _currentChannel = channelInfo;
                [self.channels reloadData];
            });
        } failure:^(NSError *error)
        {
            NSLog(@"Subscribe current ch Error %@", error.localizedDescription);
        }];

        [self.device.tvControl getChannelListWithSuccess:^(NSArray *channelList)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                _channelList = channelList;
                [self reloadData];
            });
        } failure:^(NSError *error)
        {
            NSLog(@"Get ch Error %@", error.localizedDescription);
        }];
    } else
    {
        [self removeSubscriptions];
    }
}

- (void) removeSubscriptions
{
    if (_volumeSubscription)
        [_volumeSubscription unsubscribe];

    if (_muteSubscription)
        [_muteSubscription unsubscribe];

    if (_channelInfoSubscription)
        [_channelInfoSubscription unsubscribe];

    [_volStepper setEnabled:NO];
    [_volSlider setEnabled:NO];
    [_volStepper setValue:10];
    [_muteSwitch setEnabled:NO];
    [_channelStepper setValue:10];
    [_channelStepper setEnabled:NO];
    
    _channelList = [[NSArray alloc] init];
    [self reloadData];
}

#pragma mark - Remote control methods

-(void)volumeStepperChange:(id)sender
{
    NSLog(@"Volume change requested");

    if ([_volStepper value] > 10)
    {
        [self.device.volumeControl volumeUpWithSuccess:^(id responseObject)
        {
            NSLog(@"Vol Up Success");
        } failure:^(NSError *err)
        {
            NSLog(@"Vol Up Error %@", err.description);
        }];
    } else if ([_volStepper value] < 10)
    {
        [self.device.volumeControl volumeDownWithSuccess:^(id responseObject)
        {
            NSLog(@"Vol down Success");
        } failure:^(NSError *err)
        {
            NSLog(@"Vol down Error %@", err.description);
        }];
    }

    [_volStepper setValue:10];
}

-(void) volumeSliderChange:(UISlider *)sender
{
    float vol = [_volSlider value];

    [self.device.volumeControl setVolume:vol success:^(id responseObject)
    {
        NSLog(@"Vol Change Success %f", vol);
    } failure:^(NSError *setVolumeError)
    {
        // For devices which don't support setVolume, we'll disable
        // slider and should encourage volume up/down instead

        NSLog(@"Vol Change Error %@", setVolumeError.description);

        dispatch_async(dispatch_get_main_queue(), ^{
            sender.enabled = NO;
            sender.userInteractionEnabled = NO;
        });

        [self.device.volumeControl getVolumeWithSuccess:^(float volume)
        {
            NSLog(@"Vol rolled back to actual %f", volume);

            dispatch_async(dispatch_get_main_queue(), ^{
                sender.value = volume;
            });
        } failure:^(NSError *getVolumeError)
        {
            NSLog(@"Vol serious error: %@", getVolumeError.localizedDescription);
        }];
    }];
}

-(void)muteSwitchChange:(id)sender
{
    BOOL muteOn = [_muteSwitch isOn];
    _muteSwitch.enabled = NO;

    [self.device.volumeControl setMute:muteOn success:^(id responseObject)
    {
        NSLog(@"Mute Success");
        dispatch_async(dispatch_get_main_queue(), ^{
            _muteSwitch.enabled = YES;
        });
    } failure:^(NSError *err)
    {
        NSLog(@"Mute Error %@", err.description);
    }];
}

-(void)channelStepperChange:(id)sender{
    if ([_channelStepper value] > 10)
    {
        [self.device.tvControl channelUpWithSuccess:^(id responseObject)
        {
            NSLog(@"Ch Up Success");
        } failure:^(NSError *error)
        {
            NSLog(@"Ch Up Error %@", error.description);
        }];
    } else if ([_channelStepper value] < 10)
    {
        [self.device.tvControl channelDownWithSuccess:^(id responseObject)
        {
            NSLog(@"Ch Down Success");
        } failure:^(NSError *error)
        {
            NSLog(@"Ch Down Error %@", error.description);
        }];
    }

    [_channelStepper setValue:10];
}

#pragma mark - Channel list UITableView methods

- (void) reloadData
{
    NSSortDescriptor *majorNumberSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"majorNumber" ascending:YES];
    NSSortDescriptor *minorNumberSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"minorNumber" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:majorNumberSortDescriptor, minorNumberSortDescriptor, nil];
    _channelList = [_channelList sortedArrayUsingDescriptors:sortDescriptors];
    
    [_channels reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = [_channelList count];
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ConnectSDKChannelChooser";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    ChannelInfo *channelInfo = [_channelList objectAtIndex:(NSUInteger) indexPath.row];

    cell.textLabel.text = channelInfo.number;
    cell.detailTextLabel.text = channelInfo.name;

    if ([channelInfo isEqual:_currentChannel])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ChannelInfo *channelInfo = (ChannelInfo *) [_channelList objectAtIndex:(NSUInteger) indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.device.tvControl setChannel:channelInfo success:^(id responseObject)
    {
        NSLog(@"Set ch pass");

        dispatch_async(dispatch_get_main_queue(), ^{
            _currentChannel = channelInfo;
            [self reloadData];
        });
    } failure:^(NSError *error)
    {
        NSLog(@"Set Ch Error %@", error.description);
    }];
}

@end
