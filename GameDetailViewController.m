//
//  GameDetailViewController.m
//  Ultimate
//
//  Created by Jim Geppert on 2/18/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "GameDetailViewController.h"
#import "Game.h"
#import "Preferences.h"
#import "SoundPlayer.h"
#import "ColorMaster.h"
#import "WindViewController.h"
#import "StatsViewController.h"
#import "GameHistoryController.h"
#import "GameViewController.h"
#import "Wind.h"
#import "NSString+manipulations.h"
#import "Constants.h"
#import "Team.h"
#import "LeagueVineGameViewController.h"
#import "LeaguevineGame.h"
#import "LeagueVineSignonViewController.h"
#import "LeaguevineClient.h"

#define kLowestGamePoint 9
#define kHeaderHeight 40

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

@property (nonatomic, strong) IBOutlet UITableViewCell* opponentCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* tournamentOrPubCell;
@property (strong, nonatomic) IBOutlet UIView *opponentView;
@property (strong, nonatomic) IBOutlet UIView *tournamentView;
@property (strong, nonatomic) IBOutlet UIView *leaguevineOpponentView;
@property (strong, nonatomic) IBOutlet UIView *leaguevinePublishView;

@property (nonatomic, strong) IBOutlet UILabel* windLabel;
@property (nonatomic, strong) IBOutlet UILabel* leaguevineGameLabel;
@property (nonatomic, strong) IBOutlet UITextField* opposingTeamNameField;
@property (nonatomic, strong) IBOutlet UITextField* tournamentNameField;
@property (nonatomic, strong) IBOutlet UIButton* deleteButton;
@property (nonatomic, strong) IBOutlet UIButton* startButton;
@property (nonatomic, strong) IBOutlet UISegmentedControl* initialLine;
@property (nonatomic, strong) IBOutlet UISegmentedControl* gamePointsSegmentedControl;
@property (nonatomic, strong) IBOutlet UISegmentedControl* gameTypeSegmentedControl;
@property (nonatomic, strong) IBOutlet UISegmentedControl* pubToLeaguevineSegmentedControl;

@end

@implementation GameDetailViewController


-(void)goToActionView {
    GameViewController* gameController = [[GameViewController alloc] init];
    [self.navigationController pushViewController:gameController animated:YES]; 
}

-(void)saveChanges {
    if ([self.game hasBeenSaved]) {
        [self.game save];  
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
    int segmentIndex = self.game.gamePoint == kTimeBasedGame ? self.gamePointsSegmentedControl.numberOfSegments - 1 : (self.game.gamePoint - kLowestGamePoint) / 2;      
    if (segmentIndex < 0) {
        segmentIndex = 0;
    }
    self.gamePointsSegmentedControl.selectedSegmentIndex = segmentIndex;    
    
    self.deleteButton.hidden = ![self.game hasBeenSaved];
    self.startButton.hidden = [self.game hasBeenSaved];
    if ([self.game hasBeenSaved]) {
        UIBarButtonItem *navBarActionButton = [[UIBarButtonItem alloc] initWithTitle: @"Action" style: UIBarButtonItemStyleBordered target:self action:@selector(goToActionView)];
        self.navigationItem.rightBarButtonItem = navBarActionButton;    
    }
    
    self.gameTypeSegmentedControl.selectedSegmentIndex = [self.game isLeaguevineGame] ? 1 : 0;
    
    [self populateLeaguevineCells];
    
    [self.tableView reloadData];
    [self addFooterButton];
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

-(void)addFooterButton {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 60)];
    UIButton* footerButton = [self.game hasBeenSaved] ? self.deleteButton : self.startButton;
    footerButton.frame = CGRectMake(95, 0, footerButton.frame.size.width, footerButton.frame.size.height);
    [headerView addSubview: footerButton];
    self.tableView.tableFooterView = headerView;
}

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.dateFormat = [[NSDateFormatter alloc] init];
        [self.dateFormat setDateFormat:@"EEE MMM d h:mm a"];
    }
    return self;
}

-(void)upateViewTitle {
        self.title = [self.game hasBeenSaved] ? NSLocalizedString(@"Game", @"Game") : NSLocalizedString(@"Start New Game", @"Start New Game");
}

