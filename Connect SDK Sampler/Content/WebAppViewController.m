//
//  WebAppViewController.m
//  Connect SDK Sampler
//
//  Created by Jeremy White on 2/26/14.
//  Copyright (c) 2014 LGE. All rights reserved.
//

#import <ConnectSDK/WebOSTVService.h>
#import <ConnectSDK/CastService.h>
#import "WebAppViewController.h"

@interface WebAppViewController ()
{
    WebAppSession *_webAppSession;
}

@end

@implementation WebAppViewController

- (void) addSubscriptions
{
    if (self.device)
    {
        if ([self.device hasCapability:kWebAppLauncherLaunch]) [_launchButton setEnabled:YES];
    }
}

- (void) removeSubscriptions
{
    if (_webAppSession)
    {
        [_webAppSession closeWithSuccess:^(id responseObject)
        {
            NSLog(@"web app close success");
        } failure:^(NSError *error)
        {
            NSLog(@"web app close error: %@", error.localizedDescription);
        }];

        _webAppSession = nil;
    }

    [_launchButton setEnabled:NO];
    [_sendButton setEnabled:NO];
    [_sendJSONButton setEnabled:NO];
    [_closeButton setEnabled:NO];

    [_statusTextView setText:@""];
    [_statusTextView setUserInteractionEnabled:NO];
}

- (void) handleMessage:(id)message
{
    NSString *messageString;

    if ([message isKindOfClass:[NSString class]])
        messageString = message;
    else if ([message isKindOfClass:[NSDictionary class]] || [message isKindOfClass:[NSArray class]])
    {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:message
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];

        if (!error && jsonData)
            messageString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }

    if (messageString)
        _statusTextView.text = [NSString stringWithFormat:@"%@\n%@", message, _statusTextView.text];
}

#pragma mark - Connect SDK API sampler methods

- (IBAction)launchWebApp:(id)sender
{
    NSString *webAppId;

    if ([self.device.webAppLauncher isMemberOfClass:[WebOSTVService class]])
        webAppId = @"MediaPlayer";
    else if ([self.device.webAppLauncher isMemberOfClass:[CastService class]])
        webAppId = @"4F6217BC";

    [self.device.webAppLauncher launchWebApp:webAppId success:^(WebAppSession *webAppSession)
    {
        NSLog(@"web app launch success");

        _webAppSession = webAppSession;

        if ([self.device hasCapability:kWebAppLauncherClose]) [_closeButton setEnabled:YES];

        if ([self.device hasCapability:kWebAppLauncherMessage])
        {
            [_webAppSession connectWithMessageCallback:^(id message)
            {
                NSLog(@"web app received message: %@", message);
                [self handleMessage:message];
            } success:^(id responseObject)
            {
                NSLog(@"web app connect success");

                if ([self.device hasCapability:kWebAppLauncherMessageSend]) [_sendButton setEnabled:YES];
                if ([self.device hasCapability:kWebAppLauncherMessageSendJSON]) [_sendJSONButton setEnabled:YES];
            } failure:^(NSError *error)
            {
                NSLog(@"web app connect error: %@", error.localizedDescription);
            }];
        }
    } failure:^(NSError *error)
    {
        NSLog(@"web app launch error: %@", error.localizedDescription);
    }];
}

- (IBAction)sendMessage:(id)sender
{
    NSString *stringMessage = @"This is a test message.";
    NSDictionary *jsonMessage = @{
            @"type" : @"message",
            @"contents" : @"This is a test message",
            @"params" : @{
                    @"someParam1" : @"The content & format of this JSON block can be anything",
                    @"someParam2" : @"The only limit ... is yourself"
            },
            @"anArray" : @[
                    @"Just",
                    @"to",
                    @"prove",
                    @"we",
                    @"can",
                    @"send",
                    @"arrays"
            ]
    };

    if (sender == _sendButton)
    {
        [_webAppSession sendText:stringMessage success:^(id responseObject)
        {

        } failure:^(NSError *error)
        {
            NSLog(@"web app send text error: %@", error.localizedDescription);
        }];
    } else if (sender == _sendJSONButton)
    {
        [_webAppSession sendJSON:jsonMessage success:^(id responseObject)
        {

        } failure:^(NSError *error)
        {
            NSLog(@"web app send JSON error: %@", error.localizedDescription);
        }];
    }
}

- (IBAction)closeWebApp:(id)sender
{
    [self removeSubscriptions];

    [_launchButton setEnabled:YES];
}

@end
