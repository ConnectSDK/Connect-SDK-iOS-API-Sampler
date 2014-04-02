//
//  TouchpadView.m
//  Connect SDK Sampler App
//
//  Created by Andrew Longstaff on 9/25/13.
//  Copyright (c) 2014 LG Electronics. All rights reserved.
//

#import "ControlTouchpadView.h"

@implementation ControlTouchpadView
{
    float oldX;
    float oldY;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    oldX = touchLocation.x;
    oldY = touchLocation.y;
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    int fingersDown = [[event allTouches] count];

    if (self.mouseControl)
    {
        CGVector distance = CGVectorMake(
            touchLocation.x - oldX,
            touchLocation.y - oldY
        );
        
        if (fingersDown >= 2)
        {
            [self.mouseControl scroll:distance success:^(id responseObject)
            {
//            NSLog(@"mouse scrolled!");
            } failure:^(NSError *error)
            {
                NSLog(@"Mouse scroll failed: %@", error.localizedDescription);
            }];
        } else
        {
            [self.mouseControl move:distance success:^(id responseObject)
            {
//            NSLog(@"mouse moved!");
            } failure:^(NSError *error)
            {
                NSLog(@"Mouse move failed: %@", error.localizedDescription);
            }];
        }
    }

    oldX = touchLocation.x;
    oldY = touchLocation.y;
}

- (void)tapDetected:(id)sender
{
    [self.mouseControl clickWithSuccess:nil failure:nil];
}

@end
