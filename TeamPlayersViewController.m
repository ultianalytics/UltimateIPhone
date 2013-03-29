//
//  TeamPlayersViewController.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 4/5/12.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "TeamPlayersViewController.h"
#import "PlayerDetailsViewController.h"
#import "Team.h"
#import "ImageMaster.h"
#import "Player.h"
#import "UltimateSegmentedControl.h"
#import "ColorMaster.h"
#import "LeaguevineClient.h"
#import "LeaguevineTeam.h"
#import "LeaguevinePlayer.h"

#define kAlertErrorTitle @"Error talking to Leaguevine"
#define kAlertPrivateToLeagueVineTitle @"Players will be deleted!"
#define kAlertPrivateToLeagueVineNotAllowedTitle @"Cannot switch to leaguevine" 
#define kAlertLeaguevineToPrivateTitle @"Switching to private players" 

@interface TeamPlayersViewController () <UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *playersView;
@property (nonatomic, strong) IBOutlet UITableView* playersTableView;
@property (nonatomic, strong) IBOutlet UILabel* playersTypeLabel;
@property (nonatomic, strong) IBOutlet UltimateSegmentedControl* playersTypeSegmentedControl;
@property (nonatomic, strong) IBOutlet UIButton* leagueVineTeamRefresh;
@property (strong, nonatomic) IBOutlet UILabel *noResultsFoundLabel;
@property (strong, nonatomic) IBOutlet UILabel *leaguevinePlayersDownloadedLabel;

@property (strong, nonatomic) UIBarButtonItem *addNavBarItem;

@property (strong, nonatomic) IBOutlet UIView *waitingView;
@property (strong, nonatomic) IBOutlet UILabel *busyLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (strong, nonatomic) void (^alertAction)();

@end

@implementation TeamPlayersViewController
@synthesize playersTableView;

-(void)goToAddItem {
    PlayerDetailsViewController* playerController = [[PlayerDetailsViewController alloc] init];
    [self.navigationController pushViewController:playerController animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[Team getCurrentTeam] players] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    Player* player = [[[Team getCurrentTeam] players] objectAtIndex:row];
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: STD_ROW_TYPE];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:STD_ROW_TYPE];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.backgroundColor = [UIColor clearColor];
    }
    cell.imageView.image = player.isMale ?[ImageMaster getMaleImage] : [ImageMaster getFemaleImage];
    
    NSString* text = player.name;
    if (player.number != nil && ![player.number isEqualToString:@""]) {
        text = [NSString stringWithFormat:@"%@ (%@)", text, player.number];
    }
    cell.textLabel.text = text;
    cell.backgroundColor = [ColorMaster getFormTableCellColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath { 
    NSUInteger row = [indexPath row]; 
    NSArray* players = [Team getCurrentTeam].players;
    Player* player = [players objectAtIndex:row];
    
    PlayerDetailsViewController* playerController = [[PlayerDetailsViewController alloc] init];
    playerController.player = player;
    [self.navigationController pushViewController:playerController animated:YES];
} 


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       self.title = NSLocalizedString(@"Players", @"Players");
    }
    return self;
}

-(void)updateViewAnimated: (BOOL) animate {
    self.playersTypeSegmentedControl.selectedSegmentIndex = [[Team getCurrentTeam] arePlayersFromLeagueVine] ? 1 : 0;
    CGFloat y = 0;
    if ([[Team getCurrentTeam] isLeaguevineTeam]) {
        if ([[Team getCurrentTeam] arePlayersFromLeagueVine]) {
            [self updateLeagueVineRefreshButtonText];
            y = 111;
        } else {
            y = 54;
        }
    }
    CGRect newRect = self.view.bounds;
    newRect.origin.y = y;
    newRect.size.height = newRect.size.height - y;
    if (animate) {
        [self animateTableViewResizeFrom:self.playersTableView.frame to:newRect];
    } else {
        self.playersTableView.frame = newRect;
    }
    [self.playersTableView reloadData];
    self.noResultsFoundLabel.hidden = [[Team getCurrentTeam].players count] > 0;
    [self updateAddButton];
}

-(void)animateTableViewResizeFrom: (CGRect)oldRect to: (CGRect)newRect {
    [UIView animateWithDuration:.3 animations:^{
        self.playersTableView.frame = newRect;
    }];
}

-(void)updateAddButton {
    self.navigationItem.rightBarButtonItem = ![[Team getCurrentTeam] isLeaguevineTeam] || ![[Team getCurrentTeam] arePlayersFromLeagueVine] ? self.addNavBarItem : nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.addNavBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd target:self action:@selector(goToAddItem)];
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIFont boldSystemFontOfSize:16.0], UITextAttributeFont, nil]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Players", @"Players"),[Team getCurrentTeam].name];
    [[Team getCurrentTeam] sortPlayers];
    [self updateViewAnimated: NO];
}

