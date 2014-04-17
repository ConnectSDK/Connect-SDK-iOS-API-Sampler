//
//  BaseViewController.h
//  Connect SDK Sampler App
//
//  Created by Andrew Longstaff on 9/17/13.
//  Connect SDK Sample App by LG Electronics
//
//  To the extent possible under law, the person who associated CC0 with
//  this sample app has waived all copyright and related or neighboring rights
//  to the sample app.
//
//  You should have received a copy of the CC0 legalcode along with this
//  work. If not, see http://creativecommons.org/publicdomain/zero/1.0/.
//

#import <ConnectSDK/ConnectSDK.h>

@interface BaseViewController : UIViewController

@property (nonatomic, assign) ConnectableDevice *device;

- (void) addSubscriptions;
- (void) removeSubscriptions;

@end
