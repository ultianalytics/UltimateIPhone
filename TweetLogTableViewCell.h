//
//  TweetLogTableViewCell.h
//  UltimateIPhone
//
//  Created by james on 7/25/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@interface TweetLogTableViewCell : UITableViewCell

@property (strong, nonatomic) NSString* tweetText;
@property (strong, nonatomic) NSString* timeSinceText;

@end
