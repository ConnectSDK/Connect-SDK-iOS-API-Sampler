//
//  WebAppViewController.m
//  Connect SDK Sampler
//
//  Created by Jeremy White on 2/26/14.
//  Connect SDK Sample App by LG Electronics
//
//  To the extent possible under law, the person who associated CC0 with
//  this sample app has waived all copyright and related or neighboring rights
//  to the sample app.
//
//  You should have received a copy of the CC0 legalcode along with this
//  work. If not, see http://creativecommons.org/publicdomain/zero/1.0/.
//

#import <ConnectSDK/WebOSTVService.h>
#import <ConnectSDK/CastService.h>
#import "WebAppViewController.h"

@interface WebAppViewController () <WebAppSessionDelegate>
{
    WebAppSession *_webAppSession;
    NSString *_webAppId;
}

@end

@implementation WebAppViewController

- (void) addSubscriptions
{
    if (self.device)
    {
        if ([self.device hasCapability:kWebAppLauncherLaunch]) [_launchButton setEnabled:YES];
        
        if ([self.device.webAppLauncher isMemberOfClass:[WebOSTVService class]])
            _webAppId = @"SampleWebApp";
        else if ([self.device.webAppLauncher isMemberOfClass:[CastService class]])
            _webAppId = @"DDCEDE96";
    }
}

- (void) removeSubscriptions
{
    if (_webAppSession)
    {
        _webAppSession.delegate = nil;

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

#pragma mark - Connect SDK API sampler methods

- (IBAction)launchWebApp:(id)sender
{
    if (_webAppSession)
    {
        [_statusTextView setText:@""];
        _webAppSession.delegate = nil;
        [_webAppSession disconnectFromWebApp];
    }
    
    [self.device.webAppLauncher launchWebApp:_webAppId success:^(WebAppSession *webAppSession)
    {
        NSLog(@"web app launch success");

        _webAppSession = webAppSession;
        _webAppSession.delegate = self;

        if ([self.device hasCapability:kWebAppLauncherClose]) [_closeButton setEnabled:YES];

        if ([self.device hasCapabilities:@[kWebAppLauncherMessageSend, kWebAppLauncherMessageReceive]])
        {
            [_webAppSession connectWithSuccess:^(id responseObject)
            {
                NSLog(@"web app connect success");

                [_sendButton setEnabled:YES];
                if ([self.device hasCapability:kWebAppLauncherMessageSendJSON]) [_sendJSONButton setEnabled:YES];
            }                          failure:^(NSError *error)
            {
                NSLog(@"web app connect error: %@", error.localizedDescription);
            }];
        }
    }                                failure:^(NSError *error)
    {
        NSLog(@"web app launch error: %@", error.localizedDescription);
    }];
}

- (IBAction)joinWebApp:(id)sender
{
    [self.device.webAppLauncher joinWebAppWithId:_webAppId success:^(WebAppSession *webAppSession)
    {
        NSLog(@"web app join success");
        
        _webAppSession = webAppSession;
        _webAppSession.delegate = self;
        
        [_sendButton setEnabled:YES];
        if ([self.device hasCapability:kWebAppLauncherMessageSendJSON]) [_sendJSONButton setEnabled:YES];
    } failure:^(NSError *error)
    {
        NSLog(@"web app join error: %@", error.localizedDescription);
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

#pragma mark - WebAppSessionDelegate methods

- (void) webAppSession:(WebAppSession *)webAppSession didReceiveMessage:(id)message
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

- (void) webAppSessionDidDisconnect:(WebAppSession *)webAppSession
{
    [self closeWebApp:self];
}

@end
