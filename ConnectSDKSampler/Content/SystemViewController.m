//
//  SystemViewController.m
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

#import "SystemViewController.h"

@interface SystemViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation SystemViewController
{
    NSArray *_inputList;
    LaunchSession *_inputPickerSession;
    
    ServiceSubscription *_muteSubscription;
    ServiceSubscription *_volumeSubscription;
}

- (void)addSubscriptions
{
    if (self.device)
    {
        if ([self.device hasCapability:kVolumeControlVolumeUpDown])
            [_volumeStepper setEnabled:YES];
        
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
        
        if ([self.device hasCapability:kVolumeControlMuteSubscribe])
        {
            _muteSubscription = [self.device.volumeControl subscribeMuteWithSuccess:^(BOOL mute)
                                 {
                                     NSLog(@"mute value changed");
                                     [_muteSwitch setOn:mute];
                                     [_muteSwitch setEnabled:YES];
                                 } failure:^(NSError *subscribeError)
                                 {
                                     NSLog(@"Subscribe mute Error %@", subscribeError.localizedDescription);
                                 }];
        } else if ([self.device hasCapability:kVolumeControlMuteGet])
        {
            [self.device.volumeControl getMuteWithSuccess:^(BOOL mute)
             {
                 [_muteSwitch setOn:mute];
                 [_muteSwitch setEnabled:YES];
             } failure:^(NSError *getError)
             {
                 NSLog(@"Get mute Error %@", getError.localizedDescription);
                 
                 [_muteSwitch setEnabled:NO];
             }];
        }
        
        if ([self.device hasCapability:kMediaControlPlay]) [_playButton setEnabled:YES];
        if ([self.device hasCapability:kMediaControlPause]) [_pauseButton setEnabled:YES];
        if ([self.device hasCapability:kMediaControlStop]) [_stopButton setEnabled:YES];
        if ([self.device hasCapability:kMediaControlRewind]) [_rewindButton setEnabled:YES];
        if ([self.device hasCapability:kMediaControlFastForward]) [_fastForwardButton setEnabled:YES];
        
        _inputList = [[NSArray alloc] init];
        
        if ([self.device hasCapability:kExternalInputControlList])
        {
            [self.device.externalInputControl getExternalInputListWithSuccess:^(NSArray *inp)
             {
                 _inputList = inp;
                 [_inputs reloadData];
             } failure:^(NSError *err)
             {
                 NSLog(@"External error, %@", err);
                 
                 self.inputs.hidden = YES;
             }];
        } else
        {
            self.inputs.hidden = YES;
            
            if ([self.device hasCapability:kExternalInputControlPickerLaunch]) [_launchPickerButton setEnabled:YES];
            if ([self.device hasCapability:kExternalInputControlPickerClose]) [_closePickerButton setEnabled:YES];
        }
    } else
    {
        [self removeSubscriptions];
    }
}

- (void)removeSubscriptions
{
    if (_muteSubscription)
        [_muteSubscription unsubscribe];
    
    if (_volumeSubscription)
        [_volumeSubscription unsubscribe];
    
    [_volumeStepper setEnabled:NO];
    [_volumeSlider setEnabled:NO];
    [_volumeStepper setValue:10];
    [_muteSwitch setEnabled:NO];
    
    [_playButton setEnabled:NO];
    [_pauseButton setEnabled:NO];
    [_stopButton setEnabled:NO];
    [_rewindButton setEnabled:NO];
    [_fastForwardButton setEnabled:NO];

    _inputList = [[NSArray alloc] init];
    [_inputs reloadData];

    _inputPickerSession = nil;
    
    [_launchPickerButton setEnabled:NO];
    [_closePickerButton setEnabled:NO];

    self.inputs.hidden = NO;
}

#pragma mark - Input list UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_inputList)
        return _inputList.count;
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ConnectSDKSamplerInputChooser";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    ExternalInputInfo *inputInfo = (ExternalInputInfo *) [_inputList objectAtIndex:(NSUInteger) indexPath.row];
    cell.textLabel.text = inputInfo.name;
    
    if (inputInfo.connected)
        cell.detailTextLabel.text = @"Connected";
    else
        cell.detailTextLabel.text = @"Disconnected";

    NSLog(@"%@", inputInfo);

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:inputInfo.iconURL]]];
    cell.accessoryView = imageView;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ExternalInputInfo *inputInfo = (ExternalInputInfo * ) [_inputList objectAtIndex:(NSUInteger) indexPath.row];

    [self.device.externalInputControl setExternalInput:inputInfo success:^(id responseObject)
    {
        NSLog(@"Success call");
    } failure:^(NSError *err)
    {
        NSLog(@"Error %@", err);
    }];
}

#pragma mark - Connect SDK API sampler methods

-(void)volumeStepperChange:(id)sender
{
    NSLog(@"Volume change requested");
    
    if ([_volumeStepper value] > 10)
    {
        [self.device.volumeControl volumeUpWithSuccess:^(id responseObject)
         {
             NSLog(@"Vol Up Success");
         } failure:^(NSError *err)
         {
             NSLog(@"Vol Up Error %@", err.description);
         }];
    } else if ([_volumeStepper value] < 10)
    {
        [self.device.volumeControl volumeDownWithSuccess:^(id responseObject)
         {
             NSLog(@"Vol down Success");
         } failure:^(NSError *err)
         {
             NSLog(@"Vol down Error %@", err.description);
         }];
    }
    
    [_volumeStepper setValue:10];
}

-(void) volumeSliderChange:(UISlider *)sender
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

-(void)muteSwitchChange:(id)sender
{
    BOOL muteOn = [_muteSwitch isOn];
    _muteSwitch.enabled = NO;
    
    [self.device.volumeControl setMute:muteOn success:^(id responseObject)
     {
         NSLog(@"Mute Success");
         
         _muteSwitch.enabled = YES;
     } failure:^(NSError *err)
     {
         NSLog(@"Mute Error %@", err.description);
     }];
}

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

- (IBAction)launchPicker:(id)sender
{
    [self.device.externalInputControl launchInputPickerWithSuccess:^(LaunchSession *session)
    {
        NSLog(@"External input picker launched");
        _inputPickerSession = session;

        self.closePickerButton.enabled = YES;
    } failure:^(NSError *error)
    {
        NSLog(@"External input picker error %@", error);
    }];
}

- (IBAction)closePicker:(id)sender
{
    [_inputPickerSession closeWithSuccess:^(LaunchSession *session)
    {
        NSLog(@"External input picker closed");
        _inputPickerSession = nil;

        self.closePickerButton.enabled = NO;
    } failure:^(NSError *error)
    {
        NSLog(@"External input picker close error %@", error);
    }];
}

@end
