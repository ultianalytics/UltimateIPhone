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
#import "LeagueVinePlayerNameTransformer.h"
#import "LeaguevineWaitingViewController.h"
#import "AppDelegate.h"
#import "CalloutsContainerView.h"
#import "CalloutView.h"
#import "UIScrollView+Utilities.h"
#import "PlayerDetailsViewController.h"

#define kAlertErrorTitle @"Error talking to Leaguevine"
#define kAlertPrivateToLeagueVineTitle @"Players will be deleted!"
#define kAlertPrivateToLeagueVineNotAllowedTitle @"Cannot switch to leaguevine" 
#define kAlertLeagueVineToPrivateNotAllowedTitle @"Cannot switch to private"
#define kAlertLeaguevineToPrivateTitle @"Switching to private players" 

@interface TeamPlayersViewController () <UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *playersView;
@property (strong, nonatomic) IBOutlet UIView *leaguevinePlayersView;
@property (nonatomic, strong) IBOutlet UITableView* playersTableView;
@property (nonatomic, strong) IBOutlet UILabel* playersTypeLabel;
@property (nonatomic, strong) IBOutlet UltimateSegmentedControl* playersTypeSegmentedControl;
@property (nonatomic, strong) IBOutlet UIButton* leagueVineTeamRefresh;
@property (strong, nonatomic) IBOutlet UILabel *noResultsFoundLabel;
@property (strong, nonatomic) IBOutlet UILabel *leaguevinePlayersDownloadedLabel;

@property (strong, nonatomic) NSArray* players;

@property (strong, nonatomic) UIBarButtonItem *addNavBarItem;
@property (strong, nonatomic) LeaguevineWaitingViewController* waitingViewController;

@property (strong, nonatomic) void (^alertAction)();

@property (nonatomic) BOOL hasShownLVPlayerStatsCallout;

@end

@implementation TeamPlayersViewController

-(void)goToAddItem {
    if (IS_IPHONE) {
        PlayerDetailsViewController* playerController = [[PlayerDetailsViewController alloc] init];
        [self.navigationController pushViewController:playerController animated:YES];
    } else {
        PlayerDetailsViewController* addPlayerController = [[PlayerDetailsViewController alloc] init];
        addPlayerController.isModalAddMode = YES;
        [self registerDetailControllerListener:addPlayerController];
        UINavigationController* addPlayerNavController = [[UINavigationController alloc] initWithRootViewController:addPlayerController];
        addPlayerNavController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:addPlayerNavController animated:YES completion:nil];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
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
            y = 136;
        } else {
            y = 78;
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
    self.noResultsFoundLabel.hidden = [self.players count] > 0;
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

-(void)retrievePlayers {
    self.players = [[Team getCurrentTeam].players sortedArrayUsingComparator:^(id a, id b) {
        NSString* playerNameA = ((Player*)a).name;
        NSString* playerNameB = ((Player*)b).name;
        return [playerNameA caseInsensitiveCompare:playerNameB];
    }];
}

- (void)refresh {
    NSString* currentlySelectedPlayerName = [self currentlySelectedPlayerName];
    [self retrievePlayers];
    [self updateViewAnimated: NO];
    if ([self.players count] > 0) {
        Player* player;
        if (currentlySelectedPlayerName) {
            player = [self playerNamed:currentlySelectedPlayerName];
        }
        if (!player) {
            player = self.players[0];
        }
        [self selectPlayer:player animated:YES];
    }
}

-(NSString*)currentlySelectedPlayerName {
    NSIndexPath* currentPath = [self.playersTableView indexPathForSelectedRow];
    if (currentPath) {
        UITableViewCell* cell = [self.playersTableView cellForRowAtIndexPath:currentPath];
        return cell.textLabel.text;
    }
    return nil;
}

-(Player*)playerNamed: (NSString*) playerName {
    for (Player* player in self.players) {
        if ([playerName isEqualToString:player.name]) {
            return player;
        }
    }
    return nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.addNavBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd target:self action:@selector(goToAddItem)];
    [self.playersTableView adjustInsetForTabBar];
    [self retrievePlayers];
    if (IS_IPAD) {
        [self addReturnToTeamBackButton];
        [self.playersTableView reloadData];
        if ([self.players count] > 0) {
            [self selectPlayer:self.players[0] animated:NO];
        }
    }
    self.title = IS_IPAD ? [Team getCurrentTeam].name : [NSString stringWithFormat:@"%@: %@", @"Players",[Team getCurrentTeam].name];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refresh];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[Team getCurrentTeam] isLeaguevineTeam]) {
        if (!([self.players count] > 0) && ![[Team getCurrentTeam] arePlayersFromLeagueVine]) {
            if (!self.hasShownLVPlayerStatsCallout) {
                [self showUseLeaguevinePlayersIfWantPlayersStats];
                self.hasShownLVPlayerStatsCallout = YES;
            }
        }
    }
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

