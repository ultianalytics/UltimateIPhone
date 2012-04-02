//
//  CloudViewController.m
//  Ultimate
//
//  Created by Jim Geppert on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <Twitter/Twitter.h>
#import "CloudViewController.h"
#import "Preferences.h"
#import "ColorMaster.h"
#import "CloudClient.h"
#import "SignonViewController.h"
#import "Team.h"
#import "Game.h"
#import "Tweeter.h"
#import "TweetViewController.h"
#import "TwitterAccountPickViewController.h"
#import "Constants.h"

SignonViewController* signonController;

@implementation CloudViewController
@synthesize syncButton,uploadCell,userCell,websiteCell,adminSiteCell,userLabel,websiteLabel,adminSiteLabel,twitterTableView,cloudTableView,signoffButton, tweetEveryEventCell, tweetButtonCell, tweetEveryEventSwitch, twitterAccountCell, twitterAccountNameLabel;

NSArray* twitterCells;
NSArray* cloudCells;

UIAlertView* busyView;

-(IBAction)isTweetingEveryEventChanged: (id) sender {
    if (self.tweetEveryEventSwitch.on) {
        if ([Tweeter getTwitterAccountName] == nil) {
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
    if (![Tweeter isTweetingEvents]) {  // don't add the score if we are tweeting events...they'll get it via other tweets
        [tweetController setInitialText: [NSString stringWithFormat:@"%@.  ", [Tweeter getGameScoreDescription: [Game getCurrentGame]]]];
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

-(void)goSignonView{
    signonController = [[SignonViewController alloc] init];
    [self.navigationController pushViewController:signonController animated: YES];
}

-(void)populateViewFromModel {
    NSString* websiteURL = [CloudClient getWebsiteURL: [Team getCurrentTeam]];
    self.websiteLabel.text = websiteURL == nil ?  @"unknown (do upload)" : websiteURL;
    self.websiteCell.accessoryType = websiteURL == nil ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
    self.websiteCell.selectionStyle = websiteURL == nil ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleNone;
    NSString* userid = [Preferences getCurrentPreferences].userid;
    self.userLabel.text = userid == nil ? @"unknown (do upload)" : userid;
    self.signoffButton.hidden = userid == nil;
    self.tweetEveryEventSwitch.on = [Preferences getCurrentPreferences].isTweetingEvents;
    NSString* currentAccount = [Tweeter getTwitterAccountName];
    self.twitterAccountNameLabel.text = currentAccount == nil ? kNoAccountText : currentAccount;
    self.twitterAccountCell.accessoryType = currentAccount == nil ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
    [twitterTableView reloadData];
}

-(IBAction)syncButtonClicked: (id) sender {
    [self upload];
}

-(void)upload {
    [self startBusyDialog];
    [self performSelectorInBackground:@selector(doUpload) withObject:nil];
}

-(void)doUpload {
    NSError* uploadError = nil;
    //[CloudClient uploadTeam:[Team getCurrentTeam] error: &uploadError];
    [CloudClient uploadTeam:[Team getCurrentTeam] withGames:[ Game getAllGameFileNames] error: &uploadError];
    [self stopBusyDialog];
    if (uploadError) {
        if (uploadError.code == Unauthorized) {
            [self goSignonView];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] 
                                  initWithTitle: NSLocalizedString(@"Upload FAILED",nil)
                                  message: NSLocalizedString(@"We were unable to upload your data to the cloud.  Try again later.",nil)
                                  delegate: self
                                  cancelButtonTitle: NSLocalizedString(@"OK",nil)
                                  otherButtonTitles: nil];
            [alert show];
        }
    } else {
        [self populateViewFromModel];
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle: NSLocalizedString(@"Upload Complete",nil)
                              message: NSLocalizedString(@"Your data was successfully uploaded to the cloud",nil)
                              delegate: self
                              cancelButtonTitle: NSLocalizedString(@"OK",nil)
                              otherButtonTitles: nil];
        [alert show];
    }
}


-(void)startBusyDialog {
    busyView = [[UIAlertView alloc] initWithTitle: @"Uploading data to cloud..."
                                          message: nil
                                         delegate: self
                                cancelButtonTitle: nil
                                otherButtonTitles: nil];
    // Add a spinner
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.frame = CGRectMake(50,50, 200, 50);
    [busyView addSubview:spinner];
    [spinner startAnimating];
    
    [busyView show];
}

-(void)stopBusyDialog {
    if (busyView) {
        [busyView dismissWithClickedButtonIndex:0 animated:NO];
        [busyView removeFromSuperview];
    }
}

-(IBAction)signoffButtonClicked: (id) sender {
    [CloudClient signOff];
    [self populateViewFromModel];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.twitterTableView) {
        if ([Tweeter getTwitterAccountName]) {
            twitterCells = [NSArray arrayWithObjects:tweetButtonCell, twitterAccountCell, tweetEveryEventCell, nil];
        } else {
            twitterCells = [NSArray arrayWithObjects:tweetButtonCell, tweetEveryEventCell, nil];
        }
        return [twitterCells count];
    } else {
        cloudCells = [NSArray arrayWithObjects:uploadCell, userCell, websiteCell, adminSiteCell, nil];
        return [cloudCells count];
    }
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = tableView == self.twitterTableView ? [twitterCells objectAtIndex:[indexPath row]] : [cloudCells objectAtIndex:[indexPath row]];
    cell.backgroundColor = [ColorMaster getFormTableCellColor];
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath { 
    if (tableView == cloudTableView) {
        if (tableView == self.cloudTableView) {
            UITableViewCell* cell = [cloudCells objectAtIndex:[indexPath row]];
            if (cell == websiteCell) {
                NSString* websiteURL = [CloudClient getWebsiteURL: [Team getCurrentTeam]];
                if (websiteURL != nil) {
                    NSURL *url = [NSURL URLWithString:websiteURL];
                    [[UIApplication sharedApplication] openURL:url];
                }
            } else if (cell == adminSiteCell) {
                NSString* adminUrl = adminSiteLabel.text;
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:adminUrl]];
            } 
        }
    }
    else {
        UITableViewCell* cell = [twitterCells objectAtIndex:[indexPath row]];
        if (cell == twitterAccountCell && ![self.twitterAccountNameLabel.text isEqualToString: kNoAccountText]) {
            TwitterAccountPickViewController* pickController = [[TwitterAccountPickViewController alloc] init];
            [self.navigationController pushViewController:pickController animated: YES];
        }
    }
} 


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Cloud", @"Cloud");
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
    if (signonController && signonController.isSignedOn) {
        [self doUpload];
    }
    signonController = nil;
    
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
