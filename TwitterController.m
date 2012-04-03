//
//  TwitterController.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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
#import "Constants.h"
#import "TweetLogViewController.h"

@implementation TwitterController
@synthesize twitterTableView,tweetEveryEventCell, tweetButtonCell, tweetEveryEventSwitch, twitterAccountCell, twitterAccountNameLabel,tweetLogTableView,recentTweetsCell;

NSArray* twitterCells;

UIAlertView* busyView;

-(IBAction)isTweetingEveryEventChanged: (id) sender {
    if (self.tweetEveryEventSwitch.on) {
        if ([[Tweeter getCurrent] getTwitterAccountName] == nil) {
            self.tweetEveryEventSwitch.on = NO;
            [TweetViewController alertNoAccount: self];
        } 
    }
    [Preferences getCurrentPreferences].isTweetingEvents =  self.tweetEveryEventSwitch.on;
    [[Preferences getCurrentPreferences] save];
}

-(IBAction)tweetButtonClicked: (id) sender; {
    // Create the view controller
    TweetViewController* tweetController = [[TweetViewController alloc] init];
    if (![[Tweeter getCurrent] isTweetingEvents]) {  // don't add the score if we are tweeting events...they'll get it via other tweets
        [tweetController setInitialText: [NSString stringWithFormat:@"%@.  ", [[Tweeter getCurrent] getGameScoreDescription: [Game getCurrentGame]]]];
    }
    
    // Show the controller
    [self.navigationController pushViewController:tweetController animated: YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // if user wants to set thier twitter account...take them to iphone settings
    if (buttonIndex == 1) {
        [TweetViewController goToTwitterSettings];
    } 
}


-(void)populateViewFromModel {;
    self.tweetEveryEventSwitch.on = [Preferences getCurrentPreferences].isTweetingEvents;
    NSString* currentAccount = [[Tweeter getCurrent] getTwitterAccountName];
    self.twitterAccountNameLabel.text = currentAccount == nil ? kNoAccountText : currentAccount;
    self.twitterAccountCell.accessoryType = currentAccount == nil ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
    [twitterTableView reloadData];
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
    self.tweetEveryEventSwitch.onTintColor = [ColorMaster getNavBarTintColor];
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