#pragma mark - Table Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.players count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    Player* player = [self.players objectAtIndex:row];
    NSString* primaryName = player.name;
    if (player.number != nil && ![player.number isEqualToString:@""]) {
        primaryName = [NSString stringWithFormat:@"%@ (%@)", primaryName, player.number];
    }
    
    BOOL isLeaguevinePlayers = [Team getCurrentTeam].arePlayersFromLeagueVine;
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: isLeaguevinePlayers ? @"LEAGUEVINE_PLAYER" : @"PRIVATE_PLAYER"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:isLeaguevinePlayers ? UITableViewCellStyleSubtitle : UITableViewCellStyleDefault
                reuseIdentifier:STD_ROW_TYPE];
        cell.imageView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [ColorMaster getFormTableCellColor];
    }
    
    cell.textLabel.text = primaryName;
    cell.accessoryType = isLeaguevinePlayers || IS_IPAD ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
    if (isLeaguevinePlayers) {
        cell.detailTextLabel.text = [NSString stringWithFormat: @"%@ %@", player.leaguevinePlayer.firstName, player.leaguevinePlayer.lastName];
    } else {
        cell.imageView.image = player.isAbsent ? [ImageMaster getNeutralGenderAbsentImage] : [ImageMaster getNeutralGenderImage];
    }
    cell.textLabel.textColor = player.isAbsent ? uirgb(160, 160, 160) : [UIColor blackColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Player* player = [self.players objectAtIndex:[indexPath row]];
    if (IS_IPAD) {
        self.detailController.player = player;
    } else {
        PlayerDetailsViewController* playerController = [[PlayerDetailsViewController alloc] init];
        playerController.player = player;
        [self.navigationController pushViewController:playerController animated:YES];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return [Team getCurrentTeam].arePlayersFromLeagueVine ? nil : indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kSingleSectionGroupedTableSectionHeaderHeight;
}


#pragma mark - iPad (Master/Detail UX)

-(void)setDetailController:(PlayerDetailsViewController *)detailController {
    _detailController = detailController;
    [self registerDetailControllerListener: detailController];
}

-(void)selectPlayer: (Player*) player animated: (BOOL)animated {
    if ([self.players count] > 0) {
        int playerIndex = 0;
        for (int row = 0; row < [self.players count]; row++) {
            if ([[self.players[row] name] isEqualToString:player.name]) {
                playerIndex = row;
                break;
            }
        }
        self.detailController.player = self.players[playerIndex];
        [self.playersTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:playerIndex inSection:0] animated:animated scrollPosition:UITableViewScrollPositionNone];
    }
}

-(void)registerDetailControllerListener:(PlayerDetailsViewController *)detailController {
    __typeof(self) __weak weakSelf = self;
    detailController.playerChangedBlock = ^(Player* player) {
        [weakSelf retrievePlayers];
        if ([self.players count] > 0) {
            [weakSelf.playersTableView reloadData];
            [weakSelf selectPlayer: player animated: NO];
        }
        [weakSelf notifyPlayersChangedListener];
    };
}

-(void)addReturnToTeamBackButton {
    // create a custom view (a button)
    UIImage* backCaretImage = [UIImage imageNamed:@"left-caret-green"];
    UIButton* backButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 70, backCaretImage.size.height)];
    [backButton setImage:backCaretImage forState:UIControlStateNormal];
    [backButton setTitle:@" Team" forState:UIControlStateNormal];
    [backButton setTitleColor:[ColorMaster applicationTintColor] forState:UIControlStateNormal];
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [backButton addTarget:self action:@selector(returnToTeam) forControlEvents:UIControlEventTouchUpInside];
    
    // add the button to the nav bar
    UIBarButtonItem* backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
}

-(void)returnToTeam {
    if (self.backRequestedBlock) {
        self.backRequestedBlock();
    }
}

-(void)notifyPlayersChangedListener {
    if (self.playersChangedBlock) {
        self.playersChangedBlock();
    }
}

#pragma mark - Leaguevine

-(void)refreshPlayersFromLeagueVine {
    self.waitingViewController = [[LeaguevineWaitingViewController alloc] init];
    self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    __weak TeamPlayersViewController* weakSelf = self;
    self.waitingViewController.cancelBlock = ^{
        [weakSelf dismissWaitingViewWithSuccess: NO];
    };
    [self presentViewController:self.waitingViewController animated:YES completion:^{
        [self performSelectorInBackground:@selector(startLeaguevinePlayerRetrieve) withObject:nil];
    }];
}

-(void)startLeaguevinePlayerRetrieve {
    LeaguevineClient* lvClient = [[LeaguevineClient alloc] init];
    [lvClient retrievePlayersForTeam:[Team getCurrentTeam].leaguevineTeam.itemId completion:^(LeaguevineInvokeStatus status, id result) {
        [self handleLeagueViewRetrievalResponse:status result:result];
    }];
}

