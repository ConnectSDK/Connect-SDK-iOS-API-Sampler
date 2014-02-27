//
//  TouchpadView.h
//  Connect SDK Sampler App
//
//  Created by Andrew Longstaff on 9/25/13.
//  Copyright (c) 2014 LG Electronics. All rights reserved.
//

#import <ConnectSDK/ConnectSDK.h>

@interface ControlTouchpadView : UIView

@property (nonatomic, strong) id<MouseControl> mouseControl;

-(IBAction)tapDetected:(id)sender;

@end
