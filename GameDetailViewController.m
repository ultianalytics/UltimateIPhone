//
//  GameDetailViewController.m
//  Ultimate
//
//  Created by Jim Geppert on 2/18/12.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "GameDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Game.h"
#import "Preferences.h"
#import "SoundPlayer.h"
#import "ColorMaster.h"
#import "WindViewController.h"
#import "StatsViewController.h"
#import "GameHistoryController.h"
#import "GameViewController.h"
#import "GamePositionalViewController.h"
#import "Wind.h"
#import "NSString+manipulations.h"
#import "Constants.h"
#import "Team.h"
#import "LeagueVineGameViewController.h"
#import "LeaguevineGame.h"
#import "LeagueVineSignonViewController.h"
#import "LeaguevineClient.h"
#import "LeaguevineEventQueue.h"
#import "TimeoutViewController.h"
#import "GamePlaybackViewController.h"
#import "GameStartTimeViewController.h"
#import "UIViewController+Additions.h"
#import "CalloutsContainerView.h"
#import "UIView+Convenience.h"
#import "SHSAnalytics.h"
#import "GameFieldDimensionsViewController.h"

#define kLowestGamePoint 9
#define kHeaderHeight 50
#define kEmptyHeaderHeight 30

#define kAlertTitleDeleteGame @"Delete Game"
#define kAlertLeaguevineStatsNotAllowedWithPrivatePlayers @"Team Not Setup for LV Stats"
#define kAlertLeaguevineStatsEnding @"Stats Posting Ending"
#define kAlertLeaguevineStatsStarting @"Posting Stats to Leaguevine"
#define kAlertLeaguevineStatsStartingWithGameInProgress @"Warning: Game Started"
#define kAlertOpeningFinishedGame @"Game Is Over"
#define kAlertConfirmPositionalToNormalSwitch @"No so fast!"

#define kIsNotFirstGameStartUsage @"IsNotFirstGameStartUsage"


@interface GameDetailViewController()

@property (nonatomic, strong) NSDateFormatter* dateFormat;
@property (nonatomic, strong) NSMutableArray* cells;

@property (nonatomic, strong) IBOutlet UITableView* tableView;

@property (nonatomic, strong) IBOutlet UITableViewCell* initialLineCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* gamePointsCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* windCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* statsCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* eventsCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* gameTypeCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* timeoutsCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* opponentRegularCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* opponentLeaguevineCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* tournamentCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* leaguevinePubCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* positionalEventsCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* fieldDimensionsCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* playbackCell;

@property (strong, nonatomic) IBOutlet UIView *footerView;

@property (nonatomic, strong) IBOutlet UILabel* windLabel;
@property (nonatomic, strong) IBOutlet UILabel* leaguevineGameLabel;
@property (nonatomic, strong) IBOutlet UILabel* fieldDimensionsLabel;
@property (nonatomic, strong) IBOutlet UITextField* opposingTeamNameField;
@property (nonatomic, strong) IBOutlet UITextField* tournamentNameField;
@property (nonatomic, strong) IBOutlet UIView* deleteButtonView;
@property (nonatomic, strong) IBOutlet UIView* startButtonView;
@property (nonatomic, strong) IBOutlet UISegmentedControl* initialLine;
@property (nonatomic, strong) IBOutlet UISegmentedControl* gamePointsSegmentedControl;
@property (nonatomic, strong) IBOutlet UISegmentedControl* gameTypeSegmentedControl;
@property (nonatomic, strong) IBOutlet UISegmentedControl* pubToLeaguevineSegmentedControl;
@property (nonatomic, strong) IBOutlet UISegmentedControl* positionalEventsSegmentedControl;

@property (nonatomic, strong) CalloutsContainerView *calloutsViewContainer;

@end

@implementation GameDetailViewController

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.dateFormat = [[NSDateFormatter alloc] init];
        [self.dateFormat setDateFormat:@"EEE MMM d h:mm a"];
    }
    return self;
}


#pragma mark - Cell configuring

