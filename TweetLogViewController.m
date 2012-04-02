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

@implementation TweetLogViewController
@synthesize tweetLogTableView;

NSArray* tweetLog;

UIAlertView* busyView;


-(void)populateViewFromModel {
    tweetLog = [Tweeter getRecentTweetActivity];
    [tweetLogTableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tweetLog count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* STD_ROW_TYPE = @"stdRowType";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: STD_ROW_TYPE];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                                 initWithStyle:UITableViewCellStyleDefault
                                 reuseIdentifier:STD_ROW_TYPE];
        for (UIView *view in cell.subviews) {
            [view removeFromSuperview];
        }
        UITextView* textView = [[UITextView alloc] initWithFrame:CGRectMake(0,0, 320, 70)];
        textView.backgroundColor = [UIColor clearColor];
        [cell addSubview: textView];
    }
    Tweet* tweet = [tweetLog objectAtIndex:[indexPath row]];
    UITextView* textView = (UITextView*) [cell.subviews objectAtIndex:0];
    textView.text = tweet.message;
    [textView setTextColor: tweet.status == TweetQueued ? [UIColor blueColor] : tweet.status == TweetSent ? [UIColor blackColor] : [UIColor redColor]];
    textView.text = tweet.status == TweetIgnored ? [NSString stringWithFormat:@"TWITTER REJECTED: %@", tweet.message] : tweet.status == TweetFailed ? [NSString stringWithFormat:@"ERROR SENDING TO TWITTER: %@", tweet.message] : tweet.message;
    textView.font = tweet.status == TweetIgnored || tweet.status == TweetFailed ? [UIFont systemFontOfSize: 10] : [UIFont systemFontOfSize: 14];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 73.0;
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
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(populateViewFromModel)
                                                 name: @"UIApplicationWillEnterForegroundNotification"
                                               object: nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [ColorMaster getNavBarTintColor];
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
