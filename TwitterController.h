//
//  TwitterController.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 3/31/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UltimateViewController.h"

@interface TwitterController : UltimateViewController <UITableViewDelegate, UITableViewDataSource> {
    @private
    NSArray* twitterCells;
    UIAlertView* busyView;
}

+(void)showNoConnectivityAlert;

-(IBAction)autoTweetChanged: (id) sender;
-(IBAction)tweetButtonClicked: (id) sender;
-(void)populateViewFromModel;


@end