-(void)configureCells {
    BOOL needsLeaguevineModeTransition = [self isTableConfiguredForLeaguevineMode] && ![self isLeaguevineMode];
    
    self.cells = [NSMutableArray array];
    
    if ([[Team getCurrentTeam] isLeaguevineTeam]) {
        [self.cells addObject:self.gameTypeCell];
    }
    if ([self isLeaguevineMode]) {
        [self.cells addObjectsFromArray:@[self.opponentLeaguevineCell, self.leaguevinePubCell]];
    } else {
        [self.cells addObjectsFromArray:@[self.opponentRegularCell, self.tournamentCell]];
    }
    [self.cells addObjectsFromArray:@[self.initialLineCell, self.gamePointsCell]];
    if (IS_IPAD) {
        [self.cells addObject:self.positionalEventsCell];
    }
    if (self.game.isPositional) {
        [self.cells addObjectsFromArray:@[self.fieldDimensionsCell]];
        if ([self.game hasEvents]) {
            [self.cells addObjectsFromArray:@[self.playbackCell]];
        }
    }
    [self.cells addObjectsFromArray:@[self.timeoutsCell]];
    if ([self.game hasBeenSaved]) {
        [self.cells addObjectsFromArray:@[self.statsCell, self.eventsCell, self.windCell]];
    } else {
        [self.cells addObjectsFromArray:@[self.windCell]];
    }
    
    // animate transitions from/to leaguevine mode
    if (needsLeaguevineModeTransition) {
        NSArray* cellsToTransition = @[[NSIndexPath indexPathForRow:1 inSection:0], [NSIndexPath indexPathForRow:2 inSection:0]];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:cellsToTransition withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView insertRowsAtIndexPaths:cellsToTransition withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

-(BOOL)isLeaguevineMode {
    return ([self.game isLeaguevineGame] || [self isLeaguevineType]);
}

-(BOOL)isTableConfiguredForLeaguevineMode {
    for (UITableViewCell* cell in self.cells) {
        if (cell == self.opponentLeaguevineCell) {
            return YES;
        }
    }
    return NO;
}

-(void)reconfigureCells {
    [self.tableView reloadData];
    [UIView transitionWithView:self.view duration:0.5f options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void) {

    } completion:nil];
}

#pragma mark - Event Handlers

-(void)dateTimeButtonTapped {
    [self showDateTimePicker];
}

-(void)actionButtonTapped {
    if (IS_IPHONE && [Game getCurrentGame].isPositional) {
        [self showPositionalGameNotAllowedOnIPhoneAlert];
    } else {
        if ([[Game getCurrentGame] isTimeBasedEnd] && [self.game doesGameAppearDone]) {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:kAlertOpeningFinishedGame message:@"This game is over.  You can correct events without re-opening it by using the Events view.\n\nDo you really want to re-open this game?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            [alertView show];
        } else {
            [self goToActionView];
        }
    }
}

-(IBAction)opponentNameChanged: (id) sender {
    self.game.opponentName = [self.opposingTeamNameField.text trim];
    [self upateViewTitle];
    [self saveChanges];
}

-(IBAction)tournamendNameChanged: (id) sender {
    self.game.tournamentName = [self.tournamentNameField.text trim];
    [Preferences getCurrentPreferences].tournamentName = self.game.tournamentName;
    [[Preferences getCurrentPreferences] save];
    [self saveChanges];
}

-(IBAction)firstLineChanged: (id) sender {
    [self dismissKeyboard];
    self.game.isFirstPointOline = self.initialLine.selectedSegmentIndex == 0;
    [self saveChanges];
}

-(IBAction)gamePointChanged: (id) sender {
    [self dismissKeyboard];
    // "time" is last segment in UI but is 0 in game
    int gamePoint = (self.gamePointsSegmentedControl.selectedSegmentIndex == (self.gamePointsSegmentedControl.numberOfSegments - 1)) ? kTimeBasedGame : ((int)self.gamePointsSegmentedControl.selectedSegmentIndex *2) + kLowestGamePoint;
    [Preferences getCurrentPreferences].gamePoint = gamePoint;
    [[Preferences getCurrentPreferences] save];
    self.game.gamePoint = gamePoint;
    [self saveChanges];
}

- (IBAction)gameTypeChanged:(id)sender {
    if (self.gameTypeSegmentedControl.selectedSegmentIndex == 0) {
        self.game.leaguevineGame = nil;
        [self populateLeaguevineCells];
        [self saveChanges];
    }
    [self configureCells];
    [self.tableView reloadData];
}

- (IBAction)pubToLeaguevineChanged:(id)sender {
    [self leaguevinePublishChanged];
}

- (IBAction)positionalEventsChanged:(id)sender {
    BOOL shouldBePositional = self.positionalEventsSegmentedControl.selectedSegmentIndex == 1;
    if ([self hasGameBeenStarted] && [self.game hasEvents]) {
        [self handleInProgressGamePositionalChange: shouldBePositional];
    } else {
        self.game.isPositional = shouldBePositional;
        [self saveChanges];
        [self reconfigureCells];
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL ok = [self verifyOpponentName];
    if (ok) {
        [textField resignFirstResponder];
    }
    return ok;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    BOOL isTooLong = newLength > (textField == self.tournamentNameField ? kMaxTournamentNameLength : kMaxOpponentNameLength );
    if (isTooLong) {
        [SoundPlayer playKeyIgnored];
    }
    return !isTooLong;
}


-(IBAction) deleteClicked: (id) sender {

    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: kAlertTitleDeleteGame
                          message: @"Are you sure you want to delete this game?"
                          delegate: self
                          cancelButtonTitle: @"Cancel"
                          otherButtonTitles: @"Delete", nil];
    [alert show];
}

-(IBAction)startClicked: (id) sender {
    [self dismissKeyboard];
    if ([self verifyOpponentName]) {
        self.game.startDateTime = [NSDate date];
        self.game.tournamentName = [self.tournamentNameField.text trim];
        [self.game saveWithUpload];
        [Game setCurrentGame:self.game.gameId];
        self.game = [Game getCurrentGame];
        [self upateViewTitle];
        [self logLeaguevinePostingStatus];
        if (IS_IPAD) {
            [self notifyChangeListenerOfCRUD:CRUDAdd];
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            [self goToActionView];
        }
        [[SHSAnalytics sharedAnalytics] logGameStart];
    }
}

#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([alertView.title isEqualToString:kAlertTitleDeleteGame]) {
        if (buttonIndex == 1) {  // delete
            [self.game delete];
            if (IS_IPAD) {
                [self notifyChangeListenerOfCRUD:CRUDDelete];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    } else if ([alertView.title isEqualToString:kAlertLeaguevineStatsStartingWithGameInProgress] ||
               [alertView.title isEqualToString:kAlertLeaguevineStatsStarting] ||
               [alertView.title isEqualToString:kAlertLeaguevineStatsEnding]) {
        [self updateLeaguevinePublishing];
    } else if ([alertView.title isEqualToString:kAlertLeaguevineStatsNotAllowedWithPrivatePlayers]) {
        [self populateLeaguevineCells];
    } else  if ([alertView.title isEqualToString:kAlertOpeningFinishedGame]) {
        if (buttonIndex == 1) {  // re-open game
            [[Game getCurrentGame] removeLastEvent];
            [self goToActionView];
        }
    } else if ([alertView.title isEqualToString:kAlertConfirmPositionalToNormalSwitch]) {
        [self convertGameFromPositionalToNormal: buttonIndex == 1];
    }
}

#pragma mark - Leaguevine

 -(void)logLeaguevinePostingStatus {
     if (self.game.publishScoreToLeaguevine) {
         SHSLog(@"game started...publishing SCORES to leaguevine");
     } else if (self.game.publishStatsToLeaguevine) {
         SHSLog(@"game started...publishing STATS to leaguevine");
     }
 }

-(BOOL)isLeaguevineType {
    return self.gameTypeSegmentedControl.selectedSegmentIndex == 1;
}

-(void)populateLeaguevineCells {
    self.leaguevineGameLabel.text = self.game.leaguevineGame ? [self.game.leaguevineGame shortDescription] : @"NOT SET";
    self.pubToLeaguevineSegmentedControl.enabled = self.game.leaguevineGame != nil;
//    if ([Team getCurrentTeam].arePlayersFromLeagueVine && self.pubToLeaguevineSegmentedControl.numberOfSegments < 3) {
//        [self.pubToLeaguevineSegmentedControl insertSegmentWithTitle:@"Stats" atIndex:2 animated:NO];
//    }
    if (self.game.publishStatsToLeaguevine) {
        self.pubToLeaguevineSegmentedControl.selectedSegmentIndex = 2;
    } else if (self.game.publishScoreToLeaguevine) {
        self.pubToLeaguevineSegmentedControl.selectedSegmentIndex = 1;
    } else {
        self.pubToLeaguevineSegmentedControl.selectedSegmentIndex = 0;
    }
}

-(void)handleLeaguevineGameSelected: (LeaguevineGame*) leaguevineGame {
    self.game.leaguevineGame = leaguevineGame;
    self.game.publishScoreToLeaguevine = NO;
    self.game.publishStatsToLeaguevine = self.game.leaguevineGame && [Team getCurrentTeam].arePlayersFromLeagueVine;
    if (self.game.publishStatsToLeaguevine) {
        self.pubToLeaguevineSegmentedControl.selectedSegmentIndex = 2;
        [self updateLeaguevinePublishing];
    }
    [self saveChanges];
    [self populateLeaguevineCells];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)askUserForLeauguevineCredentials: (void (^)(BOOL hasLeaguevineCredentials)) completion {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [[self navigationItem] setBackBarButtonItem:backButton];
    LeagueVineSignonViewController* lvController = [[LeagueVineSignonViewController alloc] init];
    UINavigationController* lvNavController = [[UINavigationController alloc] initWithRootViewController:lvController];
    lvController.finishedBlock = ^(BOOL isSignedOn, LeagueVineSignonViewController* signonController) {
        [signonController dismissViewControllerAnimated:YES completion:^{
            completion(isSignedOn);
        }];
    };
    [self presentViewController:lvNavController animated:YES completion:nil];
}

- (void)leaguevinePublishChanged {
    // user is turning OFF stats publishing
    if (self.pubToLeaguevineSegmentedControl.selectedSegmentIndex == 2 && ![[Team getCurrentTeam] arePlayersFromLeagueVine]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:kAlertLeaguevineStatsNotAllowedWithPrivatePlayers
                              message:@"Publishing stats to leaguevine requires that the Team be configured with leaguevine players.\nReturn to the Team players view and select Leaguevine."
                              delegate: self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    // user is turning OFF stats publishing
    } else if (self.pubToLeaguevineSegmentedControl.selectedSegmentIndex != 2 && self.game.publishStatsToLeaguevine) {
        NSString* warning = [self.game hasEvents] ?
            @"You have chosen NOT to publish stats to leaguevine for this game.  Remember that you should not change this property after the game is started." :
            @"Warning: You have STOPPED publishing stats to leaguevine for this game.  Changing this property during a game can lead to unpredictable results if not all stats are posted.";
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:kAlertLeaguevineStatsEnding
                                  message:warning
                                  delegate: self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alert show];
      
    // user is turning ON stats publishing and game is in progress
    } else if (self.pubToLeaguevineSegmentedControl.selectedSegmentIndex == 2 && !self.game.publishStatsToLeaguevine && [self.game hasEvents]) {
        NSString* warning = @"You have chosen to publish stats for a game which is already started.  Any events recorded when stats publishing was off will NOT be posted to leaguevine.";
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:kAlertLeaguevineStatsStartingWithGameInProgress
                              message:warning
                              delegate: self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    // other changes
    } else {
        [self updateLeaguevinePublishing];
    }
}