- (void)viewDidUnload
{
    [self setLeaguevinePlayersDownloadedLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Leaguevine

-(void)showWaitingView: (BOOL)show animate: (BOOL)animate {
    if (animate) {
        UIView* fromView = show ? self.playersView : self.waitingView;
        UIView* toView = show ? self.waitingView : self.playersView;
        [UIView  transitionFromView:fromView toView:toView duration:0.4 options: UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionTransitionFlipFromLeft completion:nil];
        if (show) {
            [self.spinner startAnimating];
        } else {
            [self.spinner startAnimating];            
        }
    } else {
        self.waitingView.hidden = !show;
    }
}

-(void)refreshPlayersFromLeagueVine {
    [self showWaitingView:YES animate:YES];
    LeaguevineClient* lvClient = [[LeaguevineClient alloc] init];
    [lvClient retrievePlayersForTeam:[Team getCurrentTeam].leaguevineTeam.itemId completion:^(LeaguevineInvokeStatus status, id result) {
        [self handleLeagueViewRetrievalResponse:status result:result];
    }];
}

- (void)handleLeagueViewRetrievalResponse:(LeaguevineInvokeStatus)status result:(id)arrayOfLVPlayers {
    if (status == LeaguevineInvokeOK) {
        NSArray* players = [LeaguevinePlayer playersFromLeaguevinePlayers:arrayOfLVPlayers];
        [Team getCurrentTeam].players = [NSMutableArray arrayWithArray:players];
        [[Team getCurrentTeam] save];
        [self updateViewAnimated:NO];
        [self showWaitingView:NO animate:YES];
        [self brieflyShowLeaguvineDownloadSuccessMessage];
    } else {
        [self.spinner stopAnimating];
        [self alertFailure:status];
    }
}

-(void)updateLeagueVineRefreshButtonText {
    [self.leagueVineTeamRefresh setTitle:[[Team getCurrentTeam].players count] > 0 ? @"Refresh" : @"Download Players" forState:UIControlStateNormal];
}

-(void)brieflyShowLeaguvineDownloadSuccessMessage {
    self.leaguevinePlayersDownloadedLabel.hidden = NO;
    [UIView animateWithDuration:3 animations:^{
        self.leaguevinePlayersDownloadedLabel.alpha = 0;
    } completion:^(BOOL finished) {
        self.leaguevinePlayersDownloadedLabel.alpha = 1;
        self.leaguevinePlayersDownloadedLabel.hidden = YES;
    }];
}

-(void)switchToLeaguevinePlayers: (BOOL)toLeaguevine {
    if (toLeaguevine) {
        [Team getCurrentTeam].arePlayersFromLeagueVine = YES;
        [[Team getCurrentTeam].players removeAllObjects];
        [[Team getCurrentTeam] save];
        [self updateViewAnimated:NO];
        [self refreshPlayersFromLeagueVine];
    } else {
        [Team getCurrentTeam].arePlayersFromLeagueVine = NO;
        for (Player* player in [Team getCurrentTeam].players) {
            player.leaguevinePlayer = nil;
        }
        [[Team getCurrentTeam] save];
        [self updateViewAnimated:YES];
    }
}

#pragma mark Leaguevine Event Handlers

- (IBAction)playersTypeChanged:(id)sender {
    if (self.playersTypeSegmentedControl.selectedSegmentIndex == 1) {
        if (([Team getCurrentTeam].cloudId != nil) || [[Team getCurrentTeam] hasGames]) {
            self.playersTypeSegmentedControl.selectedSegmentIndex = 0;
            [self alertTransitionToLeaguevinePlayersNotAllowed];
            return;
        }
    }
    if ([[Team getCurrentTeam].players count] > 0) {
        if (self.playersTypeSegmentedControl.selectedSegmentIndex == 1) {
            [self alertTransitionToLeaguevinePlayers];
        } else {
            [self alertTransitionFromLeaguevinePlayers];
        }
    } else {
        [self switchToLeaguevinePlayers:self.playersTypeSegmentedControl.selectedSegmentIndex == 1];
    }
}

- (IBAction)refreshButtonPressed:(id)sender {
    [self refreshPlayersFromLeagueVine];
}

#pragma mark Leaguevine Alerts

-(void)alertTransitionToLeaguevinePlayersNotAllowed {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: kAlertPrivateToLeagueVineNotAllowedTitle
                                                        message: @"The players on this team cannot be converted to leaguevine players because the team already has games on this iPhone or uploaded to the website.\n\nPlease create a new team."
                                                       delegate: self
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles: nil];
    [alertView show];
}

-(void)alertTransitionToLeaguevinePlayers {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: kAlertPrivateToLeagueVineTitle
                                                        message: @"Switching to leaguevine players will delete all existing players.\n\nContinue?"
                                                       delegate: self
                                              cancelButtonTitle: @"Cancel"
                                              otherButtonTitles: @"Continue", nil];
    [alertView show];
}

-(void)alertTransitionFromLeaguevinePlayers {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: kAlertLeaguevineToPrivateTitle
                                                        message: @"Switching to private players will keep existing player names but you will not be able to publish players stats to leaguevine.\n\nContinue?"
                                                       delegate: self
                                              cancelButtonTitle: @"Cancel"
                                              otherButtonTitles: @"Continue", nil];
    [alertView show];
}

-(void)alertFailure: (LeaguevineInvokeStatus) type {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: kAlertErrorTitle
                                                        message: [self errorDescription:type]
                                                       delegate: self
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles: nil];
    [alertView show];
}

-(NSString*)errorDescription: (LeaguevineInvokeStatus) type {
    switch(type) {
        case LeaguevineInvokeNetworkError:
            return @"Network error detected...are you connected to the internet?";
        case LeaguevineInvokeInvalidResponse:
            return @"Leaguevine is having problems. Try later";
        default:
            return @"Unkown error. Try later";
    }
}

#pragma mark Leaguevine alert delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqualToString: kAlertPrivateToLeagueVineTitle]) {
        if (buttonIndex == 1) {
            [self switchToLeaguevinePlayers: YES];
        } else {
            self.playersTypeSegmentedControl.selectedSegmentIndex = 0;
        }
    } else if ([alertView.title isEqualToString: kAlertLeaguevineToPrivateTitle]) {
        if (buttonIndex == 1) {
            [self switchToLeaguevinePlayers: NO];
        } else {
            self.playersTypeSegmentedControl.selectedSegmentIndex = 1;
        }
    } else if ([alertView.title isEqualToString: kAlertErrorTitle]) {
        [self updateViewAnimated: NO];
        [self showWaitingView:NO animate:YES];
    }
    
}

@end