- (void)handleLeagueViewRetrievalResponse:(LeaguevineInvokeStatus)status result:(id)arrayOfLVPlayers {
    if (self.waitingViewController) {  // nil if cancelled
        if (status == LeaguevineInvokeOK) {
            NSMutableArray* updatedPlayers = [NSMutableArray arrayWithArray: self.players];
            [[LeagueVinePlayerNameTransformer transformer]  updatePlayers:updatedPlayers playersFromLeaguevine:arrayOfLVPlayers];
            [Team getCurrentTeam].players = updatedPlayers;
            [[Team getCurrentTeam] save];
            [self retrievePlayers];
            [self updateViewAnimated:NO];
            [self dismissWaitingViewWithSuccess:YES];
            [((AppDelegate*)[[UIApplication sharedApplication]delegate]) resetGameTab];

        } else {
            [self alertFailure:status];
        }
    }
}

-(void)updateLeagueVineRefreshButtonText {
    [self.leagueVineTeamRefresh setTitle:[self.players count] > 0 ? @"Refresh" : @"Download Players" forState:UIControlStateNormal];
}

-(void)brieflyShowLeaguvineDownloadSuccessMessage {
    self.leaguevinePlayersDownloadedLabel.hidden = NO;
    [UIView animateWithDuration:1 delay:2 options:UIViewAnimationOptionCurveEaseIn  animations:^{
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
        for (Player* player in self.players) {
            player.leaguevinePlayer = nil;
        }
        [[Team getCurrentTeam] save];
        [self updateViewAnimated:YES];
    }
    [self notifyPlayersChangedListener];
}

-(void)dismissWaitingViewWithSuccess: (BOOL)success {
    if (success) {
        [self brieflyShowLeaguvineDownloadSuccessMessage];
    }
    self.waitingViewController = nil;
    [self dismissViewControllerAnimated:YES completion:^{
        self.waitingViewController = nil;
    }];
}

-(void)showUseLeaguevinePlayersIfWantPlayersStats {
        
    CalloutsContainerView *calloutsView = [[CalloutsContainerView alloc] initWithFrame:self.view.bounds];
    
    CGPoint anchor = CGPointTop(self.view.bounds);
    anchor.y = anchor.y + 50;
    anchor.x = anchor.x + 50;
    [calloutsView addCallout:@"NOTE: You can post SCORES to leaguevine with private players but you must choose \"Leaguevine\" players if you want to post PLAYER STATS to leaguevine." anchor: anchor width: 260 degrees: 200 connectorLength: 120 font: [UIFont systemFontOfSize:16]];
    
    [self.view addSubview:calloutsView];
    
    // move the callouts off the screen and then animate their return.
    [calloutsView slide: YES animated: NO];
    [calloutsView slide: NO animated: YES];
    
}

#pragma mark Leaguevine Event Handlers

- (IBAction)playersTypeChanged:(id)sender {
    if (self.playersTypeSegmentedControl.selectedSegmentIndex == 1) {
        if (([Team getCurrentTeam].cloudId != nil) || [[Team getCurrentTeam] hasGames]) {
            self.playersTypeSegmentedControl.selectedSegmentIndex = 0;
            [self alertTransitionToLeaguevinePlayersNotAllowed];
            return;
        }
    } else if (self.playersTypeSegmentedControl.selectedSegmentIndex == 0) {
        if (([Team getCurrentTeam].cloudId != nil) || [[Team getCurrentTeam] hasGames]) {
            self.playersTypeSegmentedControl.selectedSegmentIndex = 1;
            [self alertTransitionToPrivatePlayersNotAllowed];
            return;
        }
    }
    if ([self.players count] > 0) {
        if (self.playersTypeSegmentedControl.selectedSegmentIndex == 1) {
            [self alertTransitionToLeaguevinePlayers];
        } else {
            [self alertTransitionFromLeaguevinePlayers];
            [self.playersTableView reloadData];
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
                                                       delegate: nil
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles: nil];
    [alertView show];
}

-(void)alertTransitionToPrivatePlayersNotAllowed {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: kAlertLeagueVineToPrivateNotAllowedTitle
                                                        message: @"The players on this team cannot be converted to private players because the team already has games on this iPhone or uploaded to the website.\n\nPlease create a new team."
                                                       delegate: nil
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
            [self.playersTableView reloadData];
        } else {
            self.playersTypeSegmentedControl.selectedSegmentIndex = 0;
        }
    } else if ([alertView.title isEqualToString: kAlertLeaguevineToPrivateTitle]) {
        if (buttonIndex == 1) {
            [self switchToLeaguevinePlayers: NO];
            [self.playersTableView reloadData];
        } else {
            self.playersTypeSegmentedControl.selectedSegmentIndex = 1;
        }
    } else if ([alertView.title isEqualToString: kAlertErrorTitle]) {
        [self updateViewAnimated: NO];
        [self dismissWaitingViewWithSuccess:NO];
    }
    
}

@end