- (void)updateLeaguevinePublishing {
    self.game.publishScoreToLeaguevine = self.pubToLeaguevineSegmentedControl.selectedSegmentIndex == 1;
    self.game.publishStatsToLeaguevine = self.pubToLeaguevineSegmentedControl.selectedSegmentIndex == 2;
    if (self.game.publishScoreToLeaguevine || self.game.publishStatsToLeaguevine) {
        if (![[Preferences getCurrentPreferences].leaguevineToken isNotEmpty]) {
            [self askUserForLeauguevineCredentials:^(BOOL hasLeaguevineCredentials) {
                if (!hasLeaguevineCredentials) {
                    self.game.publishScoreToLeaguevine = NO;
                    self.game.publishStatsToLeaguevine = NO;
                }
                [self populateLeaguevineCells];
                [self saveChanges];
                if (hasLeaguevineCredentials) {
                    if (self.game.publishScoreToLeaguevine) {
                        [self postScoreToleaguevine];
                    } else if (self.game.publishStatsToLeaguevine) {
                        UIAlertView *alert = [[UIAlertView alloc]
                                              initWithTitle:@"Leaguevine Publishing Started"
                                              message:@"All events recorded by iUltimate will be published to leaguevine."
                                              delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
                        [alert show];
                    }
                }
            }];
        } else {
            if (self.game.publishScoreToLeaguevine) {
                [self postScoreToleaguevine];
            } 
        }
    } else {
        [self saveChanges];
    }
    SHSLog(@"leaguevine publishing status for game vs. %@ changed.  New status is %@", self.game.opponentName, self.game.publishStatsToLeaguevine ? @"STATS" : self.game.publishScoreToLeaguevine ? @"SCORE" : @"NONE");
}

-(void)postScoreToleaguevine {
    Score score = [self.game getScore];
    if (score.ours > 0 || score.theirs > 0) {
        LeaguevineClient* lvClient = [[LeaguevineClient alloc] init];
        [lvClient postGameScore: self.game.leaguevineGame score: score isFinal: [self.game doesGameAppearDone] completion: ^(LeaguevineInvokeStatus status, id result) {
            if (status == LeaguevineInvokeOK) {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Leaguevine Updated"
                                      message:@"Leaguvine was updated with the current score. Further updates will be sent after each goal."
                                      delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                [alert show];
            } else if (status == LeaguevineInvokeCredentialsRejected) {
                self.game.publishScoreToLeaguevine = NO;
                [self populateLeaguevineCells];
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Leaguevine Signon Invalid"
                                      message:@"Leaguevine signon is no longer valid.  Try again by turning on publishing to Leaguevine."
                                      delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                [alert show];
            }
        }];
    } else {
        NSString* message = [NSString stringWithFormat:@"Automatic publishing to Leaguevine is active.  %@", self.game.publishStatsToLeaguevine ? @"All events will be sent to leaguevine." :  @"Team scores (no player stats) will be sent after each goal."];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Leaguevine Publishing Ready"
                              message:message
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - Table delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [self configureCells];
    return [self.cells count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [self.cells objectAtIndex:[indexPath row]];
    cell.backgroundColor = [ColorMaster getFormTableCellColor];
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    [self dismissKeyboard];
    NSUInteger row = [indexPath row];
    UITableViewCell* cell = [self.cells objectAtIndex:row];
    if (cell == self.windCell) {
        WindViewController* windController = [[WindViewController alloc] init];
        windController.game = self.game;
        [self.navigationController pushViewController:windController animated:YES];
    } else if (cell == self.statsCell) {
        StatsViewController* statsController = [[StatsViewController alloc] init];
        statsController.game = self.game;
        [self.navigationController pushViewController:statsController animated:YES];
    } else if (cell == self.eventsCell) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"GameHistoryController" bundle:nil];
        GameHistoryController* eventsController   = [storyboard instantiateInitialViewController];
        eventsController.game = self.game;
        [self.navigationController pushViewController:eventsController animated:YES];
    } else if (cell == self.timeoutsCell) {
        TimeoutViewController* timeoutController = [[TimeoutViewController alloc] init];
        timeoutController.game = self.game;
        [self.navigationController pushViewController:timeoutController animated:YES];
    } else if (cell == self.playbackCell) {
        GamePlaybackViewController* playbackController = [[GamePlaybackViewController alloc] init];
        playbackController.game = self.game;
        playbackController.team = [Team getCurrentTeam];
        UINavigationController* topNavigationController = self.topViewController ? self.topViewController.navigationController : self.navigationController;
        topNavigationController.navigationBarHidden = NO;
        [topNavigationController pushViewController:playbackController animated:YES];
    } else if (cell == self.opponentLeaguevineCell) {
        LeagueVineGameViewController* leaguevineController = [[LeagueVineGameViewController alloc] init];
        leaguevineController.team = [Team getCurrentTeam];
        leaguevineController.game = self.game;
        leaguevineController.selectedBlock = ^(LeaguevineGame* leaguevineGame) {
            [self handleLeaguevineGameSelected: leaguevineGame];
        };
        [self.navigationController pushViewController:leaguevineController animated:YES];
    } else if (cell == self.fieldDimensionsCell) {
        [self showFieldDimensionsView];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self.game hasBeenSaved]) {
        UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, kHeaderHeight)];
        headerView.backgroundColor = [ColorMaster lightBackgroundColor];
        
        // start time
        NSString* dateText = self.game.startDateTime ? [self.dateFormat stringFromDate:self.game.startDateTime] : @"Start Time Unknown";
        CGFloat buttonMargin = 5;
        UIButton* dateButton = [[UIButton alloc] initWithFrame:CGRectMake(10, buttonMargin, 190, kHeaderHeight - (buttonMargin * 2))];
        [dateButton.layer setBorderWidth:1.0f];
        [dateButton.layer setBorderColor:[ColorMaster darkGrayColor].CGColor];
        dateButton.layer.cornerRadius = 5;
        dateButton.layer.masksToBounds = YES;
        dateButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [dateButton setTitleColor:[ColorMaster darkGrayColor] forState:UIControlStateNormal];
        dateButton.backgroundColor = [UIColor clearColor];
        [dateButton setTitle:dateText forState:UIControlStateNormal];
        [dateButton addTarget:self action:@selector(dateTimeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:dateButton];
        
        // score
        UILabel* scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 110, kHeaderHeight)];
        scoreLabel.textAlignment = NSTextAlignmentRight;
        scoreLabel.backgroundColor = [UIColor clearColor];
        scoreLabel.font = [UIFont boldSystemFontOfSize:16];
        Score score = [self.game getScore];
        NSString* scoreSuffix = score.ours == score.theirs ? @"tied" : (score.ours > score.theirs ? @"us" :  @"them");
        scoreLabel.text = [NSString stringWithFormat:@"%d-%d (%@)", score.ours, score.theirs, scoreSuffix];
        scoreLabel.textColor = score.ours == score.theirs ? [UIColor blackColor] : (score.ours > score.theirs ? [UIColor blackColor] : [ColorMaster getLoseScoreColor]);
        [headerView addSubview:scoreLabel];
        
        return headerView;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [self.game hasBeenSaved] ? kHeaderHeight : kEmptyHeaderHeight;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = kFormCellHeight;
    self.tableView.tableFooterView = self.footerView;
    
    self.gameTypeSegmentedControl.apportionsSegmentWidthsByContent = YES;
    self.gameTypeSegmentedControl.selectedSegmentIndex = 0;
    self.gamePointsSegmentedControl.apportionsSegmentWidthsByContent = YES;
    
    [self.opposingTeamNameField addTarget:self action:@selector(opponentNameChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.tournamentNameField addTarget:self action:@selector(tournamendNameChanged:) forControlEvents:UIControlEventEditingChanged];
    self.opposingTeamNameField.delegate = self; 
    self.tournamentNameField.delegate = self;
    if (self.isModalAddMode) {
        UIBarButtonItem *cancelBarItem = [[UIBarButtonItem alloc] initWithTitle: @"Cancel" style: UIBarButtonItemStyleBordered target:self action:@selector(cancelModalDialog)];
        self.navigationItem.leftBarButtonItem = cancelBarItem;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];  
    [self dismissKeyboard];
    self.windLabel.text = [self.game.wind isSpecified] ? [NSString stringWithFormat:@"%d mph", self.game.wind.mph] : @"NOT SPECIFIED YET"; 
    [self populateUIFromModel];
    [self registerForKeyboardNotifications];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (IS_IPAD && self.isModalAddMode) {
        [self showPositionalCallout];
    }
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Keyboard Up/Down Handling

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
    // make the view port smaller so the user can scroll up to see all of the view
    CGFloat keyboardY = [self calcKeyboardOrigin:aNotification];
    CGFloat tableBottom = CGRectGetMaxY(self.tableView.frame);
    CGFloat newBottomInset = MAX(tableBottom - keyboardY, 0);
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, newBottomInset, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    // undo the view port 
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}


