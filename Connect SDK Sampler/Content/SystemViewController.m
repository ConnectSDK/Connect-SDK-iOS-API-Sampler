//
//  InputViewController.m
//  Connect SDK Sampler App
//
//  Created by Andrew Longstaff on 9/18/13.
//  Copyright (c) 2014 LG Electronics. All rights reserved.
//

#import "SystemViewController.h"

@interface SystemViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation SystemViewController
{
    NSArray *_inputList;
    LaunchSession *_inputPickerSession;
}

- (void)addSubscriptions
{
    if (self.device)
    {
        _inputList = [[NSArray alloc] init];
        
        [self.device.externalInputControl getExternalInputListWithSuccess:^(NSArray *inp)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                _inputList = inp;
                [_inputs reloadData];
            });
        } failure:^(NSError *err)
        {
            NSLog(@"External error, %@", err);

            dispatch_async(dispatch_get_main_queue(), ^
            {
                self.inputs.hidden = YES;
            });
        }];
    } else
    {
        [self removeSubscriptions];
    }
}

- (void)removeSubscriptions
{
    _inputList = [[NSArray alloc] init];
    [_inputs reloadData];

    _inputPickerSession = nil;
    self.closePickerButton.enabled = NO;

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

- (IBAction)launchPicker:(id)sender
{
    [self.device.externalInputControl launchInputPickerWithSuccess:^(LaunchSession *session)
    {
        NSLog(@"External input picker launched");
        _inputPickerSession = session;

        dispatch_async(dispatch_get_main_queue(), ^
        {
            self.closePickerButton.enabled = YES;
        });
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

        dispatch_async(dispatch_get_main_queue(), ^
        {
            self.closePickerButton.enabled = NO;
        });
    } failure:^(NSError *error)
    {
        NSLog(@"External input picker close error %@", error);
    }];
}

@end
