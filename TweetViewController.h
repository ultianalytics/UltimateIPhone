//
//  TweetViewController.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 3/28/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UltimateViewController.h"

@interface TweetViewController : UltimateViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) IBOutlet UITableViewCell* tweetTextCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* tweetAccountCell;
@property (nonatomic, strong) IBOutlet UILabel* accountNameLabel;
@property (nonatomic, strong) IBOutlet UILabel* charCountLabel;
@property (nonatomic, strong) IBOutlet UITextView* tweetTextView;
@property (nonatomic, strong) NSString* initialText;

+(void)alertNoAccount: (id<UIAlertViewDelegate>) delegate;

@end
