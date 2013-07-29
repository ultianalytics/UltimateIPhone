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
#import "TweetLogTableViewCell.h"
#import "ColorMaster.h"

#define kTweetViewWidth 290

@interface TweetLogViewController()

@property (nonatomic, strong) TweetLogTableViewCell* sampleCell;

@end

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
    TweetLogTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"std"];
    if (cell == nil) {
        cell = [self createCell];
    }
    
    Tweet* tweet = [tweetLog objectAtIndex:[indexPath row]];
    
    cell.tweetText = [self tweetText:tweet];
    cell.status = tweet.status;
    cell.timeSinceText = tweet.status == TweetQueued ? @"" : [self timeSince:tweet.time];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Tweet* tweet = [tweetLog objectAtIndex:[indexPath row]];
    return [self heightForTweetText:[self tweetText:tweet]];
}

- (CGFloat)heightForTweetText:(NSString*)text{
    return [self.sampleCell preferredCellHeight:text];
}

- (TweetLogTableViewCell*)createCell {
	return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([TweetLogTableViewCell class]) owner:nil options:nil] lastObject];
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
    self.sampleCell = [self createCell];
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
