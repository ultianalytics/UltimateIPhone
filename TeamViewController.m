//
//  TeamViewController.m
//  Ultimate
//
//  Created by Jim Geppert on 2/25/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "Constants.h"
#import "TeamViewController.h"
#import "Team.h"
#import "TeamDescription.h"
#import "SoundPlayer.h"
#import "Preferences.h"
#import "ColorMaster.h"
#import "TeamPlayersViewController.h"
#import "AppDelegate.h"
#import "UltimateSegmentedControl.h"
#import "NSString+manipulations.h"
#import "LeagueVineSignonViewController.h"
#import "LeagueVineLeagueViewController.h"
#import "LeaguevineClient.h"


@interface TeamViewController()

@end

@implementation TeamViewController

-(void)populateViewFromModel {
    [self.teamNameField setText:([self.team.name isEqualToString: kAnonymousTeam] ? @"" : self.team.name)];
    [self.teamTypeSegmentedControl setSelection: self.team.isMixed ? @"Mixed" : @"Uni"];
    [self.playerDisplayTypeSegmentedControl setSelection: self.team.isDiplayingPlayerNumber ? @"Number" : @"Name"];    
    self.deleteButton.hidden = ![self.team hasBeenSaved];
#ifdef DEBUG
    self.clearCloudIdButton.hidden = NO;
#endif
}

-(void)populateModelFromView {
    self.team.name = [self.teamNameField.text trim];
    self.team.isMixed =  [[self.teamTypeSegmentedControl getSelection] isEqualToString: @"Mixed"] ? YES : NO;
    self.team.isDiplayingPlayerNumber =  [[self.playerDisplayTypeSegmentedControl getSelection] isEqualToString: @"Number"] ? YES : NO;
}

-(void)saveAndContinue {
    if ([self saveChanges]) {
        [self goToPlayersView:YES];
    }
}

-(BOOL)saveChanges {
    if ([self verifyTeamName]) {
        [self populateModelFromView];
        [self.team save];  
        [Team setCurrentTeam:self.team.teamId];
        self.team = [Team getCurrentTeam];
        return YES;
    }
    return NO;
}

-(IBAction)nameChanged: (id) sender {
   
}

-(IBAction)deleteClicked: (id) sender {
    [self verifyAndDelete];
}

- (IBAction)copyClicked:(id)sender {
    Team* teamCopy = [self.team copy];
    [teamCopy save];
    [Team setCurrentTeam:teamCopy.teamId];
    self.team = teamCopy;
    [self populateViewFromModel];
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Team Copied"
                          message:@"The team (and all players) have been copied and saved.  Consider entering a better team name before leaving this view."
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

- (IBAction)clearCloudIdClicked:(id)sender {
    self.team.cloudId = nil;
}

-(IBAction)teamTypeChanged: (id) sender {
    [self dismissKeyboard];
}

-(IBAction)playerDisplayChanged: (id) sender {
    [self dismissKeyboard];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    BOOL isTooLong = (newLength > kMaxTeamNameLength);
    if (isTooLong) {
        [SoundPlayer playKeyIgnored];
    }
    return !isTooLong;
}

#pragma mark TableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.cells) {
        self.cells = [[NSArray alloc] initWithObjects:self.nameCell, self.typeCell, self.displayCell, self.playersCell, self.leagueVineCell, nil];
    }
    return [self.cells count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [self.cells objectAtIndex: [indexPath row]];
    cell.backgroundColor = [ColorMaster getFormTableCellColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath { 
    [self dismissKeyboard];
    if ([self.cells objectAtIndex:[indexPath row]] == self.playersCell) {
        if ([self saveChanges]) {
            [Team setCurrentTeam: self.team.teamId];
            [self goToPlayersView: YES];
        }
    } else if ([self.cells objectAtIndex:[indexPath row]] == self.leagueVineCell) {
        [self handleLeaguevineTeamSelection];
    }
} 

#pragma mark

-(void)dismissKeyboard {
    [self.teamNameField resignFirstResponder];
}

-(BOOL)verifyTeamName {
    NSString* teamName = [self getText: self.teamNameField];
    if ([teamName isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle:@"Invalid Team Name" 
                              message:@"Team name is required"
                              delegate:self 
                              cancelButtonTitle:@"Try Again" 
                              otherButtonTitles:nil]; 
        [alert show];
        return NO;
    } else if ([self isDuplicateTeamName:teamName]) {
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle:@"Duplicate Team Name" 
                              message:@"Each team must have a unique name"
                              delegate:self 
                              cancelButtonTitle:@"Try Again" 
                              otherButtonTitles:nil]; 
        [alert show];
        return NO;  
    } else {
        return YES;
    } 
}

-(void)verifyAndDelete {
    if ([[Team retrieveTeamDescriptions] count] < 2) {
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle:@"Delete not allowed" 
                              message:@"You cannot delete this team because it is the only team remaining."
                              delegate:self 
                              cancelButtonTitle:@"OK" 
                              otherButtonTitles:nil]; 
        [alert show];
    } else {
        self.deleteAlertView = [[UIAlertView alloc]
                              initWithTitle: NSLocalizedString(@"Delete Team",nil)
                              message: NSLocalizedString(@"Are you sure you want to delete this team?",nil)
                              delegate: self
                              cancelButtonTitle: NSLocalizedString(@"Cancel",nil)
                              otherButtonTitles: NSLocalizedString(@"Delete",nil), nil];
        [self.deleteAlertView show];
    } 
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == self.deleteAlertView) {
        switch (buttonIndex) {
            case 0: 
            {       
                //NSLog(@"Delete was cancelled by the user");
            }
                break;
                
            case 1: 
            {
                [self.team delete];
                [((AppDelegate*)[[UIApplication sharedApplication]delegate]) resetGameTab];
                [self.navigationController popViewControllerAnimated:YES];
            }
                break;
        }
    }
}

