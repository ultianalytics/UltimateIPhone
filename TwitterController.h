//
//  TwitterController.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwitterController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView* twitterTableView;
@property (nonatomic, strong) IBOutlet UITableView* tweetLogTableView;

@property (nonatomic, strong) IBOutlet UITableViewCell* tweetEveryEventCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* tweetButtonCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* twitterAccountCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* recentTweetsCell;
@property (nonatomic, strong) IBOutlet UILabel* twitterAccountNameLabel;

@property (nonatomic, strong) IBOutlet UISegmentedControl* autoTweetSegmentedControl;

-(IBAction)autoTweetChanged: (id) sender;
-(IBAction)tweetButtonClicked: (id) sender;
-(void)populateViewFromModel;

@end