#pragma mark - DateTime picker

-(void)showDateTimePicker {
    GameStartTimeViewController* startTimeController = [[GameStartTimeViewController alloc] init];
    startTimeController.date = self.game.startDateTime;
    startTimeController.completion = ^(GameStartTimeViewController* startTimeController) {
        if (startTimeController.date) {
            self.game.startDateTime = startTimeController.date;
            [self.game save];
            if (IS_IPAD) {
                [self notifyChangeListenerOfCRUD: CRUDUpdate];
            }
        }
        [self.navigationController popViewControllerAnimated:YES];
    };
    [self.navigationController pushViewController:startTimeController animated:YES];
}

#pragma mark - iPad only (Master/Detail UX)

-(void)notifyChangeListenerOfCRUD: (CRUD) crud {
    if (self.gameChangedBlock) {
        self.gameChangedBlock(crud);
    }
}

-(void)cancelModalDialog {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Misc

-(void)goToActionView {
    GameViewController* gameController = [[self class] createActionViewController];
    UINavigationController* topNavigationController = self.topViewController ? self.topViewController.navigationController : self.navigationController;
    [topNavigationController pushViewController:gameController animated:YES];
}

-(void)saveChanges {
    if ([self.game hasBeenSaved]) {
        [self.game save];
        if (IS_IPAD) {
            [self notifyChangeListenerOfCRUD: CRUDUpdate];
        }
    }
}

-(void)dismissKeyboard {
    [self.opposingTeamNameField resignFirstResponder];
    [self.tournamentNameField resignFirstResponder];
}

-(void)populateUIFromModel {
    [self upateViewTitle];
    
    self.opposingTeamNameField.text = self.game.opponentName;
    self.tournamentNameField.text = [self.game hasBeenSaved] ? self.game.tournamentName : [Preferences getCurrentPreferences].tournamentName;
    
    self.initialLine.selectedSegmentIndex = self.game.isFirstPointOline ? 0 : 1;
    
    if (self.game.gamePoint == 0) {
        self.game.gamePoint = [Preferences getCurrentPreferences].gamePoint;
        if (self.game.gamePoint == 0) {
            self.game.gamePoint = kDefaultGamePoint;
        }
    }
    
    // kTimeBasedGame is last segment in UI
    int segmentIndex = self.game.gamePoint == kTimeBasedGame ? (int)self.gamePointsSegmentedControl.numberOfSegments - 1 : (self.game.gamePoint - kLowestGamePoint) / 2;
    if (segmentIndex < 0) {
        segmentIndex = 0;
    }
    self.gamePointsSegmentedControl.selectedSegmentIndex = segmentIndex;
    
    self.startButtonView.hidden = [self.game hasBeenSaved];
    self.deleteButtonView.hidden = !self.startButtonView.hidden;
    
    if ([self.game hasBeenSaved]) {
        UIBarButtonItem *navBarActionButton = [[UIBarButtonItem alloc] initWithTitle: @"Action" style: UIBarButtonItemStyleBordered target:self action:@selector(actionButtonTapped)];
        self.navigationItem.rightBarButtonItem = navBarActionButton;
    }
    
    self.gameTypeSegmentedControl.selectedSegmentIndex = [self.game isLeaguevineGame] ? 1 : 0;
    
    self.positionalEventsSegmentedControl.selectedSegmentIndex = self.game.isPositional ? 1 : 0;
    
    if (self.game.isPositional) {
        self.fieldDimensionsLabel.text = [self.game.fieldDimensions description];
    }
    
    [self populateLeaguevineCells];
    
    [self.tableView reloadData];
}

-(BOOL)verifyOpponentName {
    if (self.game.leaguevineGame) {
        return YES;
    }
    NSString* opponentName = [self getText: self.opposingTeamNameField];
    NSString* message = [self isLeaguevineType] ? @"Leaguevine game selection required" : @"Opponent required";
    if ([opponentName isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Invalid Opponent"
                              message:message
                              delegate:self
                              cancelButtonTitle:@"Try Again"
                              otherButtonTitles:nil];
        [alert show];
        return NO;
    } else {
        return YES;
    }
}


-(NSString*) getText: (UITextField*) textField {
    return textField.text == nil ? @"" : [textField.text trim];
}

-(void)upateViewTitle {
    self.title = [self.game hasBeenSaved] ? (IS_IPAD ? [NSString stringWithFormat:@"vs. %@", self.game.opponentName] : @"Game") : @"Start New Game";
}

-(void)setGame:(Game *)game {
    BOOL animate = _game != nil;
    _game = game;
    if (IS_IPAD) {
        if (self.navigationController.visibleViewController == self) {
            if (animate) {
                [self populateUIFromModel];
                [UIView transitionWithView:self.tableView duration:0.5f options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void) {
                    
                } completion:nil];
            } else {
                [self populateUIFromModel];
            }
        } else {
            [self.navigationController popToRootViewControllerAnimated:YES];
            [self populateUIFromModel];
        }
    } else {
        [self populateUIFromModel];
    }
}


