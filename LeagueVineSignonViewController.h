//
//  LeagueVineSignonViewController.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 9/18/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeagueVineSignonViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) void (^finishedBlock)(BOOL isSignedOn, LeagueVineSignonViewController* signonController);
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIView *coverView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) IBOutlet UILabel *busyLabel;

@end