-(void)configureCells {
    self.cells = [NSMutableArray array];
    
    if ([[Team getCurrentTeam] isLeaguevineTeam]) {
        [self.cells addObject:self.gameTypeCell];
    }
    [self.cells addObjectsFromArray:@[self.opponentCell, self.tournamentOrPubCell]];
    [self.cells addObjectsFromArray:@[self.initialLineCell, self.gamePointsCell,  self.windCell]];
    if ([self.game hasBeenSaved]) {
        [self.cells addObjectsFromArray:@[self.statsCell, self.eventsCell]];
    }
}

#pragma mark - Event Handlers

-(IBAction)opponentNameChanged: (id) sender {
    self.game.opponentName = [self.opposingTeamNameField.text trim];
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
    int gamePoint = (self.gamePointsSegmentedControl.selectedSegmentIndex == (self.gamePointsSegmentedControl.numberOfSegments - 1)) ? kTimeBasedGame : (self.gamePointsSegmentedControl.selectedSegmentIndex *2) + kLowestGamePoint;
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
        {
            //NSLog(@"Delete was cancelled by the user");
        }
            break;
            
        case 1:
        {
            [self.game delete];
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
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
    // Show the confirmation.
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: NSLocalizedString(@"Delete Game",nil)
                          message: NSLocalizedString(@"Are you sure you want to delete this game?",nil)
                          delegate: self
                          cancelButtonTitle: NSLocalizedString(@"Cancel",nil)
                          otherButtonTitles: NSLocalizedString(@"Delete",nil), nil];
    [alert show];
}

-(IBAction)startClicked: (id) sender {
    [self dismissKeyboard];
    if ([self verifyOpponentName]) {
        self.game.startDateTime = [NSDate date];
        self.game.tournamentName = [self.tournamentNameField.text trim];
        [self.game save];
        [Game setCurrentGame:self.game.gameId];
        self.game = [Game getCurrentGame];
        [self upateViewTitle];
        [self goToActionView];
    }
}

#pragma mark - Leaguevine


-(BOOL)isLeaguevineType {
    return self.gameTypeSegmentedControl.selectedSegmentIndex == 1;
}

-(void)populateLeaguevineCells {
    self.leaguevineGameLabel.text = self.game.leaguevineGame ? [self.game.leaguevineGame opponentDescription] : @"NOT SET";
    self.pubToLeaguevineSegmentedControl.enabled = self.game.leaguevineGame != nil;
    self.pubToLeaguevineSegmentedControl.selectedSegmentIndex = !self.game.publishScoreToLeaguevine;
}

-(void)handleLeaguevineGameSelected: (LeaguevineGame*) leaguevineGame {
    self.game.leaguevineGame = leaguevineGame;
    [self saveChanges];
    [self populateLeaguevineCells];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)askUserForLeauguevineCredentials: (void (^)(BOOL hasLeaguevineCredentials)) completion {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [[self navigationItem] setBackBarButtonItem:backButton];
    LeagueVineSignonViewController* lvController = [[LeagueVineSignonViewController alloc] init];
    lvController.finishedBlock = ^(BOOL isSignedOn, LeagueVineSignonViewController* signonController) {
        [signonController dismissViewControllerAnimated:YES completion:^{
            completion(isSignedOn);
        }];
    };
    [self presentViewController:lvController animated:YES completion:nil];
}

- (void)leaguevinePublishChanged {
    BOOL shouldPublishScores = !self.pubToLeaguevineSegmentedControl.selectedSegmentIndex;
    self.game.publishScoreToLeaguevine = shouldPublishScores;
    if (shouldPublishScores) {
        if (![[Preferences getCurrentPreferences].leaguevineToken isNotEmpty]) {
            [self askUserForLeauguevineCredentials:^(BOOL hasLeaguevineCredentials) {
                self.game.publishScoreToLeaguevine = hasLeaguevineCredentials;
                [self populateLeaguevineCells];
                [self saveChanges];
                if (hasLeaguevineCredentials) {
                    [self updateLeaguevine];
                }
            }];
        } else {
            [self updateLeaguevine];
        }
    } else {
        [self saveChanges];
    }
}

