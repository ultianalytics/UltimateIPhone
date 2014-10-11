//
//  TweetLogViewController.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UltimateViewController.h"
@class Tweet;

@interface TweetLogViewController : UltimateViewController <UITableViewDelegate, UITableViewDataSource> {
    @private
    NSArray* tweetLog;
}

@property (nonatomic, strong) IBOutlet UITableView* tweetLogTableView;

-(void)populateViewFromModel;
-(NSString*)timeSince: (double) time;
-(NSString*)tweetText: (Tweet*) tweet;
-(CGFloat)heightForTweetText:(NSString*)text;


@end
