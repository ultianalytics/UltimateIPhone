//
//  FirstViewController.m
//  Ultimate
//
//  Created by james on 12/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Constants.h"
#import "TeamViewController.h"
#import "Team.h"
#import "TeamDescription.h"
#import "SoundPlayer.h"
#import "Preferences.h"
#import "ColorMaster.h"
#import "TeamPlayersViewController.h"

@implementation TeamViewController
@synthesize team,teamTableView, teamNameField,teamTypeSegmentedControl,playerDisplayTypeSegmentedControl,nameCell,typeCell,displayCell,playersCell,deleteButton,deleteAlertView,shouldSkipToPlayers;

NSArray* cells;

-(void)populateViewFromModel {
    [self.teamNameField setText:(team.name == kNoName ? @"" : team.name)];
    self.teamTypeSegmentedControl.selectedSegmentIndex = team.isMixed ? 1 : 0;
    self.playerDisplayTypeSegmentedControl.selectedSegmentIndex = team.isDiplayingPlayerNumber ? 1 : 0;
    self.deleteButton.hidden = ![team hasBeenSaved];
}

-(void)populateModelFromView {
    team.name = teamNameField.text;
    team.isMixed =  self.teamTypeSegmentedControl.selectedSegmentIndex == 0 ? NO : YES;
    team.isDiplayingPlayerNumber = self.playerDisplayTypeSegmentedControl.selectedSegmentIndex == 0 ? NO : YES;
}


-(void)saveAndReturn {
    if ([self saveChanges]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(BOOL)saveChanges {
    if ([self verifyTeamName]) {
        [self populateModelFromView];
        [self.team save];  
        return YES;
    }
    return NO;
}

-(IBAction)nameChanged: (id) sender {
   
}

-(IBAction)deleteClicked: (id) sender {
    [self verifyAndDelete];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    cells = [[NSArray alloc] initWithObjects:nameCell, typeCell, displayCell, playersCell, nil];
    return [cells count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [cells objectAtIndex: [indexPath row]];
    cell.backgroundColor = [ColorMaster getFormTableCellColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath { 
    [self dismissKeyboard];
    //if ([cells objectAtIndex:[indexPath row] == playersCell) {
    if ([indexPath row] == 3) { // ARG!!!! Can't get the code above to work consistently so doing this rudimentary approach
        if ([self saveChanges]) {
            [Team setCurrentTeam: team.teamId];
            [self goToPlayersView: YES];
        }
    };
} 

-(void)dismissKeyboard {
    [teamNameField resignFirstResponder];
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
        deleteAlertView = [[UIAlertView alloc] 
                              initWithTitle: NSLocalizedString(@"Delete Team",nil)
                              message: NSLocalizedString(@"Are you sure you want to delete this team?",nil)
                              delegate: self
                              cancelButtonTitle: NSLocalizedString(@"Cancel",nil)
                              otherButtonTitles: NSLocalizedString(@"Delete",nil), nil];
        [deleteAlertView show];
    } 
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == deleteAlertView) {
        switch (buttonIndex) {
            case 0: 
            {       
                //NSLog(@"Delete was cancelled by the user");
            }
                break;
                
            case 1: 
            {
                [self.team delete];
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
    NSArray* teamDescriptions = [Team retrieveTeamDescriptions];
    for (TeamDescription* desc in teamDescriptions) {
        if (![desc.teamId isEqualToString: self.team.teamId] && [desc.name caseInsensitiveCompare:newTeamName] == NSOrderedSame) {
            return YES;
        }
    }
    return NO;
}

-(void)goToPlayersView: (BOOL) animated {
    TeamPlayersViewController* playersController = [[TeamPlayersViewController alloc] init];
    [self.navigationController pushViewController:playersController animated:animated];
}

-(void)goToBestView {
    // if we've already started adding players..go back there on app start
    if (shouldSkipToPlayers) {
        shouldSkipToPlayers = NO;
        if ([team.players count] > 0) {
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
    self.teamNameField.delegate = self; 
    [self.teamNameField addTarget:self action:@selector(nameChanged:) forControlEvents:UIControlEventEditingChanged];
    self.navigationController.navigationBar.tintColor = [ColorMaster getNavBarTintColor];
    self.teamTypeSegmentedControl.tintColor = [ColorMaster getNavBarTintColor];
    self.playerDisplayTypeSegmentedControl.tintColor = [ColorMaster getNavBarTintColor];
    UIBarButtonItem *saveBarItem = [[UIBarButtonItem alloc] initWithTitle: @"Save" style: UIBarButtonItemStyleBordered target:self action:@selector(saveAndReturn)];
    self.navigationItem.rightBarButtonItem = saveBarItem;    

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self populateViewFromModel];

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

@end