-(void)updateLeaguevine {
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
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Leaguevine Publishing Ready"
                              message:@"Automatic publishing to Leaguevine is active.  Updates will be sent after each goal."
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
    if (cell == self.opponentCell) {
        if ([self.game isLeaguevineGame] || [self isLeaguevineType]) {
            [self transitionCell:cell fromSubview:self.opponentView toView:self.leaguevineOpponentView];
        } else {
            [self transitionCell:cell fromSubview:self.leaguevineOpponentView toView:self.opponentView];
        }
    } else if (cell == self.tournamentOrPubCell) {
        if ([self.game isLeaguevineGame] || [self isLeaguevineType]) {
            [self transitionCell:cell fromSubview:self.tournamentView toView:self.leaguevinePublishView];
        } else {
            [self transitionCell:cell fromSubview:self.leaguevinePublishView toView:self.tournamentView];
        }
    }

    cell.backgroundColor = [ColorMaster getFormTableCellColor];
    return cell;
}

-(void)transitionCell: (UITableViewCell*) cell fromSubview: (UIView*)fromView toView: (UIView*)toView {
    [cell addSubview:toView];
    [UIView animateWithDuration:.3 delay:0 options:0 animations:^{
        fromView.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.4 delay:0 options:0 animations:^{
            toView.alpha = 1;
        } completion:^(BOOL finished) {
            [fromView removeFromSuperview];
        }];
    }];
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
        GameHistoryController* eventsController = [[GameHistoryController alloc] init];
        eventsController.game = self.game;
        [self.navigationController pushViewController:eventsController animated:YES];
    } else if (cell == self.opponentCell && [self isLeaguevineType]) {
        LeagueVineGameViewController* leaguevineController = [[LeagueVineGameViewController alloc] init];
        leaguevineController.team = [Team getCurrentTeam];
        leaguevineController.game = self.game;
        leaguevineController.selectedBlock = ^(LeaguevineGame* leaguevineGame) {
            [self handleLeaguevineGameSelected: leaguevineGame];
        };
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:nil action:nil];
        [[self navigationItem] setBackBarButtonItem:backButton];
        [self.navigationController pushViewController:leaguevineController animated:YES];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self.game hasBeenSaved]) {
        UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, kHeaderHeight)];
        headerView.backgroundColor = [UIColor clearColor];
        
        // start time
        UILabel* dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 190, kHeaderHeight)];
        dateLabel.backgroundColor = [UIColor clearColor];
        [ColorMaster styleAsWhiteLabel:dateLabel size:16];
        dateLabel.text = [self.dateFormat stringFromDate:self.game.startDateTime];
        [headerView addSubview:dateLabel];
        
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
    return [self.game hasBeenSaved] ? kHeaderHeight : 0;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.separatorColor = [ColorMaster getTableListSeparatorColor];
    self.tableView.rowHeight = 34;
    
    self.gameTypeSegmentedControl.tintColor = [ColorMaster getNavBarTintColor];
    self.gameTypeSegmentedControl.selectedSegmentIndex = 0;
    self.gamePointsSegmentedControl.tintColor = [ColorMaster getNavBarTintColor];
    self.initialLine.tintColor = [ColorMaster getNavBarTintColor];    
    
    [self.opposingTeamNameField addTarget:self action:@selector(opponentNameChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.tournamentNameField addTarget:self action:@selector(tournamendNameChanged:) forControlEvents:UIControlEventEditingChanged];
    self.opposingTeamNameField.delegate = self; 
    self.tournamentNameField.delegate = self; 

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];  
    [self dismissKeyboard];
    self.windLabel.text = [self.game.wind isSpecified] ? [NSString stringWithFormat:@"%d mph", self.game.wind.mph] : @"NOT SPECIFIED YET"; 
    [self populateUIFromModel]; 
}

- (void)viewDidUnload
{
    [self setOpponentView:nil];
    [self setTournamentView:nil];
    [self setLeaguevineOpponentView:nil];
    [self setLeaguevinePublishView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

@end
