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

#import "WebAppViewController.h"

@interface WebAppViewController () <WebAppSessionDelegate>
{
    WebAppSession *_webAppSession;
    NSString *_webAppId;
    ServiceSubscription *_isWebAppPinnedSubscription;
}

@end

@implementation WebAppViewController

- (void) appDidBecomeActive:(NSNotification *)notification
{
    if (_webAppSession)
    {
        [_webAppSession joinWithSuccess:^(id responseObject)
        {
            NSLog(@"web app re-join success");

            [_sendButton setEnabled:YES];
            if ([self.device hasCapability:kWebAppLauncherMessageSendJSON]) [_sendJSONButton setEnabled:YES];

        }                          failure:^(NSError *error)
        {
            NSLog(@"web app re-join error: %@", error.localizedDescription);

            _webAppSession.delegate = nil;
            _webAppSession = nil;

            [_sendButton setEnabled:NO];
            [_sendJSONButton setEnabled:NO];
            [_closeButton setEnabled:NO];
            [_pinButton setEnabled:NO];
            [_unPinButton setEnabled:NO];
        }];
    }
    if ([self.device hasCapability:kWebAppLauncherPin]){
        [self checkIfWebAppIsPinned];
    }
}

- (void) addSubscriptions
{
    if (self.device)
    {
        if ([self.device hasCapability:kWebAppLauncherLaunch]) [_launchButton setEnabled:YES];
        if ([self.device hasCapability:kWebAppLauncherJoin]) [_joinButton setEnabled:YES];
        if ([self.device serviceWithName:@"webOS TV"])
            _webAppId = [[NSUserDefaults standardUserDefaults] stringForKey:@"webOSWebAppId"];
        else if ([self.device serviceWithName:@"Chromecast"])
            _webAppId = [[NSUserDefaults standardUserDefaults] stringForKey:@"castWebAppId"];
        else if ([self.device serviceWithName:@"AirPlay"])
            _webAppId = [[NSUserDefaults standardUserDefaults] stringForKey:@"airPlayWebAppId"];
        
        if ([self.device hasCapability:kWebAppLauncherPin]){
            [self checkIfWebAppIsPinned];
            [self subscribeIfWebAppIsPinned];
        }
    }
}

- (void) removeSubscriptions
{
    if (_webAppSession)
    {
        _webAppSession.delegate = nil;
        [_webAppSession disconnectFromWebApp];
        _webAppSession = nil;
    }

    [_launchButton setEnabled:NO];
    [_sendButton setEnabled:NO];
    [_sendJSONButton setEnabled:NO];
    [_leaveButton setEnabled:NO];
    [_joinButton setEnabled:NO];
    [_closeButton setEnabled:NO];
    [_pinButton setEnabled:NO];
    [_unPinButton setEnabled:NO];
    [_statusTextView setText:@""];
    [_statusTextView setUserInteractionEnabled:NO];
    if(_isWebAppPinnedSubscription){
        [_isWebAppPinnedSubscription unsubscribe];
        _isWebAppPinnedSubscription = nil;
    }
}

#pragma mark - Connect SDK API sampler methods

- (IBAction)launchWebApp:(id)sender
{
    if (_webAppSession)
    {
        _webAppSession.delegate = nil;
        [_webAppSession disconnectFromWebApp];
        _webAppSession = nil;

        [_sendButton setEnabled:NO];
        [_sendJSONButton setEnabled:NO];
        [_closeButton setEnabled:NO];
        [_pinButton setEnabled:NO];
        [_unPinButton setEnabled:NO];
    }

    [_launchButton setEnabled:NO];

    [self.device.webAppLauncher launchWebApp:_webAppId success:^(WebAppSession *webAppSession)
    {
        NSLog(@"web app launch success");

        _webAppSession = webAppSession;
        _webAppSession.delegate = self;

        if ([self.device hasCapability:kWebAppLauncherClose]) [_closeButton setEnabled:YES];
        if ([self.device hasCapability:kWebAppLauncherDisconnect]) [_leaveButton setEnabled:YES];
        if ([self.device hasCapability:kWebAppLauncherPin]) {
            [self checkIfWebAppIsPinned];
        }
        if ([self.device hasCapabilities:@[kWebAppLauncherMessageSend, kWebAppLauncherMessageReceive]])
        {
            [_webAppSession connectWithSuccess:^(id responseObject)
            {
                NSLog(@"web app connect success");

                if ([self.device hasCapability:kWebAppLauncherMessageSend]) [_sendButton setEnabled:YES];
                if ([self.device hasCapability:kWebAppLauncherMessageSendJSON]) [_sendJSONButton setEnabled:YES];
            }                          failure:^(NSError *error)
            {
                NSLog(@"web app connect error: %@", error.localizedDescription);
            }];
        }
    } failure:^(NSError *error)
    {
        NSLog(@"web app launch error: %@", error.localizedDescription);
        [_launchButton setEnabled:YES];
    }];
}

