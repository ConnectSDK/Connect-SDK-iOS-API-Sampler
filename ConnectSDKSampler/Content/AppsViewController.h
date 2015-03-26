//
//  AppsViewController.h
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

#import "BaseViewController.h"

@interface AppsViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UIButton *browserButton;
@property (weak, nonatomic) IBOutlet UIButton *toastButton;
@property (weak, nonatomic) IBOutlet UIButton *netflixButton;
@property (weak, nonatomic) IBOutlet UIButton *appStoreButton;
@property (weak, nonatomic) IBOutlet UIButton *youtubeButton;
@property (weak, nonatomic) IBOutlet UIButton *myAppButton;

@property (weak, nonatomic) IBOutlet UITableView *apps;

- (IBAction)browserPressed:(id)sender;
- (IBAction)toastPressed:(id)sender;
- (IBAction)netflixPressed:(id)sender;
- (IBAction)appStorePressed:(id)sender;
- (IBAction)youtubePressed:(id)sender;
- (IBAction)myAppPressed:(id)sender;

@end