+(GameViewController*)createActionViewController {
    GameViewController* gameController = IS_IPAD && [Game getCurrentGame].isPositional ? [[GamePositionalViewController alloc] init] : [[GameViewController alloc] init];
    return gameController;
}

-(BOOL)hasGameBeenStarted {
    return self.game.startDateTime != 0;
}


#pragma mark - Positional Game

-(void)handleInProgressGamePositionalChange: (BOOL) switchToPositional {
    if (switchToPositional) {
        self.positionalEventsSegmentedControl.selectedSegmentIndex = 0;
        [self alertCannotSwitchToPositional];
    } else {
        [self confirmPositionalToNormal];
    }
}

-(void)showPositionalGameNotAllowedOnIPhoneAlert {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Cannot Open Positional Game"
                          message: @"This game was created on an iPad with positional data.  These types of games can only be opened on an iPad."
                          delegate: nil
                          cancelButtonTitle: NSLocalizedString(@"OK",nil)
                          otherButtonTitles: nil];
    [alert show];
}

-(void)confirmPositionalToNormal {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: kAlertConfirmPositionalToNormalSwitch
                          message: @"Your game already has actions recorded with positions.  Are you sure you want to convert the game to normal?"
                          delegate: self
                          cancelButtonTitle: @"No"
                          otherButtonTitles: @"Yes", nil];
    [alert show];
}

