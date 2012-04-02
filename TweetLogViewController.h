//
//  TweetLogViewController.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetLogViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView* tweetLogTableView;

-(void)populateViewFromModel;


@end
