//
//  AppViewController.m
//  Connect SDK Sampler App
//
//  Created by Andrew Longstaff on 9/17/13.
//  Copyright (c) 2014 LG Electronics. All rights reserved.
//

#import "AppViewController.h"

@interface AppViewController ()

@end

@implementation AppViewController{
    NSArray *_appList;
    int _currentApp;

    ServiceSubscription *_runningAppSubscription;

//    LaunchSession *_netflixSession;
//    LaunchSession *_youtubeSession;
//    LaunchSession *_browserSession;
//    LaunchSession *_huluSession;
    LaunchSession *_imageSession;
    LaunchSession *_videoSession;
}

- (void) addSubscriptions
{
    if (self.device)
    {
        _appList = [[NSArray alloc] init];
        
        [self.device.launcher getAppListWithSuccess:^(NSArray *appList)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                _appList = appList;
                [self reloadData];
            });
        } failure:^(NSError *err)
        {
            NSLog(@"Get app Error %@", err.description);
        }];

        _currentApp = -1;

        _runningAppSubscription = [self.device.launcher subscribeRunningAppWithSuccess:^(AppInfo *appInfo)
        {
            NSLog(@"App change %@", appInfo);

            [_appList enumerateObjectsUsingBlock:^(AppInfo *app, NSUInteger idx, BOOL *stop)
            {
                if ([app isEqual:appInfo])
                {
                    _currentApp = idx;
                    [self reloadData];
                    *stop = YES;
                }
            }];
        } failure:^(NSError *err)
        {
            NSLog(@"App change err %@", err);
        }];
    }
}

- (void) removeSubscriptions
{
    _appList = nil;
    [self reloadData];

    if (_runningAppSubscription)
        [_runningAppSubscription unsubscribe];
}

#pragma mark - App list UITableView methods

- (void) reloadData
{
    NSSortDescriptor *titleSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:titleSortDescriptor];
    _appList = [_appList sortedArrayUsingDescriptors:sortDescriptors];
    
    [_apps reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_appList)
        return _appList.count;
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ConnectSDKChannelChooser";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];

    AppInfo *appInfo = (AppInfo *) [_appList objectAtIndex:(NSUInteger) indexPath.row];

    cell.textLabel.text = appInfo.name;
    cell.detailTextLabel.text = appInfo.id;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == _currentApp)
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    else
        [cell setAccessoryType:UITableViewCellAccessoryNone];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AppInfo *app = (AppInfo *) [_appList objectAtIndex:(NSUInteger) indexPath.row];

    [self.device.launcher launchApplicationWithInfo:app success:^(LaunchSession *launchSession)
    {
        NSLog(@"Launched application %@", launchSession);
    } failure:^(NSError *error)
    {
        NSLog(@"no launchApp %@", error);
    }];
}

#pragma mark - Actions

-(void) browserPressed:(id)sender{
    NSURL *URL = [NSURL URLWithString:@"http://enyojs.com/"];

    [self.device.launcher launchBrowser:URL success:^(LaunchSession *launchSession)
    {
        NSLog(@"google opened %@", launchSession);
    } failure:^(NSError *error)
    {
        NSLog(@"Google fail, %@", error);
    }];
}

-(void) simpleImagePressed:(UIButton *)sender
{
    NSURL *imageURL = [NSURL URLWithString:@"http://upload.wikimedia.org/wikipedia/commons/3/3a/LG_LOGO_NEW.jpg"];

    if (_imageSession)
    {
        [_imageSession closeWithSuccess:^(id responseObject)
        {
            NSLog(@"media closed");

            dispatch_async(dispatch_get_main_queue(), ^
            {
                _imageSession = nil;
                sender.selected = NO;
            });
        } failure:^(NSError *error)
        {
            NSLog(@"media close fail, %@", error);
        }];
    } else
    {
        [self.device.mediaPlayer displayImage:imageURL
                                   iconURL:nil
                                     title:@"LG Logo"
                               description:@"The Logo of LG"
                                  mimeType:@"image/jpeg"
                                   success:^(LaunchSession *launchSession, id<MediaControl> mediaControl)
        {
            NSLog(@"media opened %@", launchSession);

            dispatch_async(dispatch_get_main_queue(), ^
            {
                _imageSession = launchSession;
                sender.selected = YES;
            });
        } failure:^(NSError *error)
        {
            NSLog(@"media fail, %@", error);
        }];
    }
}

-(void) simpleVideoPressed:(UIButton *)sender
{
    NSURL *videoURL = [NSURL URLWithString:@"http://mirrorblender.top-ix.org/movies/sintel-1280-surround.mp4"];
    
    if (_videoSession)
    {
        [_videoSession closeWithSuccess:^(id responseObject)
         {
             NSLog(@"media closed");
             
             dispatch_async(dispatch_get_main_queue(), ^
                            {
                                _videoSession = nil;
                                sender.selected = NO;
                            });
         } failure:^(NSError *error)
         {
             NSLog(@"media close fail, %@", error);
         }];
    } else
    {
        [self.device.mediaPlayer displayVideo:videoURL
                                   iconURL:nil
                                     title:@"Sintel"
                               description:@"Blender Open Movie Project"
                                  mimeType:@"video/mp4"
                                shouldLoop:NO
                                   success:^(LaunchSession *launchSession, id<MediaControl> mediaControl)
         {
             NSLog(@"media opened %@", launchSession);
             
             dispatch_async(dispatch_get_main_queue(), ^
                            {
                                _videoSession = launchSession;
                                sender.selected = YES;
                            });
         } failure:^(NSError *error)
         {
             NSLog(@"media fail, %@", error);
         }];
    }
}

- (IBAction)netflixPressed:(id)sender
{
    [self.device.launcher launchNetflix:@"60022689" success:^(LaunchSession *launchSession)
     {
         NSLog(@"netflix opened with data: %@", launchSession);
     } failure:^(NSError *error)
     {
         NSLog(@"netflix fail, %@", error);
     }];
}

- (IBAction)huluPressed:(id)sender
{
    [self.device.launcher launchHulu:@"545056" success:^(LaunchSession *launchSession)
     {
         NSLog(@"hulu opened with data: %@", launchSession);
     } failure:^(NSError *error)
     {
         NSLog(@"hulu fail, %@", error);
     }];
}

- (IBAction)youtubePressed:(id)sender
{
    [self.device.launcher launchYouTube:@"IHQr0HCIN2w" success:^(LaunchSession *launchSession)
    {
        NSLog(@"youtube opened with data: %@", launchSession);
    } failure:^(NSError *error)
    {
        NSLog(@"youtube fail, %@", error);
    }];
}

@end
