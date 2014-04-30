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

@end
