//
//  TweetLogTableViewCell.m
//  UltimateIPhone
//
//  Created by james on 7/25/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "TweetLogTableViewCell.h"

@interface TweetLogTableViewCell ()

@property (strong, nonatomic) IBOutlet UILabel *tweetTextLabel;
@property (strong, nonatomic) IBOutlet UILabel *tweetTimeSinceLabel;

@end

@implementation TweetLogTableViewCell
@dynamic tweetText, timeSinceText, status;


-(void)setTimeSinceText:(NSString *)timeSinceText {
    self.tweetTimeSinceLabel.text = timeSinceText;
}

-(void)setTweetText:(NSString *)tweetText {
    self.tweetTextLabel.text = tweetText;
    
    // resize the the tweet text label
    CGRect f = self.tweetTextLabel.frame;
    f.size.height = [self preferredLabelHeight:self.tweetTextLabel.text];
    self.tweetTextLabel.frame = f;
}

-(void)setStatus:(TweetStatus)status {
    // set the color of the tweet
    self.tweetTextLabel.textColor = status == TweetQueued ? [UIColor blueColor] : status == TweetSent ? [UIColor blackColor] : [UIColor redColor];
}

-(CGFloat)preferredCellHeight: (NSString*)text {
    CGFloat height = [self preferredLabelHeight: text];
    height += self.tweetTextLabel.frame.origin.x;
    height += (self.bounds.size.height - CGRectGetMaxY(self.tweetTextLabel.frame));
    return height;
}

-(CGFloat)preferredLabelHeight: (NSString*)text {
    CGSize maxSize = CGSizeMake(self.tweetTextLabel.bounds.size.width, 99999);
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGFloat estimatedHeight = [text sizeWithFont:self.tweetTextLabel.font constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping].height;
    #pragma clang diagnostic pop

    return ceilf(estimatedHeight);
}

@end
