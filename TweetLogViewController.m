//
//  TweetLogViewController.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TweetLogViewController.h"
#import "Tweet.h"
#import "Tweeter.h"
#import "ColorMaster.h"

#define kTweetViewWidth 290

@implementation TweetLogViewController
@synthesize tweetLogTableView;

-(void)populateViewFromModel {
    tweetLog = [[Tweeter getCurrent] getRecentTweetActivity];
    [tweetLogTableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tweetLog count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: STD_ROW_TYPE];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                                 initWithStyle:UITableViewCellStyleDefault
                                 reuseIdentifier:STD_ROW_TYPE];
        for (UIView *view in cell.subviews) {
            [view removeFromSuperview];
        }
        UITextView* textView = [[UITextView alloc] init];
        textView.backgroundColor = [UIColor clearColor];
        textView.editable = NO;
        [cell addSubview: textView];
        UILabel* timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTweetViewWidth + 5,0, 25, 20)];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textColor = [UIColor grayColor];
        timeLabel.font =[UIFont systemFontOfSize: 12];
        [cell addSubview: timeLabel];        
    }
    Tweet* tweet = [tweetLog objectAtIndex:[indexPath row]];
    UITextView* textView = (UITextView*) [cell.subviews objectAtIndex:0];
    NSString* text = [self tweetText:tweet];
    textView.font = tweetFont;
    textView.frame = CGRectMake(0,0, kTweetViewWidth, [self heightForTweetText:text]);
    textView.text = text;
    [textView setTextColor: tweet.status == TweetQueued ? [UIColor blueColor] : tweet.status == TweetSent ? [UIColor blackColor] : [UIColor redColor]];    
    textView.font = tweetFont;
    
    UILabel* numberLabel = (UILabel*) [cell.subviews objectAtIndex:1];
    numberLabel.text= tweet.status == TweetQueued ? @"" : [self timeSince:tweet.time];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Tweet* tweet = [tweetLog objectAtIndex:[indexPath row]];
    return [self heightForTweetText:[self tweetText:tweet]];
}

- (CGFloat)heightForTweetText:(NSString*)text{
    CGSize maxSize = CGSizeMake(kTweetViewWidth - 15,9999);  // reducing width by margins
    CGSize titleSize = [text sizeWithFont:tweetFont constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
    return titleSize.height + 20; // add some space for margin
}

-(NSString*) tweetText: (Tweet*) tweet {
    switch(tweet.status)
    {
        case TweetIgnored:
            return [NSString stringWithFormat:@"TWITTER REJECTED: %@", tweet.message];
        case TweetFailed:
            return [NSString stringWithFormat:@"ERROR SENDING TO TWITTER: %@", tweet.message];
        case TweetSkipped:
            return [NSString stringWithFormat:@"SKIPPED...TOO MANY RECENT TWEETS: %@", tweet.message];
        default:
            return tweet.message;
    }
}

-(NSString*)timeSince: (double) time {
    double now = [NSDate timeIntervalSinceReferenceDate];
    int secondsSince = now - time;
    if (secondsSince < 60) {
        return [NSString stringWithFormat:@"%ds", secondsSince];
    } else if (secondsSince < 3600) {
        int minutesSince = secondsSince / 60;
        return [NSString stringWithFormat:@"%dm", minutesSince];
    } else if (secondsSince < 86400) {
        int hoursSince = secondsSince / 3600;
        return [NSString stringWithFormat:@"%dh", hoursSince];
    } else if (secondsSince < 2592000) {
        int daysSince = secondsSince / 86400;
        return [NSString stringWithFormat:@"%dd", daysSince];
    } else {
        return @"old";
    }

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Recent Tweets", @"Recent Tweets");
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    tweetFont = [UIFont systemFontOfSize: 14];
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(populateViewFromModel)];
    self.navigationItem.rightBarButtonItem = refreshButton;    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(populateViewFromModel)
                                                 name: @"UIApplicationWillEnterForegroundNotification"
                                               object: nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self populateViewFromModel];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
@end
