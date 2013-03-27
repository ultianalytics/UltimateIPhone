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

@interface TeamPlayersViewController ()

@property (strong, nonatomic) IBOutlet UIView *playersView;
@property (nonatomic, strong) IBOutlet UITableView* playersTableView;
@property (nonatomic, strong) IBOutlet UILabel* playersTypeLabel;
@property (nonatomic, strong) IBOutlet UltimateSegmentedControl* playersTypeSegmentedControl;
@property (nonatomic, strong) IBOutlet UIButton* leagueVineTeamRefresh;
@property (strong, nonatomic) IBOutlet UILabel *noResultsFoundLabel;

@property (strong, nonatomic) IBOutlet UIView *waitingView;
@property (strong, nonatomic) IBOutlet UILabel *busyLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

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
}

-(void)animateTableViewResizeFrom: (CGRect)oldRect to: (CGRect)newRect {
    // TODO...animate
    self.playersTableView.frame = newRect;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *addNavBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd target:self action:@selector(goToAddItem)];
    self.navigationItem.rightBarButtonItem = addNavBarItem;  
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

-(void)showWaitingView {
    self.waitingView.hidden = NO;
}

-(void)hideWaitingView {
    [UIView  transitionFromView:self.waitingView toView:self.playersView duration:0.4 options: UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionTransitionFlipFromLeft completion:nil];
}

-(void)refreshPlayersFromLeagueVine {
    LeaguevineClient* lvClient = [[LeaguevineClient alloc] init];
    [lvClient retrievePlayersForTeam:[Team getCurrentTeam].leaguevineTeam.itemId completion:^(LeaguevineInvokeStatus status, id result) {
        [self handleLeagueViewRetrievalResponse:status result:result];
    }];
}

- (void)handleLeagueViewRetrievalResponse:(LeaguevineInvokeStatus)status result:(id)arrayOfLVPlayers {
    if (status == LeaguevineInvokeOK) {
        NSArray* players = [LeaguevinePlayer playersFromLeaguevinePlayers:arrayOfLVPlayers];
        [Team getCurrentTeam].players = [NSMutableArray arrayWithArray:players];
        [self.playersTableView reloadData];
        [self hideWaitingView];
        self.noResultsFoundLabel.hidden = [players count] > 0;
    } else {
        [self.spinner stopAnimating];
        [self alertFailure:status];
    }
}


#pragma mark Leaguevine Event Handlers

- (IBAction)playersTypeChanged:(id)sender {
    if (self.playersTypeSegmentedControl.selectedSegmentIndex == 1) {
        // TODO...warn that players will be replaced and replace if team has players
        [Team getCurrentTeam].arePlayersFromLeagueVine = YES;
        [self updateViewAnimated:YES];
    } else {
        // TODO...warn that players will be removed?
        [Team getCurrentTeam].arePlayersFromLeagueVine = NO;
        [self updateViewAnimated:YES];
    }
}

- (IBAction)refreshButtonPressed:(id)sender {
    [self refreshPlayersFromLeagueVine];
}

#pragma mark Leaguevine Error alerting

-(void)alertError:(NSString*) title message: (NSString*) message {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: title
                                                        message: message
                                                       delegate: nil
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles: nil];
    [alertView show];
}

-(void)alertFailure: (LeaguevineInvokeStatus) type {
    [self alertError:@"Error talking to Leaguevine" message:[self errorDescription:type]];
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


@end
