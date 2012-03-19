//
//  GameDetailViewController.m
//  Ultimate
//
//  Created by Jim Geppert on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameDetailViewController.h"
#import "Game.h"
#import "Preferences.h"
#import "SoundPlayer.h"
#import "ColorMaster.h"
#import "Constants.h"
#import "WindViewController.h"
#import "StatsViewController.h"
#import "GameHistoryController.h"

#define kLowestGamePoint 9

NSArray* cells;

@implementation GameDetailViewController
@synthesize opposingTeamNameField,tournamentNameField,game,startTimeLabel,scoreLabel,makeCurrentButton,startTimeCell,scoreCell,opponentCell,tournamentCell,windCell,statsCell,eventsCell,windLabel,tableView,initialLineCell,gamePointsCell,initialLine,gamePointsSegmentedControl,
    deleteButton, startButton;

-(IBAction) makeCurrentClicked: (id) sender {
    [Game setCurrentGame:game.gameId];
    [self.navigationController popViewControllerAnimated:YES];
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
    if ([self verifyOpponentName]) {
        game.startDateTime = [NSDate date];
        [game save];
        [Game setCurrentGame:game.gameId];
        [self.navigationController popViewControllerAnimated:YES];    
    }
}


-(void)saveChanges {
    if ([self.game hasBeenSaved]) {
        [self.game save];  
    }
}

-(void)populateUIFromModel {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEE MMM d h:mm a"];
    self.startTimeLabel.text = [dateFormat stringFromDate:game.startDateTime];
    
    Score score = [game getScore];
    NSString* scoreSuffix = score.ours == score.theirs ? @"tied" : 
    (score.ours > score.theirs ? @"us" :  @"them");
    self.scoreLabel.text = [NSString stringWithFormat:@"%d-%d (%@)", score.ours, score.theirs, scoreSuffix];
    self.scoreLabel.textColor = score.ours == score.theirs ? [UIColor blackColor] : 
    (score.ours > score.theirs ? [ColorMaster getWinScoreColor] :  [ColorMaster getLoseScoreColor]);
    
    self.opposingTeamNameField.text = self.game.opponentName;
    self.tournamentNameField.text = [self.game hasBeenSaved] ? self.game.tournamentName : [Preferences getCurrentPreferences].tournamentName;
    
    self.initialLine.selectedSegmentIndex = game.isFirstPointOline ? 0 : 1;
    
    if (game.gamePoint == 0) {
        game.gamePoint = [Preferences getCurrentPreferences].gamePoint;
        if (game.gamePoint == 0) {
            game.gamePoint = kDefaultGamePoint;
        }
    } 
    int segmentIndex = (game.gamePoint - kLowestGamePoint) / 2;
    if (segmentIndex < 0) {
        segmentIndex = 0;
    }
    self.gamePointsSegmentedControl.selectedSegmentIndex = segmentIndex;    
    
    self.makeCurrentButton.hidden = (![self.game hasBeenSaved]) || [[Preferences getCurrentPreferences].currentGameFileName isEqualToString:self.game.gameId];
    self.deleteButton.hidden = ![self.game hasBeenSaved];
    self.startButton.hidden = [self.game hasBeenSaved];
    
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
    BOOL isTooLong = newLength > (textField == tournamentNameField ? kMaxTournamentNameLength : kMaxOpponentNameLength );
    if (isTooLong) {
        [SoundPlayer playKeyIgnored];
    }
    return !isTooLong;
}

-(BOOL)verifyOpponentName {
    NSString* opponentName = [self getText: self.opposingTeamNameField];
    if ([opponentName isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle:@"Invalid Opponent Name" 
                              message:@"Opponent team name is required"
                              delegate:self 
                              cancelButtonTitle:@"Try Again" 
                              otherButtonTitles:nil]; 
        [alert show];
        return NO;
    } else {
        return YES;
    } 
}

-(IBAction)opponentNameChanged: (id) sender {
    game.opponentName = opposingTeamNameField.text;
    [self saveChanges];
}

-(IBAction)tournamendNameChanged: (id) sender {
    game.tournamentName = tournamentNameField.text;
    [Preferences getCurrentPreferences].tournamentName = tournamentNameField.text;
    [[Preferences getCurrentPreferences] save];
    [self saveChanges];
}

-(IBAction)firstLineChanged: (id) sender {
    game.isFirstPointOline = self.initialLine.selectedSegmentIndex == 0;   
    [self saveChanges];
}

-(IBAction)gamePointChanged: (id) sender {
    int gamePoint = (self.gamePointsSegmentedControl.selectedSegmentIndex *2) + kLowestGamePoint; 
    [Preferences getCurrentPreferences].gamePoint =gamePoint;
    [[Preferences getCurrentPreferences] save];
    game.gamePoint = gamePoint;
     [self saveChanges];
}

-(NSString*) getText: (UITextField*) textField {
    return textField.text == nil ? @"" : [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([game hasBeenSaved]) {
        cells = [NSArray arrayWithObjects:startTimeCell, scoreCell, opponentCell, tournamentCell, initialLineCell, gamePointsCell,  windCell, statsCell, eventsCell, nil];
    } else {
         cells = [NSArray arrayWithObjects:opponentCell, tournamentCell, initialLineCell, gamePointsCell,  windCell, nil];
    }
    return [cells count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [cells objectAtIndex:[indexPath row]];
    cell.backgroundColor = [ColorMaster getFormTableCellColor];
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath { 
    NSUInteger row = [indexPath row]; 
    UITableViewCell* cell = [cells objectAtIndex:row];
    if (cell == windCell) {
        WindViewController* windController = [[WindViewController alloc] init];
        windController.game = game;
        [self.navigationController pushViewController:windController animated:YES];
    } else if (cell == statsCell) {
        StatsViewController* statsController = [[StatsViewController alloc] init];
        statsController.game = game;
        [self.navigationController pushViewController:statsController animated:YES];
    } else if (cell == eventsCell) {
        GameHistoryController* eventsController = [[GameHistoryController alloc] init];
        eventsController.game = game;
        [self.navigationController pushViewController:eventsController animated:YES];
    }
} 

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 34;
}

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

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
    self.tableView.separatorColor = [ColorMaster getTableListSeparatorColor];
    
    self.title = [game hasBeenSaved] ? NSLocalizedString(@"Game", @"Game") : NSLocalizedString(@"Start New Game", @"Start New Game");

    self.gamePointsSegmentedControl.tintColor = [ColorMaster getNavBarTintColor];
    self.initialLine.tintColor = [ColorMaster getNavBarTintColor];    
    
    [self.opposingTeamNameField addTarget:self action:@selector(opponentNameChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.tournamentNameField addTarget:self action:@selector(tournamendNameChanged:) forControlEvents:UIControlEventEditingChanged];
    self.opposingTeamNameField.delegate = self; 
    self.tournamentNameField.delegate = self; 
    
    [self populateUIFromModel]; 
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];    
    self.navigationController.navigationBar.tintColor = [ColorMaster getNavBarTintColor];
    self.windLabel.text = [game.wind isSpecified] ? [NSString stringWithFormat:@"%d mph", game.wind.mph] : @"NOT SPECIFIED YET"; 
    [self.tableView reloadData];
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

@end