-(NSString*) getText: (UITextField*) textField {
    return textField.text == nil ? @"" : [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(BOOL) isDuplicateTeamName: (NSString*) newTeamName {
    return [Team isDuplicateTeamName: newTeamName notIncluding: self.team];
}

-(void)goToPlayersView: (BOOL) animated {
    TeamPlayersViewController* playersController = [[TeamPlayersViewController alloc] init];
    [self.navigationController pushViewController:playersController animated:animated];
}

-(void)goToBestView {
    // if we've already started adding players..go back there on app start
    if (self.shouldSkipToPlayers) {
        self.shouldSkipToPlayers = NO;
        if ([self.team.players count] > 0) {
            [self goToPlayersView: NO];
        }
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Team", @"Team");
    }
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.clearCloudIdButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.clearCloudIdButton.titleLabel.textAlignment = UITextAlignmentCenter;
    self.teamNameField.delegate = self;
    [self.teamNameField addTarget:self action:@selector(nameChanged:) forControlEvents:UIControlEventEditingChanged];
    UIBarButtonItem *saveBarItem = [[UIBarButtonItem alloc] initWithTitle: @"Save" style: UIBarButtonItemStyleBordered target:self action:@selector(saveAndContinue)];
    self.navigationItem.rightBarButtonItem = saveBarItem;

}

- (void)viewDidUnload
{
    self.clearCloudIdButton = nil;
    self.teamCopyButton = nil;
    [self setLeagueVineCell:nil];
    [self setLeagueVineDescriptionLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self populateViewFromModel];
    // special case: app is starting and we are pre-loading the stack of views for efficiency (we want user
    // to land on the players view if they've already been working with a team).  If they arrive on this view
    // with an existing team that is not the current team then we want to push them back to teams view.
    if (![self.team.teamId isEqualToString:[Team getCurrentTeam].teamId] && [self.team hasBeenSaved]) {
        [self.navigationController popViewControllerAnimated:NO];
    }

}

- (void)viewDidAppear:(BOOL)animated {
    [self goToBestView];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark Leaguevine 

-(void)handleLeaguevineTeamSelection {
    LeaguevineClient* lvClient = [[LeaguevineClient alloc] init];
    LeagueVineLeagueViewController* leagueController = [[LeagueVineLeagueViewController alloc] init];
    leagueController.leaguevineClient = lvClient;
    [self.navigationController pushViewController:leagueController animated:YES];
}

// TODO...probably don't need this method here...just sample code for how to interact with signon
-(void)presentLeaguevineSignon {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [[self navigationItem] setBackBarButtonItem:backButton];
    LeagueVineSignonViewController* lvController = [[LeagueVineSignonViewController alloc] init];
    lvController.finishedBlock = ^(BOOL isSignedOn, LeagueVineSignonViewController* signonController) {
        [signonController dismissViewControllerAnimated:YES completion:nil];
    };
    [self presentViewController:lvController animated:YES completion:nil];
}


@end