-(void)alertCannotSwitchToPositional {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Cannot Switch Game to Positional"
                          message: @"Your game already has actions without positions.  In order to switch the game to positional you must remove all of the actions."
                          delegate: nil
                          cancelButtonTitle: @"OK"
                          otherButtonTitles: nil];
    [alert show];
}

-(void)convertGameFromPositionalToNormal: (BOOL)convert {
    if (convert) {
        [self.game removePositionalData];
        self.game.isPositional = NO;
        [self saveChanges];
        [self reconfigureCells];
    } else {
        self.positionalEventsSegmentedControl.selectedSegmentIndex = 1;
    }
}

-(void)showFieldDimensionsView {
    GameFieldDimensionsViewController* dimensionsVC = [[GameFieldDimensionsViewController alloc] init];

    [self.navigationController pushViewController:dimensionsVC animated:YES];
}

#pragma mark - Callouts

-(void)showPositionalCallout {
    if (IS_IPAD && ![[NSUserDefaults standardUserDefaults] boolForKey: kIsNotFirstGameStartUsage]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey: kIsNotFirstGameStartUsage];
        CalloutsContainerView *calloutsView = [[CalloutsContainerView alloc] initWithFrame:self.view.bounds];
        
        CGPoint anchor = [self.positionalEventsSegmentedControl convertPoint:self.positionalEventsSegmentedControl.boundsCenter toView:self.view];
        [calloutsView addCallout:@"Did you know?\nRecording action with \"Field Position\" can be quite challenging.  However, with this option you can broadcast games online, playback the game visually and get distance data.  Consider first recording a game at \"Normal\" level before attempting this on a live game." anchor: anchor width: 300 degrees: 210 connectorLength: 160 font: [UIFont systemFontOfSize:14]];
        
        self.calloutsViewContainer = calloutsView;
        [self.view addSubview:self.calloutsViewContainer];
        // move the callouts off the screen and then animate their return.
        [self.calloutsViewContainer slide: YES animated: NO];
        [self.calloutsViewContainer slide: NO animated: YES];
    }
}



@end
