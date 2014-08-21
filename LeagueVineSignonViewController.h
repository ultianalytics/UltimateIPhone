//
//  LeagueVineSignonViewController.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 9/18/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UltimateViewController.h"

@interface LeagueVineSignonViewController : UltimateViewController <UIWebViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) void (^finishedBlock)(BOOL isSignedOn, LeagueVineSignonViewController* signonController);

@end
