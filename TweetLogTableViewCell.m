//
//  TweetLogTableViewCell.m
//  UltimateIPhone
//
//  Created by james on 7/25/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "TweetLogTableViewCell.h"

#define kTweetLogTextFont [UIFont systemFontOfSize:13]

@interface TweetLogTableViewCell ()

@property (strong, nonatomic) IBOutlet UILabel *tweetTextLabel;
@property (strong, nonatomic) IBOutlet UILabel *tweetTimeSinceLabel;

@end

@implementation TweetLogTableViewCell
@dynamic tweetText, timeSinceText;

-(void)awakeFromNib {
    self.tweetTextLabel.font = kTweetLogTextFont;
}

-(void)setTweetText:(NSString *)tweetText {
    self.tweetTextLabel.text = tweetText;
}

-(void)setTimeSinceText:(NSString *)timeSinceText {
    self.tweetTimeSinceLabel.text = timeSinceText;
}


@end
