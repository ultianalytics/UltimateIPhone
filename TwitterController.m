//
//  TwitterController.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 3/31/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "TwitterController.h"
#import "CloudViewController.h"
#import "Preferences.h"
#import "ColorMaster.h"
#import "Team.h"
#import "Game.h"
#import "Tweeter.h"
#import "TweetViewController.h"
#import "TwitterAccountPickViewController.h"
#import "TweetLogViewController.h"
#import "Reachability.h"

@interface TwitterController()

-(void)populateAccountCell;

@end

@implementation TwitterController
@synthesize twitterTableView,tweetEveryEventCell, tweetButtonCell, autoTweetSegmentedControl, twitterAccountCell, twitterAccountNameLabel,tweetLogTableView,recentTweetsCell;

+ (void)showNoConnectivityAlert {
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle: @"No Internet Access"
                          message: @"We are not able to connect to Twitter.  Please make sure you have Internet access."
                          delegate: nil
                          cancelButtonTitle: NSLocalizedString(@"OK",nil)
                          otherButtonTitles: nil];
    [alert show];
}

-(IBAction)autoTweetChanged: (id) sender {
    if (self.autoTweetSegmentedControl.selectedSegmentIndex != NoAutoTweet) {
        if ([[Tweeter getCurrent] getTwitterAccountName] == nil) {
            self.autoTweetSegmentedControl.selectedSegmentIndex = NoAutoTweet;
            [TweetViewController alertNoAccount: nil];
        } 
    }
    AutoTweetLevel level = self.autoTweetSegmentedControl.selectedSegmentIndex;
    if (level != NoAutoTweet && [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        [TwitterController showNoConnectivityAlert];
        self.autoTweetSegmentedControl.selectedSegmentIndex = NoAutoTweet;
        return;
    } else {
        [[Tweeter getCurrent] setAutoTweetLevel:level];
    }
}

-(IBAction)tweetButtonClicked: (id) sender; {
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        [TwitterController showNoConnectivityAlert];
    } else {
        // Create the view controller
        TweetViewController* tweetController = [[TweetViewController alloc] init];
        if (![[Tweeter getCurrent] isTweetingEvents]) {  // don't add the score if we are tweeting events...they'll get it via other tweets
            [tweetController setInitialText: [NSString stringWithFormat:@"%@.  ", [[Tweeter getCurrent] getGameScoreDescription: [Game getCurrentGame]]]];
        }
        
        // Show the controller
        [self.navigationController pushViewController:tweetController animated: YES];
    }
}


-(void)populateViewFromModel {;
    self.autoTweetSegmentedControl.selectedSegmentIndex = [[Tweeter getCurrent] getAutoTweetLevel];
    [twitterTableView reloadData];
}

-(void)populateAccountCell {
    NSString* currentAccount = [[Tweeter getCurrent] getTwitterAccountName];
    self.twitterAccountNameLabel.text = currentAccount == nil ? kNoAccountText : currentAccount;
    self.twitterAccountCell.accessoryType = currentAccount == nil ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[Tweeter getCurrent] getTwitterAccountName]) {
        twitterCells = [NSArray arrayWithObjects:tweetButtonCell, twitterAccountCell, tweetEveryEventCell, recentTweetsCell, nil];
    } else {
        twitterCells = [NSArray arrayWithObjects:tweetButtonCell, tweetEveryEventCell, recentTweetsCell, nil];
    }
    return [twitterCells count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [twitterCells objectAtIndex:[indexPath row]];
    if (cell == self.twitterAccountCell) {
        [self populateAccountCell];
    }
    cell.backgroundColor = [ColorMaster getFormTableCellColor];
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath { 
    UITableViewCell* cell = [twitterCells objectAtIndex:[indexPath row]];
    if (cell == twitterAccountCell && ![self.twitterAccountNameLabel.text isEqualToString: kNoAccountText]) {
        TwitterAccountPickViewController* pickController = [[TwitterAccountPickViewController alloc] init];
        [self.navigationController pushViewController:pickController animated: YES];
    } else if (cell == recentTweetsCell) {
        TweetLogViewController* logController = [[TweetLogViewController alloc] init];
        [self.navigationController pushViewController:logController animated:YES];                                
    }
} 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Tweeting", @"Tweeting");
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
    self.autoTweetSegmentedControl.tintColor = [ColorMaster getNavBarTintColor];
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
