//
//  TVViewController.m
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

#import "TVViewController.h"

@interface TVViewController ()

@end

@implementation TVViewController
{
    NSArray *_channelList;
    ChannelInfo *_currentChannel;
    
    ServiceSubscription *_3DSubscription;
    ServiceSubscription *_channelInfoSubscription;
}

- (void) addSubscriptions
{
    NSLog(@"ChannelViewController::addSubscriptions with tv %@", self.device);
    
    if (self.device)
    {
        if ([self.device hasCapabilities:@[kTVControlChannelUp, kTVControlChannelDown]])
            [_channelStepper setEnabled:YES];
        
        if ([self.device hasCapability:kTVControl3DSet]) [_display3DButton setEnabled:YES];
        
        if ([self.device hasCapability:kTVControl3DSubscribe])
        {
            _3DSubscription = [self.device.tvControl subscribe3DEnabledWithSuccess:^(BOOL tv3DEnabled)
                               {
                                   NSLog(@"3D mode changed");
                                   _display3DButton.selected = tv3DEnabled;
                               } failure:^(NSError *error)
                               {
                                   NSLog(@"Subscribe to 3D mode error: %@", error.localizedDescription);
                               }];
        } else if ([self.device hasCapability:kTVControl3DSet])
        {
            [self.device.tvControl get3DEnabledWithSuccess:^(BOOL tv3DEnabled) {
                _display3DButton.selected = tv3DEnabled;
            } failure:^(NSError *error) {
                NSLog(@"Get 3D mode error: %@", error.localizedDescription);
            }];
        }
        
        if ([self.device hasCapability:kPowerControlOff]) [_powerOffButton setEnabled:YES];
        
        _channelList = [[NSArray alloc] init];
        
        if ([self.device hasCapability:kTVControlChannelList])
        {
            [self.device.tvControl getChannelListWithSuccess:^(NSArray *channelList)
             {
                 NSLog(@"Get channel list success");
                 
                 _channelList = channelList;
                 [self reloadData];
             } failure:^(NSError *error)
             {
                 NSLog(@"Get ch list Error %@", error.localizedDescription);
             }];
        }
        
        if ([self.device hasCapability:kTVControlChannelSubscribe])
        {
            _channelInfoSubscription = [self.device.tvControl subscribeCurrentChannelWithSuccess:^(ChannelInfo *channelInfo)
            {
                NSLog(@"subscribe current channel success");
                _currentChannel = channelInfo;
                [self.channels reloadData];
            }                                                                            failure:^(NSError *error)
            {
                NSLog(@"Subscribe current ch Error %@", error.localizedDescription);
            }];
        }
        
        if ([self.device hasCapability:kMediaControlPause]) [_incomingCallButton setEnabled:YES];
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
    
    [_incomingCallButton setEnabled:NO];
    [_powerOffButton setEnabled:NO];
    [_display3DButton setEnabled:NO];
    
    [_channelStepper setValue:10];
    [_channelStepper setEnabled:NO];
    
    _channelList = [[NSArray alloc] init];
    [self reloadData];
}

#pragma mark - Connect SDK API sampler methods

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

- (IBAction)incomingCall:(id)sender
{
    if (_incomingCallButton.selected)
    {
        if ([self.device hasCapabilities:@[kMediaControlPlay, kMediaControlPause]])
            [self.device.mediaControl playWithSuccess:nil failure:nil];
        
        if ([self.device hasCapability:kVolumeControlMuteSet])
            [self.device.volumeControl setMute:NO success:nil failure:nil];
        
        if ([self.device hasCapability:kToastControlShowToast])
            [self.device.toastControl showToast:@"Ended call with Jeremy White" iconData:[self callIconData] iconExtension:@"jpeg" success:nil failure:nil];
    } else
    {
        if ([self.device hasCapabilities:@[kMediaControlPlay, kMediaControlPause]])
            [self.device.mediaControl pauseWithSuccess:nil failure:nil];
        
        if ([self.device hasCapability:kVolumeControlMuteSet])
            [self.device.volumeControl setMute:YES success:nil failure:nil];
        
        if ([self.device hasCapability:kToastControlShowToast])
            [self.device.toastControl showToast:@"Incoming call from Jeremy White" iconData:[self callIconData] iconExtension:@"jpeg" success:nil failure:nil];
    }
    
    _incomingCallButton.selected = !_incomingCallButton.selected;
}

- (IBAction)powerOff:(id)sender
{
    [self.device.powerControl powerOffWithSuccess:^(id responseObject) {
        NSLog(@"power off success");
    } failure:^(NSError *error) {
        NSLog(@"power off failure: %@", error.localizedDescription);
    }];
}

- (IBAction)display3D:(id)sender
{
    BOOL enabled = !_display3DButton.selected;
    
    [self.device.tvControl set3DEnabled:enabled success:^(id responseObject)
     {
         NSLog(@"set 3D success:");
         _display3DButton.selected = enabled;
     } failure:^(NSError *error)
     {
         NSLog(@"set 3D failure: %@", error.localizedDescription);
     }];
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

        _currentChannel = channelInfo;
        [self reloadData];
    } failure:^(NSError *error)
    {
        NSLog(@"Set Ch Error %@", error.description);
    }];
}

#pragma mark - Incoming call icon data

- (NSString *) callIconData
{
    return @"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";
}

@end