- (IBAction)joinWebApp:(id)sender
{
    [self.device.webAppLauncher joinWebAppWithId:_webAppId success:^(WebAppSession *webAppSession)
    {
        NSLog(@"web app join success");
        
        _webAppSession = webAppSession;
        _webAppSession.delegate = self;

        [_launchButton setEnabled:NO];
        if ([self.device hasCapability:kWebAppLauncherMessageSend]) [_sendButton setEnabled:YES];
        if ([self.device hasCapability:kWebAppLauncherMessageSendJSON]) [_sendJSONButton setEnabled:YES];
        if ([self.device hasCapability:kWebAppLauncherDisconnect]) [_leaveButton setEnabled:YES];
        if ([self.device hasCapability:kWebAppLauncherClose]) [_closeButton setEnabled:YES];
        if ([self.device hasCapability:kWebAppLauncherPin]) [_pinButton setEnabled:YES];
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
            NSLog(@"web app send text success");
        } failure:^(NSError *error)
        {
            NSLog(@"web app send text error: %@", error.localizedDescription);
        }];
    } else if (sender == _sendJSONButton)
    {
        [_webAppSession sendJSON:jsonMessage success:^(id responseObject)
        {
            NSLog(@"web app send JSON success");
        } failure:^(NSError *error)
        {
            NSLog(@"web app send JSON error: %@", error.localizedDescription);
        }];
    }
}

- (IBAction)leaveWebApp:(id)sender
{
    _webAppSession.delegate = nil;
    [_webAppSession disconnectFromWebApp];
    _webAppSession = nil;
    
    [self removeSubscriptions];
    
    [_launchButton setEnabled:YES];
    if ([self.device hasCapability:kWebAppLauncherJoin]) [_joinButton setEnabled:YES];
}

- (IBAction)closeWebApp:(id)sender
{
    _webAppSession.delegate = nil;

    [_webAppSession closeWithSuccess:^(id responseObject) {
        NSLog(@"close web app success");
    } failure:^(NSError *error) {
        NSLog(@"close web app failure, %@", error.localizedDescription);
    }];

    _webAppSession = nil;

    [self removeSubscriptions];

    [_launchButton setEnabled:YES];
    if ([self.device hasCapability:kWebAppLauncherJoin]) [_joinButton setEnabled:YES];
}

- (IBAction)pinWebApp:(id)sender
{
    [self.device.webAppLauncher pinWebApp:_webAppId success:^(id responseObject){
        NSLog(@"pin web app success");
        [self checkIfWebAppIsPinned];
    } failure:^(NSError *error) {
        NSLog(@"pin web app failure, %@", error.localizedDescription);
    }];
    
}

- (IBAction)unPinWebApp:(id)sender{
    [self.device.webAppLauncher unPinWebApp:_webAppId success:^(id responseObject) {
        NSLog(@"un pin web app success");
        [self checkIfWebAppIsPinned];
    } failure:^(NSError *error) {
        NSLog(@"un pin web app failure, %@", error.localizedDescription);
    }];
}

-(void)checkIfWebAppIsPinned{
    
    [self.device.webAppLauncher isWebAppPinned:_webAppId success:^(BOOL status) {
        [self updatePinButton:status];
    } failure:^(NSError *error) {
        NSLog(@" Subscribe isWebAppPinned failure, %@", error.localizedDescription);
    }];
}

-(void)subscribeIfWebAppIsPinned{
    
   _isWebAppPinnedSubscription = [self.device.webAppLauncher subscribeIsWebAppPinned:_webAppId success:^(BOOL status) {
        [self updatePinButton:status];
    } failure:^(NSError *error) {
        NSLog(@" isWebAppPinned failure, %@", error.localizedDescription);
    }];
}

-(void)updatePinButton:(BOOL)status{
    if(status){
        _pinButton.enabled = NO;
        _unPinButton.enabled = YES;
    }else{
        _pinButton.enabled = YES;
        _unPinButton.enabled = NO;
    }
}

#pragma mark - WebAppSessionDelegate methods

- (void) webAppSession:(WebAppSession *)webAppSession didReceiveMessage:(id)message
{
    // check to see if we actually care about this delegate message
    if (!_webAppSession || _webAppSession != webAppSession)
        return;

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
    // check to see if we actually care about this delegate message
    if (!_webAppSession || _webAppSession != webAppSession)
        return;

    _webAppSession.delegate = nil;
    _webAppSession = nil;

    [_launchButton setEnabled:YES];
    [_sendButton setEnabled:NO];
    [_sendJSONButton setEnabled:NO];
    [_leaveButton setEnabled:NO];
    [_closeButton setEnabled:NO];
}

@end
